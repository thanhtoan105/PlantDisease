import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TensorFlowService {
  static Interpreter? _interpreter;
  static bool _isModelLoaded = false;
  static List<String>? _labels;

  // Model configuration matching React Native
  static const int modelInputSize = 128;
  static const int modelChannels = 3;
  static const String modelPath = 'assets/models/apple_model_final.tflite';
  static const String labelsPath = 'assets/models/labels.txt';

  /// Initialize TensorFlow Lite model
  static Future<bool> initialize() async {
    try {
      debugPrint('🔬 Initializing TensorFlow Lite model...');

      // Check if model file exists first
      try {
        final modelData =
            await rootBundle.load('assets/models/apple_model_final.tflite');
        debugPrint(
            '📊 Model file found, size: ${modelData.lengthInBytes} bytes');
      } catch (e) {
        debugPrint(
            '⚠️ Model file not found. Please add apple_model_final.tflite to assets/models/');
        debugPrint('📖 See assets/models/README.md for setup instructions');
        // Return true to allow app to continue without AI functionality
        _isModelLoaded = false;
        await _loadLabels(); // Still load labels for UI
        return true;
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
          'assets/models/apple_model_final.tflite',
          options: options,
        );
        debugPrint('✅ Interpreter created with GPU delegate');
      } catch (e) {
        debugPrint('⚠️ GPU delegate failed, trying CPU only: $e');
        // Fallback to CPU-only execution
        final cpuOptions = InterpreterOptions();
        cpuOptions.threads = 2;
        _interpreter = await Interpreter.fromAsset(
          'assets/models/apple_model_final.tflite',
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
      _isModelLoaded = false;
      await _loadLabels(); // Still load labels for UI
      return true; // Return true to allow app to continue
    }
  }

  /// Load model labels
  static Future<void> _loadLabels() async {
    try {
      final labelsData =
          await rootBundle.loadString('assets/models/labels.txt');
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

  /// Analyze image for plant disease detection
  static Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    if (!isModelLoaded || _interpreter == null) {
      return {
        'success': false,
        'error':
            'AI model not available. Please add the model file to continue.',
      };
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

    return {
      'predictions': predictions,
      'topPrediction': topPrediction,
      'confidence': topPrediction?['confidence'] ?? 0.0,
      'isHealthy': topPrediction?['label']?.contains('healthy') ?? false,
      'diseaseDetected': topPrediction != null &&
          !(topPrediction['label']?.contains('healthy') ?? true),
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

  /// Dispose resources
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
    _labels = null;
  }
}
