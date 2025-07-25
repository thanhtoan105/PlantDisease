import SupabaseService from './SupabaseService';

/**
 * Plant Service - Provides a clean interface for plant-related data operations
 * This service acts as a bridge between the UI components and the database
 */
class PlantService {
	/**
	 * Get all crops for display in lists (HomeTab, CropLibrary)
	 */
	static async getAllCrops() {
		try {
			const crops = await SupabaseService.getAllCrops();
			return {
				success: true,
				data: crops,
			};
		} catch (error) {
			console.error('PlantService - Error fetching crops:', error);
			return {
				success: false,
				error: error.message || 'Failed to fetch crops',
				data: this.getFallbackCrops(), // Fallback to hardcoded data
			};
		}
	}

	/**
	 * Get detailed crop information including diseases and growing conditions
	 */
	static async getCropDetails(cropId) {
		try {
			const cropDetails = await SupabaseService.getCropById(cropId);

			// The SupabaseService now returns enriched data with JSON structure
			// Add fallback data if needed
			const enrichedDetails = {
				...cropDetails,
				// Use database data if available, otherwise fallback to hardcoded
				growingConditions:
					cropDetails.growingConditions ||
					this.getGrowingConditions(cropDetails.name),
				seasons:
					cropDetails.seasons || this.getGrowingSeasons(cropDetails.name),
				tips: cropDetails.growingTips
					? this.extractTipsArray(cropDetails.growingTips)
					: await SupabaseService.getGrowingTips(cropDetails.name),
			};

			return {
				success: true,
				data: enrichedDetails,
			};
		} catch (error) {
			console.error('PlantService - Error fetching crop details:', error);
			return {
				success: false,
				error: error.message || 'Failed to fetch crop details',
				data: this.getFallbackCropDetails(cropId),
			};
		}
	}

	/**
	 * Extract tips array from JSON structure
	 */
	static extractTipsArray(growingTips) {
		if (Array.isArray(growingTips)) return growingTips;

		const tips = [];

		// Extract tips from different sections of the JSON
		if (growingTips.site_selection) {
			Object.values(growingTips.site_selection).forEach((tip) => {
				if (typeof tip === 'string') tips.push(tip);
			});
		}

		if (growingTips.planting) {
			Object.values(growingTips.planting).forEach((tip) => {
				if (typeof tip === 'string') tips.push(tip);
			});
		}

		if (growingTips.watering) {
			Object.values(growingTips.watering).forEach((tip) => {
				if (typeof tip === 'string') tips.push(tip);
			});
		}

		if (growingTips.fertilizing) {
			Object.values(growingTips.fertilizing).forEach((tip) => {
				if (typeof tip === 'string') tips.push(tip);
			});
		}

		if (growingTips.pruning) {
			Object.values(growingTips.pruning).forEach((tip) => {
				if (typeof tip === 'string') tips.push(tip);
			});
		}

		return tips.length > 0 ? tips.slice(0, 5) : [];
	}

	/**
	 * Search for crops
	 */
	static async searchCrops(searchTerm) {
		try {
			const crops = await SupabaseService.searchCrops(searchTerm);
			return {
				success: true,
				data: crops,
			};
		} catch (error) {
			console.error('PlantService - Error searching crops:', error);
			return {
				success: false,
				error: error.message || 'Failed to search crops',
				data: [],
			};
		}
	}

	/**
	 * Search for diseases
	 */
	static async searchDiseases(searchTerm) {
		try {
			const diseases = await SupabaseService.searchDiseases(searchTerm);
			return {
				success: true,
				data: diseases,
			};
		} catch (error) {
			console.error('PlantService - Error searching diseases:', error);
			return {
				success: false,
				error: error.message || 'Failed to search diseases',
				data: [],
			};
		}
	}

	/**
	 * Search all content (crops and diseases)
	 */
	static async searchAll(searchTerm) {
		try {
			const [cropsResult, diseasesResult] = await Promise.all([
				this.searchCrops(searchTerm),
				this.searchDiseases(searchTerm),
			]);

			const allResults = [];

			if (cropsResult.success) {
				allResults.push(...cropsResult.data);
			}

			if (diseasesResult.success) {
				allResults.push(...diseasesResult.data);
			}

			return {
				success: true,
				data: allResults,
			};
		} catch (error) {
			console.error('PlantService - Error searching all:', error);
			return {
				success: false,
				error: error.message || 'Failed to search',
				data: [],
			};
		}
	}

