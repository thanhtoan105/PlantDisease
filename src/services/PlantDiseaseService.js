import RNFS from 'react-native-fs';
import DatabaseService from './DatabaseService';
import SupabaseService from './SupabaseService';
import TensorFlowService from './TensorFlowService';

class PlantDiseaseService {
	// Mock disease database for demonstration
	static diseaseDatabase = {
		tomato: [
			{
				id: 'tomato-late-blight',
				name: 'Late Blight',
				confidence: 0.92,
				severity: 'High',
				description:
					'A devastating fungal disease that can destroy entire tomato crops rapidly. Characterized by dark, water-soaked lesions on leaves and fruits.',
				symptoms: [
					'Dark water-soaked lesions on leaves',
					'White mold growth on leaf undersides',
					'Brown spots on stems and fruits',
					'Rapid wilting and plant death',
				],
				treatment: [
					'Apply copper-based fungicides immediately',
					'Remove and destroy all infected plant parts',
					'Improve air circulation around plants',
					'Avoid overhead watering',
					'Use resistant varieties in future plantings',
				],
				prevention: [
					'Plant resistant varieties',
					'Ensure proper spacing for air circulation',
					'Water at soil level, not on leaves',
					'Remove plant debris regularly',
					'Apply preventive fungicide sprays',
				],
			},
			{
				id: 'tomato-early-blight',
				name: 'Early Blight',
				confidence: 0.85,
				severity: 'Moderate',
				description:
					'A common fungal disease affecting tomatoes, causing brown spots with concentric rings on older leaves.',
				symptoms: [
					'Brown spots with concentric rings on leaves',
					'Yellowing of affected leaves',
					'Defoliation starting from bottom leaves',
					'Dark lesions on stems and fruits',
				],
				treatment: [
					'Apply fungicide containing chlorothalonil',
					'Remove affected lower leaves',
					'Improve plant nutrition',
					'Ensure adequate spacing',
				],
				prevention: [
					'Rotate crops annually',
					'Mulch around plants',
					'Water at soil level',
					'Provide adequate nutrition',
				],
			},
		],
		potato: [
			{
				id: 'potato-late-blight',
				name: 'Late Blight',
				confidence: 0.88,
				severity: 'High',
				description:
					'The same pathogen that causes tomato late blight, equally devastating to potato crops.',
				symptoms: [
					'Dark lesions on leaves and stems',
					'White fungal growth on leaf undersides',
					'Brown rot in tubers',
					'Foul smell from infected tubers',
				],
				treatment: [
					'Apply copper-based fungicides',
					'Harvest tubers before disease spreads',
					'Destroy infected plant material',
					'Improve drainage',
				],
				prevention: [
					'Plant certified disease-free seed potatoes',
					'Ensure good drainage',
					'Avoid overhead irrigation',
					'Hill soil around plants properly',
				],
			},
		],
		corn: [
			{
				id: 'corn-rust',
				name: 'Corn Rust',
				confidence: 0.79,
				severity: 'Moderate',
				description:
					'A fungal disease causing orange-red pustules on corn leaves.',
				symptoms: [
					'Orange-red pustules on leaves',
					'Yellowing of affected areas',
					'Reduced plant vigor',
					'Premature leaf death',
				],
				treatment: [
					'Apply fungicide if severe',
					'Remove heavily infected leaves',
					'Ensure adequate nutrition',
					'Monitor weather conditions',
				],
				prevention: [
					'Plant resistant varieties',
					'Ensure proper spacing',
					'Avoid excessive nitrogen',
					'Monitor for early symptoms',
				],
			},
		],
	};

