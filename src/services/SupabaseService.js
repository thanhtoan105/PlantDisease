// Import polyfills first for Hermes compatibility
import '../utils/polyfills';
import { createClient } from '@supabase/supabase-js';
import { SUPABASE_URL, SUPABASE_ANON_KEY } from '@env';

// Direct configuration - using the values from your .env file
const supabaseUrl = SUPABASE_URL;
const supabaseAnonKey = SUPABASE_ANON_KEY;

// Debug logging to check if environment variables are loaded
console.log('🔍 Environment Variables Debug:');
console.log('SUPABASE_URL:', supabaseUrl);
console.log(
	'SUPABASE_ANON_KEY:',
	supabaseAnonKey ? 'Present (hidden for security)' : 'Missing',
);

// Validate required environment variables
if (!supabaseUrl || !supabaseAnonKey) {
	console.warn(
		'⚠️ Supabase configuration missing!\n' +
			'📝 Please add SUPABASE_URL and SUPABASE_ANON_KEY to your .env file.\n' +
			'🔗 Get these from your Supabase project dashboard: https://supabase.com/dashboard\n' +
			'📄 Check the README.md for detailed setup instructions.',
	);
}

// Create Supabase client with Hermes-compatible configuration
export const supabase =
	supabaseUrl && supabaseAnonKey
		? createClient(supabaseUrl, supabaseAnonKey, {
				db: {
					schema: 'plant_disease',
				},
				auth: {
					storage: require('@react-native-async-storage/async-storage').default,
					autoRefreshToken: true,
					persistSession: true,
					detectSessionInUrl: false,
				},
				global: {
					fetch: fetch.bind(globalThis),
				},
		  })
		: null;

class SupabaseService {
	/**
	 * Check if Supabase is properly configured
	 */
	static isConfigured() {
		return supabase !== null;
	}

	/**
	 * Test database connection
	 */
	static async testConnection() {
		if (!this.isConfigured()) {
			return {
				success: false,
				error:
					'Supabase not configured. Please check your environment variables.',
			};
		}

		try {
			// Test connection by querying crops table (schema is configured in client)
			const { data, error } = await supabase
				.from('crops')
				.select('count')
				.limit(1);

			if (error) {
				return {
					success: false,
					error: `Database connection failed: ${error.message}. Make sure the plant_disease schema exists and contains the crops table.`,
				};
			}

			return {
				success: true,
				message: 'Database connection successful',
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to connect to database',
			};
		}
	}

	/**
	 * Get all crops with disease count
	 */
	static async getAllCrops() {
		if (!this.isConfigured()) {
			throw new Error('Supabase not configured');
		}

		try {
			const { data, error } = await supabase
				.from('crops')
				.select(
					`
					id,
					name,
					scientific_name,
					description,
					image_url,
					diseases:diseases(count)
				`,
				)
				.order('name');

			if (error) throw error;

			// Transform data to match UI expectations
			return data.map((crop) => ({
				id: crop.id.toString(),
				name: crop.name,
				scientificName: crop.scientific_name,
				description: this.extractDescription(crop.description),
				emoji: this.getCropEmoji(crop.name),
				diseaseCount: crop.diseases?.[0]?.count || 0,
				image_url: crop.image_url,
			}));
		} catch (error) {
			console.error('Error fetching crops:', error);
			throw error;
		}
	}

	/**
	 * Extract description from JSON or return fallback
	 */
	static extractDescription(description) {
		if (!description) return 'No description available';

		// If it's already a string, return it
		if (typeof description === 'string') return description;

		// If it's JSON, try to extract meaningful description
		try {
			if (description.overview?.description) {
				return description.overview.description;
			}
			if (description.legacy_description) {
				return description.legacy_description;
			}
			return 'No description available';
		} catch (error) {
			return 'No description available';
		}
	}

