# TensorFlow Lite Models

This directory should contain the TensorFlow Lite model files for plant disease detection.

## Required Files

1. **apple_model_final.tflite** - The main TensorFlow Lite model file
   - Input size: 128x128x3 (RGB images)
   - Output: Probability scores for each disease class

2. **labels.txt** - Text file containing class labels (already included)
   - One label per line
   - Should match the model's output classes

## Model Setup

To use your own model:

1. Convert your trained model to TensorFlow Lite format
2. Place the `.tflite` file in this directory
3. Update the labels.txt file with your model's classes
4. Update the model path in `lib/core/services/tensorflow_service.dart` if needed

## Model Requirements

- Input format: Float32 normalized to [0, 1]
- Input shape: [1, 128, 128, 3]
- Output format: Float32 probability scores
- Output shape: [1, num_classes]

## Example Model Training

The model should be trained to classify plant diseases. Common classes include:
- Healthy plants
- Various disease types (scab, rot, rust, etc.)
- Different plant species (apple, tomato, potato, etc.)

For best results, train with diverse datasets including:
- Different lighting conditions
- Various backgrounds
- Multiple angles and distances
- Different disease severities