	/**
	 * Analyze plant image for disease detection using TensorFlow Lite
	 * @param {string} imageUri - URI of the image to analyze
	 * @param {string} plantType - Type of plant (optional)
	 * @returns {Promise<Object>} Analysis results
	 */
	static async analyzeImage(imageUri, plantType = null) {
		try {
			console.log('Starting disease analysis with TensorFlow Lite...');
			console.log('Image URI:', imageUri);

			// Validate input
			if (!imageUri || typeof imageUri !== 'string') {
				throw new Error('Invalid image URI provided');
			}

			// Ensure TensorFlow model is loaded
			const modelInfo = TensorFlowService.getModelInfo();
			if (!modelInfo.isLoaded) {
				console.log('Model not loaded, attempting to load...');
				const loaded = await TensorFlowService.loadModel();
				if (!loaded) {
					throw new Error('Failed to load TensorFlow Lite model');
				}
			}

			// Perform TensorFlow Lite analysis
			const tensorflowResult = await TensorFlowService.analyzeImage(imageUri);

			if (!tensorflowResult.success) {
				throw new Error(tensorflowResult.error || 'TensorFlow analysis failed');
			}

			console.log(
				'TensorFlow Lite analysis successful:',
				tensorflowResult.data,
			);

			// Generate recommendations based on TensorFlow results
			const recommendations = this.generateRecommendations(
				tensorflowResult.data.diseases,
				tensorflowResult.data.healthStatus,
			);

			// Enhanced analysis result with database integration
			const enhancedDiseases = [];
			
			// Fetch detailed disease information from database for each detected disease
			if (tensorflowResult.data.diseases && tensorflowResult.data.diseases.length > 0) {
				for (const disease of tensorflowResult.data.diseases) {
					try {
						// Query database for disease details using className
						const dbResult = await DatabaseService.getDiseaseByClassName(disease.className);
						
						if (dbResult.success && dbResult.data) {
							enhancedDiseases.push({
								...disease,
								// Add database information
								description: dbResult.data.description || disease.description,
								treatment: dbResult.data.treatment || disease.treatment,
								databaseInfo: dbResult.data,
								detailedDescription: dbResult.data.description,
								symptoms: dbResult.data.symptoms || [],
								prevention: dbResult.data.prevention || [],
							});
						} else {
							// If not found in database, use TensorFlow predictions
							enhancedDiseases.push(disease);
						}
					} catch (dbError) {
						console.error('Error fetching disease from database:', dbError);
						enhancedDiseases.push(disease);
					}
				}
			}

			// Structure the final result
			const analysisResult = {
				success: true,
				data: {
					imageUri,
					plantType: tensorflowResult.data.plantType || plantType || 'Apple',
					cropId: tensorflowResult.data.cropId || 1,
					diseases: enhancedDiseases,
					healthStatus: tensorflowResult.data.healthStatus,
					confidence: tensorflowResult.data.overallConfidence,
					prediction: tensorflowResult.data.prediction,
					analysisTimestamp:
						tensorflowResult.data.timestamp || new Date().toISOString(),
					recommendations: recommendations,
					analysisMethod: 'tensorflow_lite',
					modelInfo: {
						...TensorFlowService.getModelInfo(),
						modelPath: tensorflowResult.data.modelPath,
					},
					rawPredictions: tensorflowResult.data.rawPredictions,
					enhancedWithDatabase: enhancedDiseases.length > 0,
				},
			};

			console.log('Final analysis result:', analysisResult);
			return analysisResult;
		} catch (error) {
			console.error('TensorFlow analysis error:', error);
			console.error('Error stack:', error.stack);

			// Return detailed error information instead of falling back
			return {
				success: false,
				error: error.message || 'TensorFlow Lite analysis failed',
				errorDetails: {
					message: error.message,
					stack: error.stack,
					imageUri: imageUri,
					timestamp: new Date().toISOString(),
				},
				analysisMethod: 'tensorflow_lite_failed',
			};
		}
	}

	// Removed simulated analysis methods - now using TensorFlow Lite exclusively