	/**
	 * Get crop details by ID with enhanced JSON data
	 */
	static async getCropById(cropId) {
		if (!this.isConfigured()) {
			throw new Error('Supabase not configured');
		}

		try {
			// Get basic crop data with diseases
			const { data, error } = await supabase
				.from('crops')
				.select(
					`
					id,
					name,
					scientific_name,
					description,
					image_url,
					diseases:diseases(
						id,
						class_name,
						display_name,
						description,
						treatment,
						image_url
					)
				`,
				)
				.eq('id', cropId)
				.single();

			if (error) throw error;

			// Get overview data using the new function
			const { data: overviewData, error: overviewError } = await supabase.rpc(
				'get_crop_overview',
				{ crop_id: parseInt(cropId) },
			);

			// Get growing tips using the new function
			const { data: tipsData, error: tipsError } = await supabase.rpc(
				'get_crop_growing_tips',
				{ crop_id: parseInt(cropId) },
			);

			// Transform data to match UI expectations
			const result = {
				id: data.id.toString(),
				name: data.name,
				scientificName: data.scientific_name,
				description: this.extractDescription(data.description),
				emoji: this.getCropEmoji(data.name),
				image_url: data.image_url,
				diseases:
					data.diseases?.map((disease) => ({
						id: disease.id.toString(),
						name: disease.display_name,
						display_name: disease.display_name,
						className: disease.class_name,
						description: disease.description || 'No description available',
						treatment:
							disease.treatment || 'No treatment information available',
						image_url: disease.image_url,
						severity: this.getDiseaseServerity(disease.display_name),
						symptoms: this.getDefaultSymptoms(disease.display_name),
					})) || [],
			};

			// Add overview data if available
			if (overviewData && overviewData.length > 0 && overviewData[0].overview) {
				result.overview = overviewData[0].overview;

				// Extract growing conditions from overview
				if (result.overview.growing_conditions) {
					result.growingConditions = this.transformGrowingConditions(
						result.overview.growing_conditions,
					);
				}

				// Extract seasons from overview
				if (result.overview.growing_season) {
					result.seasons = this.transformGrowingSeasons(
						result.overview.growing_season,
					);
				}
			}

			// Add growing tips if available
			if (tipsData && tipsData.length > 0 && tipsData[0].growing_tips) {
				result.growingTips = tipsData[0].growing_tips;
			}

			return result;
		} catch (error) {
			console.error('Error fetching crop details:', error);
			throw error;
		}
	}

	/**
	 * Search crops by term
	 */
	static async searchCrops(searchTerm) {
		if (!this.isConfigured()) {
			throw new Error('Supabase not configured');
		}

		try {
			const { data, error } = await supabase.rpc('search_crops', {
				search_term: searchTerm,
			});

			if (error) throw error;

			return data.map((crop) => ({
				id: crop.id.toString(),
				name: crop.name,
				scientificName: crop.scientific_name,
				description: this.extractDescription(crop.description),
				emoji: this.getCropEmoji(crop.name),
				diseaseCount: crop.disease_count || 0,
				image_url: crop.image_url,
				type: 'crop',
			}));
		} catch (error) {
			console.error('Error searching crops:', error);
			throw error;
		}
	}

	/**
	 * Search diseases by term
	 */
	static async searchDiseases(searchTerm) {
		if (!this.isConfigured()) {
			throw new Error('Supabase not configured');
		}

		try {
			const { data, error } = await supabase.rpc('search_diseases', {
				search_term: searchTerm,
			});

			if (error) throw error;

			return data.map((disease) => ({
				id: disease.id.toString(),
				name: disease.display_name,
				className: disease.class_name,
				description: disease.description || 'No description available',
				treatment: disease.treatment || 'No treatment information available',
				cropName: disease.crop_name,
				cropScientificName: disease.crop_scientific_name,
				severity: this.getDiseaseServerity(disease.display_name),
				symptoms: this.getDefaultSymptoms(disease.display_name),
				type: 'disease',
				affectedCrops: [disease.crop_name],
			}));
		} catch (error) {
			console.error('Error searching diseases:', error);
			throw error;
		}
	}

