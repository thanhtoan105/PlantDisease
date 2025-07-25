import PlantDiseaseService from '../services/PlantDiseaseService';
import TensorFlowService from '../services/TensorFlowService';

// Mock dependencies
jest.mock('../services/TensorFlowService');
jest.mock('react-native-fs', () => ({
	DocumentDirectoryPath: '/mock/documents',
	exists: jest.fn(),
	readFile: jest.fn(),
	writeFile: jest.fn(),
}));

describe('PlantDiseaseService', () => {
	beforeEach(() => {
		jest.clearAllMocks();
	});

	describe('analyzeImage', () => {
		it('should use TensorFlow Lite analysis successfully', async () => {
			const mockTensorFlowResult = {
				success: true,
				data: {
					plantType: 'Apple',
					diseases: [
						{
							id: 'apple_scab',
							name: 'Apple Scab',
							confidence: 0.85,
							severity: 'High',
						},
					],
					healthStatus: 'Diseased',
					overallConfidence: 0.85,
				},
			};

			TensorFlowService.analyzeImage.mockResolvedValue(mockTensorFlowResult);
			TensorFlowService.getModelInfo.mockReturnValue({
				modelPath: 'apple_model_final.tflite',
				isLoaded: true,
			});

			const result = await PlantDiseaseService.analyzeImage('test-image-uri', 'Apple');

			expect(result.success).toBe(true);
			expect(result.data.analysisMethod).toBe('tensorflow_lite');
			expect(result.data.plantType).toBe('Apple');
			expect(result.data.diseases).toHaveLength(1);
			expect(result.data.diseases[0].name).toBe('Apple Scab');
			expect(result.data.modelInfo).toBeDefined();
			expect(TensorFlowService.analyzeImage).toHaveBeenCalledWith('test-image-uri');
		});

		it('should fallback to simulated analysis when TensorFlow fails', async () => {
			const mockTensorFlowResult = {
				success: false,
				error: 'Model loading failed',
			};

			TensorFlowService.analyzeImage.mockResolvedValue(mockTensorFlowResult);

			const result = await PlantDiseaseService.analyzeImage('test-image-uri', 'Apple');

			expect(result.success).toBe(true);
			expect(result.data.analysisMethod).toBe('simulated_fallback');
			expect(result.data.fallbackReason).toBe('Model loading failed');
			expect(result.data.plantType).toBeDefined();
		});

		it('should handle complete analysis failure', async () => {
			TensorFlowService.analyzeImage.mockRejectedValue(new Error('Complete failure'));

			// Mock the simulateAIAnalysis to also fail
			const originalSimulate = PlantDiseaseService.simulateAIAnalysis;
			PlantDiseaseService.simulateAIAnalysis = jest.fn().mockRejectedValue(new Error('Simulation failed'));

			const result = await PlantDiseaseService.analyzeImage('test-image-uri');

			expect(result.success).toBe(false);
			expect(result.error).toBe('Failed to analyze image. Please try again.');

			// Restore original method
			PlantDiseaseService.simulateAIAnalysis = originalSimulate;
		});
	});

	describe('saveAnalysisResult', () => {
		it('should save analysis result successfully', async () => {
			const RNFS = require('react-native-fs');
			RNFS.exists.mockResolvedValue(false);
			RNFS.writeFile.mockResolvedValue();

			const analysisResult = {
				plantType: 'Apple',
				diseases: [],
				healthStatus: 'Healthy',
			};

			const result = await PlantDiseaseService.saveAnalysisResult(analysisResult);

			expect(result).toBe(true);
			expect(RNFS.writeFile).toHaveBeenCalled();
		});

		it('should handle save errors', async () => {
			const RNFS = require('react-native-fs');
			RNFS.exists.mockRejectedValue(new Error('File system error'));

			const analysisResult = {
				plantType: 'Apple',
				diseases: [],
				healthStatus: 'Healthy',
			};

			const result = await PlantDiseaseService.saveAnalysisResult(analysisResult);

			expect(result).toBe(false);
		});
	});

	describe('getSavedResults', () => {
		it('should retrieve saved results successfully', async () => {
			const RNFS = require('react-native-fs');
			const mockResults = [
				{
					id: '1',
					plantType: 'Apple',
					diseases: [],
					healthStatus: 'Healthy',
				},
			];

			RNFS.exists.mockResolvedValue(true);
			RNFS.readFile.mockResolvedValue(JSON.stringify(mockResults));

			const results = await PlantDiseaseService.getSavedResults();

			expect(results).toEqual(mockResults);
			expect(RNFS.readFile).toHaveBeenCalledWith('/mock/documents/plant_analysis_results.json', 'utf8');
		});

		it('should return empty array when no saved results exist', async () => {
			const RNFS = require('react-native-fs');
			RNFS.exists.mockResolvedValue(false);

			const results = await PlantDiseaseService.getSavedResults();

			expect(results).toEqual([]);
		});

		it('should handle read errors', async () => {
			const RNFS = require('react-native-fs');
			RNFS.exists.mockResolvedValue(true);
			RNFS.readFile.mockRejectedValue(new Error('Read error'));

			const results = await PlantDiseaseService.getSavedResults();

			expect(results).toEqual([]);
		});
	});

	describe('generateRecommendations', () => {
		it('should generate recommendations for diseased plants', () => {
			const diseases = [
				{
					id: 'apple_scab',
					name: 'Apple Scab',
					severity: 'High',
				},
			];

			const recommendations = PlantDiseaseService.generateRecommendations(diseases, 'Diseased');

			expect(recommendations).toBeInstanceOf(Array);
			expect(recommendations.length).toBeGreaterThan(0);
			expect(recommendations[0]).toHaveProperty('type');
			expect(recommendations[0]).toHaveProperty('title');
			expect(recommendations[0]).toHaveProperty('description');
		});

		it('should generate recommendations for healthy plants', () => {
			const recommendations = PlantDiseaseService.generateRecommendations([], 'Healthy');

			expect(recommendations).toBeInstanceOf(Array);
			expect(recommendations.length).toBeGreaterThan(0);
			expect(recommendations.some(r => r.type === 'prevention')).toBe(true);
		});
	});

	describe('simulateAIAnalysis', () => {
		it('should simulate analysis with random results', async () => {
			const result = await PlantDiseaseService.simulateAIAnalysis('test-image-uri', 'Apple');

			expect(result).toHaveProperty('plantType');
			expect(result).toHaveProperty('diseases');
			expect(result).toHaveProperty('healthStatus');
			expect(result).toHaveProperty('overallConfidence');
			expect(result).toHaveProperty('recommendations');
			expect(result.plantType).toBe('Apple');
		});

		it('should detect plant type when not provided', async () => {
			const result = await PlantDiseaseService.simulateAIAnalysis('test-image-uri');

			expect(result.plantType).toBeDefined();
			expect(['Apple', 'Tomato', 'Potato', 'Corn', 'Grape']).toContain(result.plantType);
		});
	});
});