	/**
	 * Generate recommendations based on detected diseases
	 * @param {Array} diseases - Detected diseases
	 * @param {string} healthStatus - Overall health status
	 * @returns {Array} Recommendations
	 */
	static generateRecommendations(diseases, healthStatus) {
		const recommendations = [];

		if (healthStatus === 'Healthy') {
			recommendations.push({
				type: 'prevention',
				title: 'Maintain Plant Health',
				description:
					'Continue current care practices. Monitor regularly for early signs of disease.',
				priority: 'low',
			});
		} else {
			// Add treatment recommendations for each disease
			diseases.forEach((disease) => {
				// Get treatment text - handle both string and array formats
				const treatmentText = typeof disease.treatment === 'string' 
					? disease.treatment 
					: (Array.isArray(disease.treatment) && disease.treatment.length > 0) 
						? disease.treatment[0] 
						: 'Apply appropriate treatment based on disease severity';

				if (disease.severity === 'High') {
					recommendations.push({
						type: 'urgent',
						title: `Immediate Treatment for ${disease.name}`,
						description: treatmentText,
						priority: 'high',
					});
				} else {
					recommendations.push({
						type: 'treatment',
						title: `Treatment for ${disease.name}`,
						description: treatmentText,
						priority: 'medium',
					});
				}
			});

			// Add general care recommendation
			recommendations.push({
				type: 'care',
				title: 'Improve Plant Care',
				description:
					'Ensure proper watering, nutrition, and spacing to prevent disease spread.',
				priority: 'medium',
			});
		}

		return recommendations;
	}

	/**
	 * Get detailed information about a specific disease
	 * @param {string} diseaseId - Disease identifier
	 * @returns {Object|null} Disease information
	 */
	static getDiseaseInfo(diseaseId) {
		for (const plantType in this.diseaseDatabase) {
			const disease = this.diseaseDatabase[plantType].find(
				(d) => d.id === diseaseId,
			);
			if (disease) {
				return disease;
			}
		}
		return null;
	}

	/**
	 * Get all diseases for a specific plant type
	 * @param {string} plantType - Plant type
	 * @returns {Array} List of diseases
	 */
	static getDiseasesForPlant(plantType) {
		return this.diseaseDatabase[plantType] || [];
	}

	/**
	 * Save analysis result to local storage
	 * @param {Object} analysisResult - Analysis result to save
	 * @returns {Promise<boolean>} Success status
	 */
	static async saveAnalysisResult(analysisResult) {
		try {
			const savedResults = await this.getSavedResults();
			const newResult = {
				id: Date.now().toString(),
				...analysisResult,
				savedAt: new Date().toISOString(),
			};

			savedResults.unshift(newResult);

			// Keep only last 50 results
			const trimmedResults = savedResults.slice(0, 50);

			const filePath =
				RNFS.DocumentDirectoryPath + '/plant_analysis_results.json';
			await RNFS.writeFile(filePath, JSON.stringify(trimmedResults), 'utf8');

			return true;
		} catch (error) {
			console.error('Error saving analysis result:', error);
			return false;
		}
	}

	/**
	 * Get saved analysis results
	 * @returns {Promise<Array>} Saved results
	 */
	static async getSavedResults() {
		try {
			const filePath =
				RNFS.DocumentDirectoryPath + '/plant_analysis_results.json';
			const fileExists = await RNFS.exists(filePath);

			if (fileExists) {
				const content = await RNFS.readFile(filePath, 'utf8');
				return JSON.parse(content);
			}

			return [];
		} catch (error) {
			console.error('Error reading saved results:', error);
			return [];
		}
	}

	/**
	 * DATABASE INTEGRATION METHODS
	 */

	/**
	 * Get all crops from database
	 * @returns {Promise<Object>} Crops data
	 */
	static async getAllCropsFromDB() {
		try {
			if (!SupabaseService.isConfigured()) {
				console.warn('Database not configured, using mock data');
				return {
					success: true,
					data: [
						{ id: 1, name: 'Apple Tree', scientific_name: 'Malus domestica' },
					],
				};
			}

			return await DatabaseService.getAllCrops();
		} catch (error) {
			console.error('Error fetching crops from database:', error);
			return {
				success: false,
				error: error.message || 'Failed to fetch crops',
			};
		}
	}

	/**
	 * Get all diseases from database
	 * @returns {Promise<Object>} Diseases data
	 */
	static async getAllDiseasesFromDB() {
		try {
			if (!SupabaseService.isConfigured()) {
				console.warn('Database not configured, using mock data');
				return {
					success: true,
					data: Object.values(this.diseaseDatabase).flat(),
				};
			}

			return await DatabaseService.getAllDiseases();
		} catch (error) {
			console.error('Error fetching diseases from database:', error);
			return {
				success: false,
				error: error.message || 'Failed to fetch diseases',
			};
		}
	}