	/**
	 * Get growing tips for a crop using database function
	 */
	static async getGrowingTips(cropName) {
		if (!this.isConfigured()) {
			return this.getDefaultGrowingTips(cropName);
		}

		try {
			// Try to find crop by name and get tips
			const { data: cropData } = await supabase
				.from('crops')
				.select('id')
				.eq('name', cropName)
				.single();

			if (cropData) {
				const { data: tipsData } = await supabase.rpc('get_crop_growing_tips', {
					crop_id: cropData.id,
				});

				if (tipsData && tipsData.length > 0 && tipsData[0].growing_tips) {
					return this.extractTipsFromJSON(tipsData[0].growing_tips);
				}
			}
		} catch (error) {
			console.log('Using fallback tips for', cropName);
		}

		return this.getDefaultGrowingTips(cropName);
	}

	/**
	 * Transform growing conditions from JSON to UI format
	 */
	static transformGrowingConditions(growingConditions) {
		if (!growingConditions) return {};

		return {
			climate: growingConditions.climate || 'Varies by variety',
			soil: growingConditions.soil_type || 'Well-drained, fertile soil',
			sunlight: growingConditions.sunlight || 'Full sun to partial shade',
			water: growingConditions.water_requirements || 'Regular watering',
			temperature: growingConditions.temperature || 'Moderate temperatures',
			spacing: growingConditions.spacing || 'Follow variety guidelines',
		};
	}

	/**
	 * Transform growing seasons from JSON to UI format
	 */
	static transformGrowingSeasons(growingSeason) {
		if (!growingSeason) return {};

		return {
			planting: growingSeason.planting_time || 'Spring to early summer',
			harvest: growingSeason.harvest_time || 'Varies by crop',
			duration: growingSeason.first_harvest || 'Varies by variety',
			blooming: growingSeason.blooming_period || 'Spring',
		};
	}

	/**
	 * Extract tips from JSON structure
	 */
	static extractTipsFromJSON(growingTips) {
		if (!growingTips) return [];

		const tips = [];

		// Extract tips from different sections
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

		return tips.length > 0
			? tips.slice(0, 5)
			: this.getDefaultGrowingTips('Apple Tree');
	}

	/**
	 * Get crop emoji based on name
	 */
	static getCropEmoji(cropName) {
		const emojiMap = {
			'Apple Tree': '🍎',
			Apple: '🍎',
			Tomato: '🍅',
			Potato: '🥔',
			Corn: '🌽',
			Maize: '🌽',
			Wheat: '🌾',
			Rice: '🌾',
			Grape: '🍇',
			Orange: '🍊',
			Lemon: '🍋',
			Banana: '🍌',
			Strawberry: '🍓',
			Cherry: '🍒',
			Peach: '🍑',
			Pear: '🍐',
			Pineapple: '🍍',
			Watermelon: '🍉',
			Carrot: '🥕',
			Pepper: '🌶️',
			Cucumber: '🥒',
			Eggplant: '🍆',
			Broccoli: '🥦',
			Cabbage: '🥬',
			Lettuce: '🥬',
			Spinach: '🥬',
		};
		return emojiMap[cropName] || '🌱';
	}

	/**
	 * Get disease severity based on name (placeholder logic)
	 */
	static getDiseaseServerity(diseaseName) {
		const highSeverityKeywords = ['blight', 'rot', 'wilt', 'canker', 'rust'];
		const moderateSeverityKeywords = ['spot', 'mildew', 'scab', 'smut'];

		const lowerName = diseaseName.toLowerCase();

		if (lowerName.includes('healthy')) return 'Low';

		if (highSeverityKeywords.some((keyword) => lowerName.includes(keyword))) {
			return 'High';
		}

		if (
			moderateSeverityKeywords.some((keyword) => lowerName.includes(keyword))
		) {
			return 'Moderate';
		}

		return 'Moderate';
	}

	/**
	 * Get default symptoms based on disease name (placeholder logic)
	 */
	static getDefaultSymptoms(diseaseName) {
		const symptomsMap = {
			'Apple Scab': [
				'Dark spots on leaves',
				'Scabby fruit lesions',
				'Premature leaf drop',
			],
			'Apple Black Rot': [
				'Frogeye spots on leaves',
				'Black fruit rot',
				'Cankers on branches',
			],
			'Cedar Apple Rust': [
				'Orange spots on leaves',
				'Galls on cedar trees',
				'Leaf distortion',
			],
			Healthy: ['No visible symptoms', 'Normal leaf color', 'Healthy growth'],
		};

		return (
			symptomsMap[diseaseName] || [
				'Consult plant pathologist for detailed symptoms',
			]
		);
	}

