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

  // Model configuration from centralized config
  static const int modelInputSize = AIModelConfig.inputImageSize;
  static const int modelChannels = AIModelConfig.modelChannels;
  static const String modelPath = AIModelConfig.modelPath;
  static const String labelsPath = AIModelConfig.labelsPath;

  /// Initialize TensorFlow Lite model
  static Future<bool> initialize() async {
    try {
      debugPrint('🔬 Initializing TensorFlow Lite model...');
      _isInitialized = true;
      _initializationError = null;

      // Check if model file exists first with detailed debugging
      try {
        debugPrint('🔍 Attempting to load model from: $modelPath');
        final modelData =
            await rootBundle.load(modelPath);
        debugPrint(
            '📊 Model file found, size: ${modelData.lengthInBytes} bytes');

        // Verify the model data is valid
        if (modelData.lengthInBytes < 1000) {
          throw Exception('Model file too small, might be corrupted');
        }

        debugPrint('✅ Model file validation passed');
      } catch (e) {
        debugPrint('❌ Model file loading failed: $e');
        debugPrint('🔍 Error type: ${e.runtimeType}');
        debugPrint(
            '⚠️ Model file not found or corrupted. Please ensure tomato_model_final.tflite is in assets/models/');
        debugPrint('📖 See assets/models/README.md for setup instructions');

        // Try to list available assets for debugging
        try {
          final manifestContent =
              await rootBundle.loadString('AssetManifest.json');
          debugPrint('📋 Available assets: $manifestContent');
        } catch (manifestError) {
          debugPrint('⚠️ Could not load asset manifest: $manifestError');
        }

        _initializationError =
            'Model file not found. Please rebuild the app after ensuring the model file is in assets/models/';
        _isModelLoaded = false;
        await _loadLabels(); // Still load labels for UI
        return true; // Return true to allow app to continue
      }

      // Create interpreter options for better compatibility
      final options = InterpreterOptions();

      // Try to use GPU delegate if available (optional)
      try {
        if (Platform.isAndroid) {
          options.addDelegate(GpuDelegateV2());
          debugPrint('🚀 GPU delegate added for Android');
        }
      } catch (e) {
        debugPrint('⚠️ GPU delegate not available, using CPU: $e');
      }

      // Set number of threads for CPU execution
      options.threads = 4;

      // Load the model with options
      try {
        _interpreter = await Interpreter.fromAsset(
          modelPath,
          options: options,
        );
        debugPrint('✅ Interpreter created with GPU delegate');
      } catch (e) {
        debugPrint('⚠️ GPU delegate failed, trying CPU only: $e');
        // Fallback to CPU-only execution
        final cpuOptions = InterpreterOptions();
        cpuOptions.threads = 2;
        _interpreter = await Interpreter.fromAsset(
          modelPath,
          options: cpuOptions,
        );
        debugPrint('✅ Interpreter created with CPU only');
      }

      // Load labels if available
      await _loadLabels();

      _isModelLoaded = true;
      debugPrint('✅ TensorFlow model loaded successfully');

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

  /// Load model labels
  static Future<void> _loadLabels() async {
    try {
      final labelsData =
          await rootBundle.loadString(labelsPath);
      _labels =
          labelsData.split('\n').where((label) => label.isNotEmpty).toList();
      debugPrint('✅ Loaded ${_labels!.length} labels');
    } catch (e) {
      debugPrint('⚠️ Labels file not found, using default labels');
      // Default labels for apple diseases (matching React Native)
      _labels = [
        'Apple___Apple_scab',
        'Apple___Black_rot',
        'Apple___Cedar_apple_rust',
        'Apple___healthy',
      ];
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

  /// Run model inference
  static Future<List<double>> _runInference(Float32List inputData) async {
    // Reshape input data for the model
    final input =
        inputData.reshape([1, modelInputSize, modelInputSize, modelChannels]);

    // Prepare output tensor
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    final output = List.filled(outputShape.reduce((a, b) => a * b), 0.0)
        .reshape(outputShape);

    // Run inference
    _interpreter!.run(input, output);

    // Extract results
    final results = output[0] as List<double>;
    debugPrint('🔬 Raw inference results: $results');

    return results;
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
    // Simulate analysis based on image name or random selection
    final fileName = imagePath.split('/').last.toLowerCase();

    // Default to healthy with some randomness
    String predictedClass = 'Apple___healthy';
    double confidence = 0.85;

    // Check filename for disease indicators
    if (fileName.contains('scab')) {
      predictedClass = 'Apple___Apple_scab';
      confidence = 0.78;
    } else if (fileName.contains('rot') || fileName.contains('black')) {
      predictedClass = 'Apple___Black_rot';
      confidence = 0.82;
    } else if (fileName.contains('rust') || fileName.contains('cedar')) {
      predictedClass = 'Apple___Cedar_apple_rust';
      confidence = 0.75;
    }

    // Create demo predictions
    final predictions = [
      {
        'label': predictedClass,
        'confidence': confidence,
        'displayName': _formatLabel(predictedClass),
      },
      {
        'label': 'Apple___healthy',
        'confidence': predictedClass == 'Apple___healthy' ? 0.15 : 0.92,
        'displayName': 'Healthy',
      },
    ];

    // Sort by confidence
    predictions.sort((a, b) =>
        (b['confidence'] as double).compareTo(a['confidence'] as double));

    final topPrediction = predictions.first;

    return {
      'success': true,
      'data': {
        'predictions': predictions,
        'topPrediction': topPrediction,
        'confidence': topPrediction['confidence'],
        'isHealthy':
            (topPrediction['label'] as String?)?.contains('healthy') ?? false,
        'diseaseDetected':
            !((topPrediction['label'] as String?)?.contains('healthy') ?? true),
        'isDemoResult': true,
      },
      'analysisMethod': 'demo_fallback',
    };
  }

  /// Dispose resources
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
    _isInitialized = false;
    _initializationError = null;
    _labels = null;
  }
}
