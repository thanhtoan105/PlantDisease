import { useState, useEffect } from 'react';
import { useTensorflowModel } from 'react-native-fast-tflite';

/**
 * Custom hook for TensorFlow model management with real image processing
 * Based on official react-native-fast-tflite documentation
 */
export const useTensorFlowModel = () => {
  const [error, setError] = useState(null);

  // Use the official hook from react-native-fast-tflite
  const tensorflowModel = useTensorflowModel(
    require('../../assets/apple_model_final.tflite')
  );

  useEffect(() => {
    if (tensorflowModel.state === 'error') {
      setError(tensorflowModel.error);
    } else {
      setError(null);
    }
  }, [tensorflowModel.state, tensorflowModel.error]);

  /**
   * Analyze image using real frame data from Vision Camera
   * This is called from Frame Processor with actual camera frames
   * @param {Object} resizedFrame - Frame from vision-camera-resize-plugin
   * @returns {Object} Analysis results
   */
  const analyzeImageFromFrame = (resizedFrame) => {
    'worklet';
    
    try {
      if (tensorflowModel.state !== 'loaded' || !tensorflowModel.model) {
        console.log('⚠️ Model not loaded yet');
        return {
          success: false,
          error: 'Model not loaded',
          data: null
        };
      }

      console.log('🚀 Running inference with REAL frame data');
      console.log('📊 Frame data type:', typeof resizedFrame);
      console.log('📊 Frame size:', resizedFrame.length || 'unknown');

      // Run the model with real frame data (this is the key part!)
      const outputs = tensorflowModel.model.runSync([resizedFrame]);
      
      console.log('✅ Inference completed with real data');
      console.log('📊 Raw outputs:', outputs);

      // Process results exactly like Python
      const results = processModelOutputs(outputs);
      
      return {
        success: true,
        data: results,
        analysisMethod: 'tensorflow_lite_real_frame'
      };
      
    } catch (error) {
      console.error('❌ Real frame analysis failed:', error);
      return {
        success: false,
        error: error.message,
        data: null
      };
    }
  };

  /**
   * Process model outputs (Python-compatible)
   * @param {Array} outputs - Raw model outputs
   * @returns {Object} Processed results
   */
  const processModelOutputs = (outputs) => {
    'worklet';
    
    try {
      // Extract output data (same as Python: output_data = interpreter.get_tensor(...))
      let outputData = outputs[0];
      
      // Convert to array if needed
      if (!Array.isArray(outputData)) {
        outputData = Array.from(outputData);
      }

      // Python logic: predicted_class_index = np.argmax(output_data)
      let maxValue = -Infinity;
      let predictedClassIndex = 0;
      
      for (let i = 0; i < outputData.length; i++) {
        if (outputData[i] > maxValue) {
          maxValue = outputData[i];
          predictedClassIndex = i;
        }
      }

      // Python logic: confidence = float(np.max(output_data))
      const confidence = maxValue;
      
      // Python class names
      const classNames = [
        'Apple___Apple_scab',
        'Apple___Black_rot', 
        'Apple___Cedar_apple_rust',
        'Apple___healthy'
      ];

      const displayNames = [
        'Apple Scab',
        'Apple Black Rot',
        'Cedar Apple Rust', 
        'Healthy'
      ];

      // Python logic: predicted_class_name = CLASS_NAMES[predicted_class_index]
      const predictedClassName = classNames[predictedClassIndex];
      const predictedDisplayName = displayNames[predictedClassIndex];

      console.log('🎯 REAL DATA PREDICTION:');
      console.log('   - Class Index:', predictedClassIndex);
      console.log('   - Class Name:', predictedClassName);
      console.log('   - Confidence:', confidence);

      // Create detected diseases
      const detectedDiseases = [];
      
      if (predictedClassName !== 'Apple___healthy') {
        detectedDiseases.push({
          id: predictedClassName,
          name: predictedDisplayName,
          className: predictedClassName,
          confidence: confidence,
          severity: confidence > 0.7 ? 'High' : confidence > 0.4 ? 'Medium' : 'Low',
          description: `Detected ${predictedDisplayName} with confidence ${(confidence * 100).toFixed(1)}%`,
        });
      }

      const isHealthy = predictedClassName === 'Apple___healthy';

      return {
        plantType: 'Apple',
        cropId: 1,
        diseases: detectedDiseases,
        healthStatus: isHealthy ? 'Healthy' : 'Diseased',
        overallConfidence: confidence,
        prediction: {
          className: predictedClassName,
          displayName: predictedDisplayName,
          confidence: confidence,
          index: predictedClassIndex,
        },
        allProbabilities: outputData.map((prob, idx) => ({
          className: classNames[idx] || `Class_${idx}`,
          displayName: displayNames[idx] || `Class ${idx}`,
          probability: prob,
          percentage: (prob * 100).toFixed(1) + '%'
        })),
        rawPredictions: Array.from(outputData),
        modelUsed: 'TensorFlow Lite (Real Frame Data)',
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      console.error('❌ Error processing real outputs:', error);
      throw error;
    }
  };

  return {
    // Model state from official hook
    isLoading: tensorflowModel.state === 'loading',
    isLoaded: tensorflowModel.state === 'loaded',
    error: error !== null,
    errorMessage: error,
    model: tensorflowModel.model,
    
    // Real frame analysis function
    analyzeImageFromFrame,
    
    // Model info
    getModelInfo: () => ({
      state: tensorflowModel.state,
      modelPath: require('../../assets/apple_model_final.tflite'),
      inputSize: 128, // Match Python model
      channels: 3,
      supportedClasses: [
        'Apple___Apple_scab',
        'Apple___Black_rot',
        'Apple___Cedar_apple_rust',
        'Apple___healthy',
      ],
    }),
  };
};
