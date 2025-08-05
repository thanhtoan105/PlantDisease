import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../config/ai_model_config.dart';

class TensorFlowService {
  static Interpreter? _interpreter;
  static bool _isModelLoaded = false;
  static bool _isInitialized = false;
  static List<String>? _labels;
  static String? _initializationError;
  static bool _isUsingGPU = false;
  static int _optimalThreadCount = 2;

  // Model configuration from centralized config
  static const int modelInputSize = AIModelConfig.inputImageSize;
  static const int modelChannels = AIModelConfig.modelChannels;
  static const String modelPath = AIModelConfig.modelPath;
  static const String labelsPath = AIModelConfig.labelsPath;

  /// Initialize TensorFlow Lite model with optimized CPU/GPU detection
  static Future<bool> initialize() async {
    try {
      debugPrint('🔬 Initializing TensorFlow Lite model...');
      _isInitialized = true;
      _initializationError = null;

      // Detect optimal hardware configuration first
      await _detectOptimalConfiguration();

      // Check if model file exists first with detailed debugging
      try {
        debugPrint('🔍 Attempting to load model from: $modelPath');
        final modelData = await rootBundle.load(modelPath);
        debugPrint('📊 Model file found, size: ${modelData.lengthInBytes} bytes');

        // Verify the model data is valid
        if (modelData.lengthInBytes < 1000) {
          throw Exception('Model file too small, might be corrupted');
        }

        debugPrint('✅ Model file validation passed');
      } catch (e) {
        debugPrint('❌ Model file loading failed: $e');
        debugPrint('🔍 Error type: ${e.runtimeType}');
        debugPrint('⚠️ Model file not found or corrupted. Please ensure tomato_model_final.tflite is in assets/models/');
        debugPrint('📖 See assets/models/README.md for setup instructions');

        // Try to list available assets for debugging
        try {
          final manifestContent = await rootBundle.loadString('AssetManifest.json');
          debugPrint('📋 Available assets: $manifestContent');
        } catch (manifestError) {
          debugPrint('⚠️ Could not load asset manifest: $manifestError');
        }

        _initializationError = 'Model file not found. Please rebuild the app after ensuring the model file is in assets/models/';
        _isModelLoaded = false;
        await _loadLabels(); // Still load labels for UI
        return true; // Return true to allow app to continue
      }

      // Initialize interpreter with optimized configuration
      await _initializeInterpreter();

      // Load labels if available
      await _loadLabels();

      // If no labels were loaded from file, generate generic ones based on model output
      if (_labels == null) {
        _generateGenericLabels();
      }

      _isModelLoaded = true;
      debugPrint('✅ TensorFlow model loaded successfully');
      debugPrint('🚀 Using ${_isUsingGPU ? 'GPU' : 'CPU'} with $_optimalThreadCount threads');

      // Print model info
      _printModelInfo();

      return true;
    } catch (e) {
      debugPrint('❌ Failed to load TensorFlow model: $e');
      debugPrint('🔍 Error details: ${e.runtimeType}');
      _initializationError = 'Failed to initialize TensorFlow: $e';
      _isModelLoaded = false;
      await _loadLabels(); // Still load labels for UI
      return true; // Return true to allow app to continue
    }
  }

  /// Detect optimal hardware configuration for the device
  static Future<void> _detectOptimalConfiguration() async {
    try {
      // Detect CPU cores for optimal thread count
      _optimalThreadCount = Platform.numberOfProcessors;

      // Cap thread count based on device performance
      if (_optimalThreadCount > 4) {
        _optimalThreadCount = 4; // Most mobile GPUs work best with 4 threads max
      } else if (_optimalThreadCount < 2) {
        _optimalThreadCount = 2; // Minimum for decent performance
      }

      debugPrint('🔧 Detected $_optimalThreadCount CPU cores, using $_optimalThreadCount threads');

      // Check if we're running on a high-performance device
      final isHighPerformanceDevice = _optimalThreadCount >= 4;

      if (isHighPerformanceDevice && Platform.isAndroid) {
        debugPrint('📱 High-performance Android device detected, GPU delegate preferred');
      } else {
        debugPrint('📱 Standard device detected, CPU optimization preferred');
      }
    } catch (e) {
      debugPrint('⚠️ Hardware detection failed, using default configuration: $e');
      _optimalThreadCount = 2;
    }
  }