	/**
	 * Get default growing tips based on crop name
	 */
	static getDefaultGrowingTips(cropName) {
		const tipsMap = {
			'Apple Tree': [
				'Prune annually for good air circulation',
				'Thin fruits for better quality',
				'Apply dormant oil in late winter',
				'Choose disease-resistant varieties',
				'Mulch around base but not touching trunk',
			],
			Apple: [
				'Prune annually for good air circulation',
				'Thin fruits for better quality',
				'Apply dormant oil in late winter',
				'Choose disease-resistant varieties',
				'Mulch around base but not touching trunk',
			],
		};

		return (
			tipsMap[cropName] || [
				'Provide adequate sunlight and water',
				'Use well-draining soil',
				'Monitor for pests and diseases regularly',
				'Follow proper spacing guidelines',
				'Apply organic fertilizer as needed',
			]
		);
	}

	/**
	 * Initialize database schema
	 */
	static async initializeSchema() {
		if (!this.isConfigured()) {
			throw new Error('Supabase not configured');
		}

		try {
			// Create a crop table
			const { error: cropsError } = await supabase.rpc('create_crops_table');
			if (cropsError && !cropsError.message.includes('already exists')) {
				throw cropsError;
			}

			// Create a disease table
			const { error: diseasesError } = await supabase.rpc(
				'create_diseases_table',
			);
			if (diseasesError && !diseasesError.message.includes('already exists')) {
				throw diseasesError;
			}

			// Create a users' table
			const { error: usersError } = await supabase.rpc('create_users_table');
			if (usersError && !usersError.message.includes('already exists')) {
				throw usersError;
			}

			return {
				success: true,
				message: 'Database schema initialized successfully',
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to initialize database schema',
			};
		}
	}

	/**
	 * Insert initial data
	 */
	static async insertInitialData() {
		if (!this.isConfigured()) {
			throw new Error('Supabase not configured');
		}

		try {
			// Insert crops data
			const { error: cropError } = await supabase
				.from('crops')
				.upsert([
					{ id: 1, name: 'Apple Tree', scientific_name: 'Malus domestica' },
				]);

			if (cropError) throw cropError;

			// Insert diseases data
			const { error: diseaseError } = await supabase.from('diseases').upsert([
				{
					id: 101,
					crop_id: 1,
					class_name: 'Apple___Apple_scab',
					display_name: 'Apple Scab',
					description:
						'Caused by the fungus *Venturia inaequalis*. Symptoms include olive-green or brown spots on leaves and fruit, which later become black and scabby.',
					treatment: null,
				},
				{
					id: 102,
					crop_id: 1,
					class_name: 'Apple___Black_rot',
					display_name: 'Apple Black Rot',
					description:
						'Caused by the fungus *Botryosphaeria obtusa*. On leaves, it creates "frogeye" spots with a tan center. On fruit, it causes a black, firm rot that spreads rapidly.',
					treatment: null,
				},
				{
					id: 103,
					crop_id: 1,
					class_name: 'Apple___Cedar_apple_rust',
					display_name: 'Cedar Apple Rust',
					description:
						'Caused by the fungus *Gymnosporangium juniperi-virginianae*. On apple leaves, it creates small, yellow spots that enlarge and turn bright orange with black spots in the center.',
					treatment: null,
				},
				{
					id: 104,
					crop_id: 1,
					class_name: 'Apple___healthy',
					display_name: 'Healthy',
					description:
						'The leaf shows no visible signs of common diseases. The surface is green, with no spots, distortions, or unusual discoloration.',
					treatment: null,
				},
			]);

			if (diseaseError) throw diseaseError;

			return {
				success: true,
				message: 'Initial data inserted successfully',
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to insert initial data',
			};
		}
	}
}

export default SupabaseService;
