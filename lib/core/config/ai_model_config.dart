/// Configuration constants for AI model processing
class AIModelConfig {
  AIModelConfig._();

  /// The model input image size (width and height in pixels)
  /// Change this single value to update the processing size throughout the app
  static const int inputImageSize = 224;

  /// Image quality for JPEG compression (0-100)
  static const int imageQuality = 100;

  /// Model channels (RGB = 3)
  static const int modelChannels = 3;

  /// Path to TensorFlow Lite model file
  static const String modelPath = 'assets/models/tomato_model_final.tflite';

  /// Path to model labels file
  static const String labelsPath = 'assets/models/labels.txt';
}