	/**
	 * Get diseases by crop ID from database
	 * @param {number} cropId - Crop ID
	 * @returns {Promise<Object>} Diseases data
	 */
	static async getDiseasesByCropFromDB(cropId) {
		try {
			if (!SupabaseService.isConfigured()) {
				console.warn('Database not configured, using mock data');
				return {
					success: true,
					data: this.diseaseDatabase['tomato'] || [],
				};
			}

			return await DatabaseService.getDiseasesByCropId(cropId);
		} catch (error) {
			console.error('Error fetching diseases by crop from database:', error);
			return {
				success: false,
				error: error.message || 'Failed to fetch diseases for crop',
			};
		}
	}

	/**
	 * Search diseases in database
	 * @param {string} searchTerm - Search term
	 * @returns {Promise<Object>} Search results
	 */
	static async searchDiseasesInDB(searchTerm) {
		try {
			if (!SupabaseService.isConfigured()) {
				console.warn('Database not configured, using mock search');
				const allDiseases = Object.values(this.diseaseDatabase).flat();
				const filtered = allDiseases.filter(
					(disease) =>
						disease.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
						disease.description
							.toLowerCase()
							.includes(searchTerm.toLowerCase()),
				);
				return {
					success: true,
					data: filtered,
				};
			}

			return await DatabaseService.searchDiseases(searchTerm);
		} catch (error) {
			console.error('Error searching diseases in database:', error);
			return {
				success: false,
				error: error.message || 'Failed to search diseases',
			};
		}
	}

	/**
	 * Get disease by class name from database
	 * @param {string} className - Disease class name
	 * @returns {Promise<Object>} Disease data
	 */
	static async getDiseaseByClassNameFromDB(className) {
		try {
			if (!SupabaseService.isConfigured()) {
				console.warn('Database not configured, using mock data');
				// Try to find in mock data
				const allDiseases = Object.values(this.diseaseDatabase).flat();
				const disease = allDiseases.find((d) => d.id === className);
				return {
					success: true,
					data: disease || null,
				};
			}

			return await DatabaseService.getDiseaseByClassName(className);
		} catch (error) {
			console.error(
				'Error fetching disease by class name from database:',
				error,
			);
			return {
				success: false,
				error: error.message || 'Failed to fetch disease',
			};
		}
	}

	/**
	 * Enhanced analysis with database integration
	 * @param {string} imageUri - URI of the image to analyze
	 * @param {string} plantType - Type of plant (optional)
	 * @returns {Promise<Object>} Analysis results with database info
	 */
	static async analyzeImageWithDB(imageUri, plantType = null) {
		try {
			// First, perform the regular analysis
			const analysisResult = await this.analyzeImage(imageUri, plantType);

			if (!analysisResult.success) {
				return analysisResult;
			}

			// If database is configured, enhance results with database info
			if (
				SupabaseService.isConfigured() &&
				analysisResult.detectedDiseases.length > 0
			) {
				const enhancedDiseases = [];

				for (const disease of analysisResult.detectedDiseases) {
					// Try to get detailed info from database
					const dbResult = await this.getDiseaseByClassNameFromDB(disease.id);

					if (dbResult.success && dbResult.data) {
						enhancedDiseases.push({
							...disease,
							databaseInfo: dbResult.data,
							treatment: dbResult.data.treatment,
							detailedDescription: dbResult.data.description,
						});
					} else {
						enhancedDiseases.push(disease);
					}
				}

				return {
					...analysisResult,
					detectedDiseases: enhancedDiseases,
					enhancedWithDatabase: true,
				};
			}

			return analysisResult;
		} catch (error) {
			console.error('Error in enhanced analysis:', error);
			return {
				success: false,
				error: error.message || 'Analysis failed',
			};
		}
	}
}

export default PlantDiseaseService;