  /// Initialize interpreter with optimized GPU/CPU configuration
  static Future<void> _initializeInterpreter() async {
    // Strategy: Try GPU first on capable devices, then fallback to optimized CPU

    // First, try GPU delegate on Android devices
    if (Platform.isAndroid && _optimalThreadCount >= 3) {
      try {
        debugPrint('🚀 Attempting GPU initialization...');
        final gpuOptions = InterpreterOptions();

        // Configure GPU delegate with simplified settings
        final gpuDelegate = GpuDelegateV2(
          options: GpuDelegateOptionsV2(
            isPrecisionLossAllowed: false, // Keep precision for medical/agricultural use
          ),
        );

        gpuOptions.addDelegate(gpuDelegate);
        gpuOptions.threads = 1; // GPU delegate typically uses 1 thread

        _interpreter = await Interpreter.fromAsset(modelPath, options: gpuOptions);
        _isUsingGPU = true;

        debugPrint('✅ GPU delegate initialized successfully');
        return;
      } catch (e) {
        debugPrint('⚠️ GPU delegate initialization failed: $e');
        debugPrint('🔄 Falling back to optimized CPU execution...');
      }
    }

    // CPU-only execution with optimized settings
    try {
      debugPrint('🖥️ Initializing optimized CPU execution...');
      final cpuOptions = InterpreterOptions();

      // Optimize CPU execution
      cpuOptions.threads = _optimalThreadCount;

      _interpreter = await Interpreter.fromAsset(modelPath, options: cpuOptions);
      _isUsingGPU = false;

      debugPrint('✅ Optimized CPU execution initialized with $_optimalThreadCount threads');
    } catch (e) {
      // Final fallback with minimal settings
      debugPrint('⚠️ Optimized CPU failed, using basic CPU configuration: $e');
      final basicOptions = InterpreterOptions();
      basicOptions.threads = 2;

      _interpreter = await Interpreter.fromAsset(modelPath, options: basicOptions);
      _isUsingGPU = false;

      debugPrint('✅ Basic CPU execution initialized');
    }
  }