	/**
	 * Get growing conditions for a crop (placeholder - can be moved to database)
	 */
	static getGrowingConditions(cropName) {
		const conditionsMap = {
			'Apple Tree': {
				climate: 'Temperate',
				soil: 'Well-drained, slightly acidic (pH 6.0-7.0)',
				sunlight: 'Full sun (6-8 hours daily)',
				water: 'Regular, deep watering',
				temperature: '15-25°C (59-77°F)',
			},
			Apple: {
				climate: 'Temperate',
				soil: 'Well-drained, slightly acidic (pH 6.0-7.0)',
				sunlight: 'Full sun (6-8 hours daily)',
				water: 'Regular, deep watering',
				temperature: '15-25°C (59-77°F)',
			},
		};

		return (
			conditionsMap[cropName] || {
				climate: 'Varies by variety',
				soil: 'Well-drained, fertile soil',
				sunlight: 'Full sun to partial shade',
				water: 'Regular watering',
				temperature: 'Moderate temperatures',
			}
		);
	}

	/**
	 * Get growing seasons for a crop (placeholder - can be moved to database)
	 */
	static getGrowingSeasons(cropName) {
		const seasonsMap = {
			'Apple Tree': {
				planting: 'Late winter to early spring',
				harvest: 'Late summer to fall',
				duration: '3-5 years to fruit production',
			},
			Apple: {
				planting: 'Late winter to early spring',
				harvest: 'Late summer to fall',
				duration: '3-5 years to fruit production',
			},
		};

		return (
			seasonsMap[cropName] || {
				planting: 'Spring to early summer',
				harvest: 'Varies by crop',
				duration: 'Varies by variety',
			}
		);
	}

	/**
	 * Fallback crops data when database is unavailable
	 */
	static getFallbackCrops() {
		return [
			{
				id: '1',
				name: 'Apple Tree',
				description: 'Popular fruit tree',
				emoji: '🍎',
				diseaseCount: 4,
				scientificName: 'Malus domestica',
			},
			{
				id: 'tomato',
				name: 'Tomato',
				description: 'Common vegetable crop',
				emoji: '🍅',
				diseaseCount: 12,
				scientificName: 'Solanum lycopersicum',
			},
			{
				id: 'potato',
				name: 'Potato',
				description: 'Root vegetable',
				emoji: '🥔',
				diseaseCount: 8,
				scientificName: 'Solanum tuberosum',
			},
			{
				id: 'corn',
				name: 'Corn',
				description: 'Cereal grain',
				emoji: '🌽',
				diseaseCount: 10,
				scientificName: 'Zea mays',
			},
		];
	}

	/**
	 * Fallback crop details when database is unavailable
	 */
	static getFallbackCropDetails(cropId) {
		const fallbackDetails = {
			1: {
				id: '1',
				name: 'Apple Tree',
				scientificName: 'Malus domestica',
				description:
					'Apple trees are deciduous trees in the rose family best known for their sweet, pomaceous fruit, the apple.',
				emoji: '🍎',
				diseases: [
					{
						id: '1',
						name: 'Apple Scab',
						severity: 'High',
						description: 'Fungal disease affecting leaves and fruit',
						symptoms: [
							'Dark spots on leaves',
							'Scabby fruit lesions',
							'Premature leaf drop',
						],
						treatment: 'Apply fungicide spray during growing season',
					},
				],
				growingConditions: this.getGrowingConditions('Apple Tree'),
				seasons: this.getGrowingSeasons('Apple Tree'),
				tips: SupabaseService.getDefaultGrowingTips('Apple Tree'),
			},
		};

		return (
			fallbackDetails[cropId] || {
				id: cropId,
				name: 'Unknown Crop',
				scientificName: 'Not available',
				description: 'Detailed information not available for this crop.',
				emoji: '🌱',
				diseases: [],
				growingConditions: this.getGrowingConditions('Unknown'),
				seasons: this.getGrowingSeasons('Unknown'),
				tips: [],
			}
		);
	}

	/**
	 * Check if the service is properly configured
	 */
	static isConfigured() {
		return SupabaseService.isConfigured();
	}

	/**
	 * Test database connection
	 */
	static async testConnection() {
		return await SupabaseService.testConnection();
	}
}

export default PlantService;
