import TensorFlowService from '../services/TensorFlowService';

// Mock the react-native-fast-tflite plugin
jest.mock('react-native-fast-tflite', () => ({
	TensorflowPlugin: {
		loadModel: jest.fn(),
		runInference: jest.fn(),
	},
}));

describe('TensorFlowService', () => {
	beforeEach(() => {
		// Reset the service state before each test
		TensorFlowService.model = null;
		TensorFlowService.isModelLoaded = false;
		jest.clearAllMocks();
	});

	describe('loadModel', () => {
		it('should load the model successfully', async () => {
			const { TensorflowPlugin } = require('react-native-fast-tflite');
			TensorflowPlugin.loadModel.mockResolvedValue('mock-model');

			const result = await TensorFlowService.loadModel();

			expect(result).toBe(true);
			expect(TensorFlowService.isModelLoaded).toBe(true);
			expect(TensorFlowService.model).toBe('mock-model');
			expect(TensorflowPlugin.loadModel).toHaveBeenCalledWith(
				'apple_model_final.tflite',
			);
		});

		it('should handle model loading errors', async () => {
			const { TensorflowPlugin } = require('react-native-fast-tflite');
			TensorflowPlugin.loadModel.mockRejectedValue(
				new Error('Model loading failed'),
			);

			const result = await TensorFlowService.loadModel();

			expect(result).toBe(false);
			expect(TensorFlowService.isModelLoaded).toBe(false);
			expect(TensorFlowService.model).toBe(null);
		});

		it('should return true if model is already loaded', async () => {
			TensorFlowService.model = 'existing-model';
			TensorFlowService.isModelLoaded = true;

			const result = await TensorFlowService.loadModel();

			expect(result).toBe(true);
			expect(TensorflowPlugin.loadModel).not.toHaveBeenCalled();
		});
	});

	describe('runInference', () => {
		it('should run inference successfully', async () => {
			const { TensorflowPlugin } = require('react-native-fast-tflite');
			const mockResults = [0.1, 0.8, 0.05, 0.05]; // Mock classification results

			TensorflowPlugin.loadModel.mockResolvedValue('mock-model');
			TensorflowPlugin.runInference.mockResolvedValue(mockResults);

			const result = await TensorFlowService.runInference('test-image-uri');

			expect(result.plantType).toBe('Apple');
			expect(result.overallConfidence).toBeGreaterThan(0);
			expect(result.modelUsed).toBe('TensorFlow Lite');
			expect(result.rawOutput).toEqual(mockResults);
		});

		it('should load model if not already loaded', async () => {
			const { TensorflowPlugin } = require('react-native-fast-tflite');
			const mockResults = [0.9, 0.05, 0.03, 0.02];

			TensorflowPlugin.loadModel.mockResolvedValue('mock-model');
			TensorflowPlugin.runInference.mockResolvedValue(mockResults);

			await TensorFlowService.runInference('test-image-uri');

			expect(TensorflowPlugin.loadModel).toHaveBeenCalled();
			expect(TensorflowPlugin.runInference).toHaveBeenCalledWith(
				'mock-model',
				'test-image-uri',
			);
		});

		it('should handle inference errors', async () => {
			const { TensorflowPlugin } = require('react-native-fast-tflite');
			TensorflowPlugin.loadModel.mockRejectedValue(
				new Error('Model loading failed'),
			);

			await expect(
				TensorFlowService.runInference('test-image-uri'),
			).rejects.toThrow();
		});
	});

	describe('analyzeImage', () => {
		it('should analyze image successfully', async () => {
			const { TensorflowPlugin } = require('react-native-fast-tflite');
			const mockResults = [0.1, 0.8, 0.05, 0.05];

			TensorflowPlugin.loadModel.mockResolvedValue('mock-model');
			TensorflowPlugin.runInference.mockResolvedValue(mockResults);

			const result = await TensorFlowService.analyzeImage('test-image-uri');

			expect(result.success).toBe(true);
			expect(result.data.plantType).toBe('Apple');
			expect(result.analysisMethod).toBe('tensorflow_lite');
		});

		it('should handle analysis errors gracefully', async () => {
			const { TensorflowPlugin } = require('react-native-fast-tflite');
			TensorflowPlugin.loadModel.mockRejectedValue(
				new Error('Analysis failed'),
			);

			const result = await TensorFlowService.analyzeImage('test-image-uri');

			expect(result.success).toBe(false);
			expect(result.error).toContain('Analysis failed');
			expect(result.analysisMethod).toBe('tensorflow_lite');
		});
	});

	describe('postprocessResults', () => {
		it('should postprocess Apple Scab classification correctly', () => {
			const rawResults = [0.8, 0.1, 0.05, 0.05]; // Apple Scab has highest probability

			const result = TensorFlowService.postprocessResults(rawResults);

			expect(result.plantType).toBe('Apple');
			expect(result.cropId).toBe(1);
			expect(result.diseases).toHaveLength(1);
			expect(result.diseases[0].name).toBe('Apple Scab');
			expect(result.diseases[0].className).toBe('Apple___Apple_scab');
			expect(result.diseases[0].confidence).toBe(0.8);
			expect(result.healthStatus).toBe('Diseased');
			expect(result.prediction.className).toBe('Apple___Apple_scab');
			expect(result.prediction.displayName).toBe('Apple Scab');
		});

		it('should identify healthy plants correctly', () => {
			const rawResults = [0.05, 0.05, 0.05, 0.85]; // Healthy has highest probability

			const result = TensorFlowService.postprocessResults(rawResults);

			expect(result.plantType).toBe('Apple');
			expect(result.cropId).toBe(1);
			expect(result.diseases).toHaveLength(0);
			expect(result.healthStatus).toBe('Healthy');
			expect(result.prediction.className).toBe('Apple___healthy');
			expect(result.prediction.displayName).toBe('Healthy');
		});

		it('should handle invalid results', () => {
			expect(() => TensorFlowService.postprocessResults(null)).toThrow();
			expect(() => TensorFlowService.postprocessResults('invalid')).toThrow();
		});
	});

	describe('getModelInfo', () => {
		it('should return correct model information', () => {
			TensorFlowService.isModelLoaded = true;

			const info = TensorFlowService.getModelInfo();

			expect(info.modelPath).toBe('apple_model_final.tflite');
			expect(info.isLoaded).toBe(true);
			expect(info.modelType).toBe('TensorFlow Lite');
			expect(info.framework).toBe('react-native-fast-tflite');
		});
	});

	describe('unloadModel', () => {
		it('should unload the model', async () => {
			TensorFlowService.model = 'mock-model';
			TensorFlowService.isModelLoaded = true;

			await TensorFlowService.unloadModel();

			expect(TensorFlowService.model).toBe(null);
			expect(TensorFlowService.isModelLoaded).toBe(false);
		});
	});
});