  /// Load model labels
  static Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString(labelsPath);
      _labels = labelsData.split('\n').where((label) => label.isNotEmpty).toList();
      debugPrint('✅ Loaded ${_labels!.length} labels from file');
    } catch (e) {
      debugPrint('⚠️ Labels file not found, will generate generic labels after model loads: $e');
      _labels = null; // Will be generated after model loads
    }
  }

  /// Generate generic labels based on model output dimensions
  static void _generateGenericLabels() {
    if (_interpreter == null) {
      debugPrint('⚠️ Cannot generate labels: interpreter not available');
      return;
    }

    try {
      // Get the number of output classes from the model
      final outputTensor = _interpreter!.getOutputTensor(0);
      final outputShape = outputTensor.shape;

      // For classification models, the last dimension is usually the number of classes
      final numClasses = outputShape.last;

      // Generate generic labels: Class_0, Class_1, Class_2, etc.
      _labels = List.generate(numClasses, (index) => 'Class_$index');

      debugPrint('📋 Generated ${_labels!.length} generic labels based on model output shape: $outputShape');
      debugPrint('🏷️ Labels: ${_labels!.join(', ')}');
    } catch (e) {
      debugPrint('❌ Failed to generate generic labels: $e');
      // Fallback to minimal generic labels
      _labels = ['Class_0', 'Class_1'];
    }
  }

  /// Print model information
  static void _printModelInfo() {
    if (_interpreter == null) return;

    final inputTensors = _interpreter!.getInputTensors();
    final outputTensors = _interpreter!.getOutputTensors();

    debugPrint('📊 Model Info:');
    debugPrint('  Input tensors: ${inputTensors.length}');
    for (int i = 0; i < inputTensors.length; i++) {
      debugPrint(
          '    Input $i: ${inputTensors[i].shape} (${inputTensors[i].type})');
    }

    debugPrint('  Output tensors: ${outputTensors.length}');
    for (int i = 0; i < outputTensors.length; i++) {
      debugPrint(
          '    Output $i: ${outputTensors[i].shape} (${outputTensors[i].type})');
    }
  }

  /// Check if model is loaded
  static bool get isModelLoaded => _isModelLoaded && _interpreter != null;

  /// Check if service is initialized (even without model)
  static bool get isInitialized => _isInitialized;

  /// Get initialization error message
  static String? get initializationError => _initializationError;

  /// Debug method to check asset availability
  static Future<Map<String, dynamic>> debugAssetAvailability() async {
    debugPrint('🔍 Checking asset availability...');

    final results = <String, dynamic>{
      'modelFound': false,
      'modelSize': 0,
      'labelsFound': false,
      'labelsContent': '',
      'manifestFound': false,
      'modelInManifest': false,
      'allModelAssets': <String>[],
    };

    // Check model file
    try {
      final modelData =
          await rootBundle.load(modelPath);
      results['modelFound'] = true;
      results['modelSize'] = modelData.lengthInBytes;
      debugPrint('✅ Model file found: ${modelData.lengthInBytes} bytes');
    } catch (e) {
      debugPrint('❌ Model file not found: $e');
      debugPrint('🔍 Error details: ${e.toString()}');
    }

    // Check labels file
    try {
      final labelsData =
          await rootBundle.loadString(labelsPath);
      results['labelsFound'] = true;
      results['labelsContent'] = labelsData;
      debugPrint('✅ Labels file found: ${labelsData.length} characters');
      debugPrint('📋 Labels: ${labelsData.replaceAll('\n', ', ')}');
    } catch (e) {
      debugPrint('❌ Labels file not found: $e');
    }

    // Check asset manifest
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final manifest = json.decode(manifestContent) as Map<String, dynamic>;
      results['manifestFound'] = true;

      final modelAssets = manifest.keys
          .where((key) => key.contains(modelPath.split('/').last))
          .toList();
      results['modelInManifest'] = modelAssets.isNotEmpty;
      debugPrint('🔍 Model assets in manifest: $modelAssets');

      final allModelAssets =
          manifest.keys.where((key) => key.contains('models/')).toList();
      results['allModelAssets'] = allModelAssets;
      debugPrint('🔍 All model assets: $allModelAssets');

      // Also check for any assets that might be similar
      final similarAssets = manifest.keys
          .where((key) =>
              key.toLowerCase().contains('apple') ||
              key.toLowerCase().contains('model'))
          .toList();
      debugPrint('🔍 Similar assets: $similarAssets');
    } catch (e) {
      debugPrint('❌ Could not check asset manifest: $e');
    }

    return results;
  }

  /// Check if service can be used (initialized, even without model)
  static bool get canAnalyze => _isInitialized;

  /// Analyze image for plant disease detection
  static Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    if (!_isInitialized) {
      return {
        'success': false,
        'error': 'TensorFlow service not initialized. Please restart the app.',
      };
    }

    if (!isModelLoaded || _interpreter == null) {
      // Provide demo results when model is not available
      debugPrint('🔬 Model not available, providing demo results');
      return _generateDemoResults(imagePath);
    }

    try {
      debugPrint('🔬 Starting TensorFlow analysis: $imagePath');

      // Preprocess image
      final inputData = await _preprocessImage(imagePath);
      if (inputData == null) {
        return {
          'success': false,
          'error': 'Failed to preprocess image',
        };
      }

      // Run inference
      final output = await _runInference(inputData);

      // Post-process results
      final results = _postprocessResults(output);

      debugPrint('✅ TensorFlow analysis completed');

      return {
        'success': true,
        'data': results,
        'analysisMethod': 'tflite_flutter',
      };
    } catch (e) {
      debugPrint('❌ TensorFlow analysis failed: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Dispose resources and cleanup
  static Future<void> dispose() async {
    try {
      _interpreter?.close();
      _interpreter = null;
      _isModelLoaded = false;
      _isInitialized = false;
      _isUsingGPU = false;
      debugPrint('🧹 TensorFlow resources disposed');
    } catch (e) {
      debugPrint('⚠️ Error disposing TensorFlow resources: $e');
    }
  }

  /// Get performance information
  static Map<String, dynamic> getPerformanceInfo() {
    return {
      'isUsingGPU': _isUsingGPU,
      'threadCount': _optimalThreadCount,
      'isModelLoaded': _isModelLoaded,
      'processorCount': Platform.numberOfProcessors,
      'platform': Platform.operatingSystem,
    };
  }

  /// Preprocess image for model input
  static Future<Float32List?> _preprocessImage(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        debugPrint('❌ Failed to decode image');
        return null;
      }

      // Resize to model input size
      final resizedImage = img.copyResize(
        image,
        width: modelInputSize,
        height: modelInputSize,
        interpolation: img.Interpolation.linear,
      );

      // Convert to Float32List and normalize (0-1)
      final inputSize = modelInputSize * modelInputSize * modelChannels;
      final input = Float32List(inputSize);

      int pixelIndex = 0;
      for (int y = 0; y < modelInputSize; y++) {
        for (int x = 0; x < modelInputSize; x++) {
          final pixel = resizedImage.getPixel(x, y);

          // Extract RGB values and normalize to 0-1
          input[pixelIndex++] = pixel.r / 255.0;
          input[pixelIndex++] = pixel.g / 255.0;
          input[pixelIndex++] = pixel.b / 255.0;
        }
      }

      debugPrint('✅ Image preprocessed: ${input.length} values');
      return input;
    } catch (e) {
      debugPrint('❌ Image preprocessing failed: $e');
      return null;
    }
  }

  /// Optimized inference execution
  static Future<List<double>> _runInference(Float32List inputData) async {
    try {
      // Prepare input tensor with proper shape
      final input = inputData.reshape([1, modelInputSize, modelInputSize, modelChannels]);

      // Prepare output tensor
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final outputSize = outputShape.reduce((a, b) => a * b);
      final output = List.filled(outputSize, 0.0).reshape(outputShape);

      // Run inference with performance monitoring
      final stopwatch = Stopwatch()..start();
      _interpreter!.run(input, output);
      stopwatch.stop();

      // Log performance metrics
      final inferenceTime = stopwatch.elapsedMilliseconds;
      debugPrint('⚡ Inference completed in ${inferenceTime}ms using ${_isUsingGPU ? 'GPU' : 'CPU'}');

      // Extract and validate results
      final results = output[0] as List<double>;

      // Validate output
      if (results.any((value) => value.isNaN || value.isInfinite)) {
        debugPrint('⚠️ Invalid inference results detected');
        throw Exception('Invalid inference output');
      }

      debugPrint('🔬 Inference results: ${results.take(5).toList()}... (showing first 5)');
      return results;
    } catch (e) {
      debugPrint('❌ Inference execution failed: $e');
      rethrow;
    }
  }

  /// Post-process model results
  static Map<String, dynamic> _postprocessResults(List<double> rawResults) {
    if (_labels == null || _labels!.isEmpty) {
      return {
        'predictions': [],
        'topPrediction': null,
        'confidence': 0.0,
      };
    }

    // Create predictions with labels and confidence scores
    final predictions = <Map<String, dynamic>>[];
    for (int i = 0; i < rawResults.length && i < _labels!.length; i++) {
      final confidence = rawResults[i];
      final label = _labels![i];

      predictions.add({
        'label': label,
        'confidence': confidence,
        'displayName': _formatLabel(label),
      });
    }

    // Sort by confidence (descending)
    predictions.sort((a, b) =>
        (b['confidence'] as double).compareTo(a['confidence'] as double));

    // Get top prediction
    final topPrediction = predictions.isNotEmpty ? predictions.first : null;

    // Build detectedDiseases list for storage
    List<Map<String, dynamic>> detectedDiseases = [];
    if (predictions.isNotEmpty) {
      for (final pred in predictions) {
        detectedDiseases.add({
          'disease': pred['displayName'],
          'confidence': pred['confidence'],
          'label': pred['label'],
        });
      }
    } else {
      detectedDiseases.add({
        'disease': 'Unknown',
        'confidence': 0.0,
        'label': 'Unknown',
      });
    }

    return {
      'predictions': predictions,
      'topPrediction': topPrediction,
      'confidence': topPrediction?['confidence'] ?? 0.0,
      'isHealthy': topPrediction?['label']?.contains('healthy') ?? false,
      'diseaseDetected': topPrediction != null &&
          !(topPrediction['label']?.contains('healthy') ?? true),
      'detectedDiseases': detectedDiseases,
    };
  }

  /// Format label for display
  static String _formatLabel(String label) {
    // Convert "Apple___Apple_scab" to "Apple Scab"
    return label
        .split('___')
        .last
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  /// Get model labels
  static List<String> get labels => _labels ?? [];

  /// Generate demo results when model is not available
  static Map<String, dynamic> _generateDemoResults(String imagePath) {
    // Use actual labels if available, otherwise generate generic ones
    List<String> availableLabels;

    if (_labels != null && _labels!.isNotEmpty) {
      // Use the actual labels from the model
      availableLabels = _labels!;
    } else {
      // Generate generic labels for demo (simulating a typical classification model)
      availableLabels = List.generate(5, (index) => 'Class_$index');
    }

    final predictions = <Map<String, dynamic>>[];

    // Create predictions for all available labels with pseudo-random but realistic confidences
    for (int i = 0; i < availableLabels.length; i++) {
      final label = availableLabels[i];
      
      // Generate deterministic pseudo-random confidence based on image path and label index
      final seed = (imagePath.hashCode + label.hashCode + i) % 100;
      final baseConfidence = (seed / 100.0) * 0.8 + 0.1; // Range: 0.1 to 0.9
      
      // Apply some variation to make it more realistic
      final variation = ((seed * 3) % 20 - 10) / 100.0; // ±10% variation
      final confidence = (baseConfidence + variation).clamp(0.05, 0.95);

      predictions.add({
        'label': label,
        'confidence': confidence,
        'displayName': _formatLabel(label),
      });
    }

    // Sort by confidence (descending) to simulate real model behavior
    predictions.sort((a, b) =>
        (b['confidence'] as double).compareTo(a['confidence'] as double));

    final topPrediction = predictions.first;

    // Build detectedDiseases list
    final detectedDiseases = predictions.map((pred) => {
      'disease': pred['displayName'],
      'confidence': pred['confidence'],
      'label': pred['label'],
    }).toList();

    // Determine if the top prediction suggests a healthy state
    // This is generic - looks for keywords that might indicate health
    final topLabel = (topPrediction['label'] as String).toLowerCase();
    final isHealthy = topLabel.contains('healthy') ||
                     topLabel.contains('normal') ||
                     topLabel.contains('class_0'); // Often class 0 is healthy in many models

    return {
      'success': true,
      'data': {
        'predictions': predictions,
        'topPrediction': topPrediction,
        'confidence': topPrediction['confidence'],
        'isHealthy': isHealthy,
        'diseaseDetected': !isHealthy,
        'detectedDiseases': detectedDiseases,
        'isDemoResult': true, // Important: mark this as demo data
      },
      'analysisMethod': 'demo_fallback',
    };
  }
}
