/**
 * Integration tests for TensorFlow Lite implementation
 * Tests the complete flow from image analysis to structured results
 */

import TensorFlowService from '../services/TensorFlowService';
import PlantDiseaseService from '../services/PlantDiseaseService';

// Mock react-native-fast-tflite
jest.mock('react-native-fast-tflite', () => ({
	loadTensorflowModel: jest.fn(),
}));

describe('TensorFlow Lite Integration Tests', () => {
	beforeEach(() => {
		jest.clearAllMocks();
		TensorFlowService.model = null;
		TensorFlowService.isModelLoaded = false;
	});

	describe('Apple Disease Classification', () => {
		it('should correctly classify Apple Scab', async () => {
			const { loadTensorflowModel } = require('react-native-fast-tflite');
			
			// Mock model loading and inference
			const mockModel = {
				run: jest.fn().mockResolvedValue([0.85, 0.1, 0.03, 0.02])
			};
			loadTensorflowModel.mockResolvedValue(mockModel);

			const result = await PlantDiseaseService.analyzeImage('test://image.jpg');

			expect(result.success).toBe(true);
			expect(result.data.prediction.className).toBe('Apple___Apple_scab');
			expect(result.data.prediction.displayName).toBe('Apple Scab');
			expect(result.data.diseases).toHaveLength(1);
			expect(result.data.diseases[0].className).toBe('Apple___Apple_scab');
			expect(result.data.healthStatus).toBe('Diseased');
		});

		it('should correctly classify Apple Black Rot', async () => {
			const { loadTensorflowModel } = require('react-native-fast-tflite');
			
			const mockModel = {
				run: jest.fn().mockResolvedValue([0.1, 0.8, 0.05, 0.05])
			};
			loadTensorflowModel.mockResolvedValue(mockModel);

			const result = await PlantDiseaseService.analyzeImage('test://image.jpg');

			expect(result.success).toBe(true);
			expect(result.data.prediction.className).toBe('Apple___Black_rot');
			expect(result.data.prediction.displayName).toBe('Apple Black Rot');
			expect(result.data.diseases[0].className).toBe('Apple___Black_rot');
		});

		it('should correctly classify Cedar Apple Rust', async () => {
			const { loadTensorflowModel } = require('react-native-fast-tflite');
			
			const mockModel = {
				run: jest.fn().mockResolvedValue([0.05, 0.1, 0.8, 0.05])
			};
			loadTensorflowModel.mockResolvedValue(mockModel);

			const result = await PlantDiseaseService.analyzeImage('test://image.jpg');

			expect(result.success).toBe(true);
			expect(result.data.prediction.className).toBe('Apple___Cedar_apple_rust');
			expect(result.data.prediction.displayName).toBe('Cedar Apple Rust');
			expect(result.data.diseases[0].className).toBe('Apple___Cedar_apple_rust');
		});

		it('should correctly identify healthy apples', async () => {
			const { loadTensorflowModel } = require('react-native-fast-tflite');
			
			const mockModel = {
				run: jest.fn().mockResolvedValue([0.05, 0.05, 0.05, 0.85])
			};
			loadTensorflowModel.mockResolvedValue(mockModel);

			const result = await PlantDiseaseService.analyzeImage('test://image.jpg');

			expect(result.success).toBe(true);
			expect(result.data.prediction.className).toBe('Apple___healthy');
			expect(result.data.prediction.displayName).toBe('Healthy');
			expect(result.data.diseases).toHaveLength(0);
			expect(result.data.healthStatus).toBe('Healthy');
		});
	});

	describe('Error Handling', () => {
		it('should handle model loading failures', async () => {
			const { loadTensorflowModel } = require('react-native-fast-tflite');
			loadTensorflowModel.mockRejectedValue(new Error('Model loading failed'));

			const result = await PlantDiseaseService.analyzeImage('test://image.jpg');

			expect(result.success).toBe(false);
			expect(result.error).toContain('Model loading failed');
		});

		it('should handle inference failures', async () => {
			const { loadTensorflowModel } = require('react-native-fast-tflite');
			
			const mockModel = {
				run: jest.fn().mockRejectedValue(new Error('Inference failed'))
			};
			loadTensorflowModel.mockResolvedValue(mockModel);

			const result = await PlantDiseaseService.analyzeImage('test://image.jpg');

			expect(result.success).toBe(false);
			expect(result.error).toContain('Inference failed');
		});

		it('should handle invalid image URIs', async () => {
			const result = await PlantDiseaseService.analyzeImage(null);

			expect(result.success).toBe(false);
			expect(result.error).toContain('Invalid image URI');
		});
	});

	describe('Result Structure', () => {
		it('should return properly structured results', async () => {
			const { loadTensorflowModel } = require('react-native-fast-tflite');
			
			const mockModel = {
				run: jest.fn().mockResolvedValue([0.7, 0.2, 0.05, 0.05])
			};
			loadTensorflowModel.mockResolvedValue(mockModel);

			const result = await PlantDiseaseService.analyzeImage('test://image.jpg');

			expect(result.success).toBe(true);
			expect(result.data).toHaveProperty('imageUri');
			expect(result.data).toHaveProperty('plantType');
			expect(result.data).toHaveProperty('cropId');
			expect(result.data).toHaveProperty('diseases');
			expect(result.data).toHaveProperty('healthStatus');
			expect(result.data).toHaveProperty('confidence');
			expect(result.data).toHaveProperty('prediction');
			expect(result.data).toHaveProperty('analysisTimestamp');
			expect(result.data).toHaveProperty('recommendations');
			expect(result.data).toHaveProperty('analysisMethod');
			expect(result.data).toHaveProperty('modelInfo');
			expect(result.data).toHaveProperty('rawPredictions');

			// Check prediction structure
			expect(result.data.prediction).toHaveProperty('className');
			expect(result.data.prediction).toHaveProperty('displayName');
			expect(result.data.prediction).toHaveProperty('confidence');
			expect(result.data.prediction).toHaveProperty('index');

			// Check disease structure (if any)
			if (result.data.diseases.length > 0) {
				expect(result.data.diseases[0]).toHaveProperty('id');
				expect(result.data.diseases[0]).toHaveProperty('name');
				expect(result.data.diseases[0]).toHaveProperty('className');
				expect(result.data.diseases[0]).toHaveProperty('confidence');
				expect(result.data.diseases[0]).toHaveProperty('severity');
				expect(result.data.diseases[0]).toHaveProperty('description');
			}
		});
	});
});
