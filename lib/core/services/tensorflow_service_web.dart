import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../config/ai_model_config.dart';

class TensorFlowService {
  static bool _isInitialized = false;
  static List<String>? _labels;
  static String? _initializationError;

  static const int modelInputSize = AIModelConfig.inputImageSize;
  static const int modelChannels = AIModelConfig.modelChannels;
  static const String modelPath = AIModelConfig.modelPath;
  static const String labelsPath = AIModelConfig.labelsPath;

  static Future<bool> initialize() async {
    _isInitialized = true;
    _initializationError =
        'TensorFlow Lite inference is not supported on Flutter Web yet.';
    await _loadLabels();
    debugPrint(_initializationError);
    return true;
  }

  static bool get isModelLoaded => false;

  static bool get isInitialized => _isInitialized;

  static String? get initializationError => _initializationError;

  static bool get canAnalyze => _isInitialized;

  static List<String> get labels => _labels ?? const [];

  static Future<Map<String, dynamic>> debugAssetAvailability() async {
    final results = <String, dynamic>{
      'modelFound': false,
      'modelSize': 0,
      'labelsFound': false,
      'labelsContent': '',
      'manifestFound': false,
      'modelInManifest': false,
      'allModelAssets': <String>[],
      'webInferenceSupported': false,
    };

    try {
      final modelData = await rootBundle.load(modelPath);
      results['modelFound'] = true;
      results['modelSize'] = modelData.lengthInBytes;
    } catch (_) {
      results['modelFound'] = false;
    }

    try {
      final labelsData = await rootBundle.loadString(labelsPath);
      results['labelsFound'] = true;
      results['labelsContent'] = labelsData;
    } catch (_) {
      results['labelsFound'] = false;
    }

    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final manifest = json.decode(manifestContent) as Map<String, dynamic>;
      results['manifestFound'] = true;

      final allModelAssets =
          manifest.keys.where((key) => key.contains('models/')).toList();
      results['allModelAssets'] = allModelAssets;
      results['modelInManifest'] = allModelAssets.contains(modelPath);
    } catch (_) {
      results['manifestFound'] = false;
    }

    return results;
  }

  static Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    if (!_isInitialized) {
      await initialize();
    }

    return {
      'success': false,
      'error': 'TensorFlow Lite inference is not supported on Flutter Web yet.',
      'analysisMethod': 'web_unsupported',
      'requiresWebInference': true,
    };
  }

  static Future<void> dispose() async {
    _isInitialized = false;
    _labels = null;
    _initializationError = null;
  }

  static Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString(labelsPath);
      _labels = labelsData
          .split('\n')
          .map((label) => label.trim())
          .where((label) => label.isNotEmpty)
          .toList();
    } catch (_) {
      _labels = const [];
    }
  }
}
