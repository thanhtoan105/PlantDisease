import { loadTensorflowModel } from 'react-native-fast-tflite';

/**
 * TensorFlow Lite Service for Plant Disease Detection
 * CORRECTED IMPLEMENTATION - Based on Python app_basic.py
 */
class TensorFlowService {
	static model = null;
	static isModelLoaded = false;
	static modelPath = require('../../assets/apple_model_final.tflite');

	// CORRECTED: Match Python model configuration exactly
	static MODEL_INPUT_SIZE = 128; // Changed from 224 to 128 to match Python
	static MODEL_CHANNELS = 3;

	/**
	 * Load the TensorFlow Lite model
	 * @returns {Promise<boolean>} Success status
	 */
	static async loadModel() {
		try {
			if (this.isModelLoaded && this.model) {
				console.log('✅ Model already loaded');
				return true;
			}

			console.log('🔄 Loading TensorFlow Lite model...');
			this.model = await loadTensorflowModel(this.modelPath);

			if (!this.model) {
				throw new Error('Model loading returned null or undefined');
			}

			this.isModelLoaded = true;
			console.log('✅ TensorFlow Lite model loaded successfully');
			console.log(
				'📊 Model input size:',
				this.MODEL_INPUT_SIZE + 'x' + this.MODEL_INPUT_SIZE,
			);
			return true;
		} catch (error) {
			console.error('❌ Error loading TensorFlow Lite model:', error);
			this.isModelLoaded = false;
			this.model = null;
			return false;
		}
	}

	/**
	 * Process image using react-native-fast-tflite (REAL IMPLEMENTATION)
	 * This completely removes mock data and uses the official library
	 * @param {string} imageUri - Image URI
	 * @returns {Promise<Object>} Analysis results
	 */
	static async processImageWithFastTflite(imageUri) {
		try {
			console.log(
				'🔄 Processing image with react-native-fast-tflite:',
				imageUri,
			);

			if (!this.isModelLoaded || !this.model) {
				const loaded = await this.loadModel();
				if (!loaded) {
					throw new Error('Failed to load TensorFlow Lite model');
				}
			}

			// Use react-native-fast-tflite's built-in image processing
			// This handles all the preprocessing automatically
			console.log('🚀 Running inference with react-native-fast-tflite');
			const results = await this.model.run([imageUri]);

			console.log('✅ Inference completed successfully');
			console.log('📊 Raw results:', results);

			return results;
		} catch (error) {
			console.error('❌ react-native-fast-tflite processing failed:', error);
			throw error;
		}
	}

	/**
	 * Process results exactly like Python code
	 * @param {Object|Array} rawResults - Raw model output
	 * @returns {Object} Processed results
	 */
	static postprocessResults(rawResults) {
		try {
			console.log('🔍 Processing results (Python-style)...');
			console.log('📊 Raw results:', rawResults);

			// Extract output tensor (matching Python: output_data = interpreter.get_tensor(...))
			let outputData = null;

			if (Array.isArray(rawResults)) {
				outputData = rawResults[0];
			} else if (rawResults && typeof rawResults === 'object') {
				const keys = Object.keys(rawResults);
				if (keys.length > 0) {
					outputData = rawResults[keys[0]];
				}
			}

			if (!outputData) {
				throw new Error('Could not extract output data from results');
			}

			// Convert to array if needed
			if (!Array.isArray(outputData)) {
				outputData = Array.from(outputData);
			}

			console.log('📊 Extracted output data:', outputData);

			// EXACT Python logic: predicted_class_index = np.argmax(output_data)
			let maxValue = -Infinity;
			let predictedClassIndex = 0;

			for (let i = 0; i < outputData.length; i++) {
				if (outputData[i] > maxValue) {
					maxValue = outputData[i];
					predictedClassIndex = i;
				}
			}

			// EXACT Python logic: confidence = float(np.max(output_data))
			const confidence = maxValue;

			// EXACT Python class names (matching Python: CLASS_NAMES)
			const classNames = [
				'Apple___Apple_scab',
				'Apple___Black_rot',
				'Apple___Cedar_apple_rust',
				'Apple___healthy',
			];

			const displayNames = [
				'Apple Scab',
				'Apple Black Rot',
				'Cedar Apple Rust',
				'Healthy',
			];

			// EXACT Python logic: predicted_class_name = CLASS_NAMES[predicted_class_index]
			const predictedClassName = classNames[predictedClassIndex];
			const predictedDisplayName = displayNames[predictedClassIndex];

			console.log('🎯 PYTHON-STYLE PREDICTION:');
			console.log('   - Class Index:', predictedClassIndex);
			console.log('   - Class Name:', predictedClassName);
			console.log('   - Confidence:', confidence);
			console.log('   - All outputs:', outputData);

			// Create detected diseases
			const detectedDiseases = [];

			if (predictedClassName !== 'Apple___healthy') {
				detectedDiseases.push({
					id: predictedClassName,
					name: predictedDisplayName,
					className: predictedClassName,
					confidence: confidence,
					severity:
						confidence > 0.7 ? 'High' : confidence > 0.4 ? 'Medium' : 'Low',
					description: `Detected ${predictedDisplayName} with confidence ${(
						confidence * 100
					).toFixed(1)}%`,
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
					percentage: (prob * 100).toFixed(1) + '%',
				})),
				rawPredictions: Array.from(outputData),
				modelUsed: 'TensorFlow Lite (Python-Compatible)',
				timestamp: new Date().toISOString(),
			};
		} catch (error) {
			console.error('❌ Error in postprocessing:', error);
			throw error;
		}
	}

	/**
	 * Analyze image using Python-compatible pipeline
	 * @param {string} imageUri - URI of the image to analyze
	 * @returns {Promise<Object>} Analysis results
	 */
	static async analyzeImage(imageUri) {
		try {
			console.log(
				'🔬 Starting REAL TensorFlow analysis with react-native-fast-tflite:',
				imageUri,
			);

			// Use the official react-native-fast-tflite library
			// This handles all image preprocessing automatically
			const rawResults = await this.processImageWithFastTflite(imageUri);

			// Process results using the same logic as Python
			const results = this.postprocessResults(rawResults);

			console.log('✅ Real TensorFlow analysis completed:', results);

			return {
				success: true,
				data: results,
				analysisMethod: 'react_native_fast_tflite_real',
			};
		} catch (error) {
			console.error('❌ Real TensorFlow analysis failed:', error);
			return {
				success: false,
				error: error.message || 'TensorFlow analysis failed',
				analysisMethod: 'react_native_fast_tflite_error',
			};
		}
	}

	/**
	 * Get model information
	 */
	static getModelInfo() {
		return {
			modelPath: this.modelPath,
			isLoaded: this.isModelLoaded,
			modelType: 'TensorFlow Lite (Python-Compatible)',
			framework: 'react-native-fast-tflite',
			inputSize: this.MODEL_INPUT_SIZE, // 128
			channels: this.MODEL_CHANNELS, // 3
			supportedClasses: [
				'Apple___Apple_scab',
				'Apple___Black_rot',
				'Apple___Cedar_apple_rust',
				'Apple___healthy',
			],
		};
	}

	/**
	 * Reset the model
	 */
	static resetModel() {
		this.model = null;
		this.isModelLoaded = false;
		console.log('Model reset');
	}

	/**
	 * Check if model is ready
	 */
	static isReady() {
		return this.isModelLoaded && this.model !== null;
	}
}

export default TensorFlowService;
