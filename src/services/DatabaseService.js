import { supabase } from './SupabaseService';

class DatabaseService {
	/**
	 * CROPS OPERATIONS
	 */

	/**
	 * Get all crops
	 */
	static async getAllCrops() {
		try {
			if (!supabase) {
				throw new Error('Supabase not configured');
			}

			// Schema is configured in Supabase client
			const { data, error } = await supabase
				.from('crops')
				.select('*')
				.order('name');

			if (error) throw error;

			return {
				success: true,
				data: data || [],
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to fetch crops',
			};
		}
	}

	/**
	 * Get crop by ID
	 */
	static async getCropById(id) {
		try {
			if (!supabase) {
				throw new Error('Supabase not configured');
			}

			const { data, error } = await supabase
				.from('crops')
				.select('*')
				.eq('id', id)
				.single();

			if (error) throw error;

			return {
				success: true,
				data,
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to fetch crop',
			};
		}
	}

	/**
	 * Add new crop
	 */
	static async addCrop(cropData) {
		try {
			if (!supabase) {
				throw new Error('Supabase not configured');
			}

			const { data, error } = await supabase
				.from('crops')
				.insert([cropData])
				.select()
				.single();

			if (error) throw error;

			return {
				success: true,
				data,
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to add crop',
			};
		}
	}

	/**
	 * DISEASES OPERATIONS
	 */

	/**
	 * Get all diseases
	 */
	static async getAllDiseases() {
		try {
			if (!supabase) {
				throw new Error('Supabase not configured');
			}

			const { data, error } = await supabase
				.from('diseases')
				.select(
					`
          *,
          crops (
            id,
            name,
            scientific_name
          )
        `,
				)
				.order('display_name');

			if (error) throw error;

			return {
				success: true,
				data: data || [],
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to fetch diseases',
			};
		}
	}

	/**
	 * Get diseases by crop ID
	 */
	static async getDiseasesByCropId(cropId) {
		try {
			if (!supabase) {
				throw new Error('Supabase not configured');
			}

			const { data, error } = await supabase
				.from('diseases')
				.select(
					`
          *,
          crops (
            id,
            name,
            scientific_name
          )
        `,
				)
				.eq('crop_id', cropId)
				.order('display_name');

			if (error) throw error;

			return {
				success: true,
				data: data || [],
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to fetch diseases for crop',
			};
		}
	}

	/**
	 * Get disease by class name
	 */
	static async getDiseaseByClassName(className) {
		try {
			if (!supabase) {
				throw new Error('Supabase not configured');
			}

			const { data, error } = await supabase
				.from('diseases')
				.select(
					`
          *,
          crops (
            id,
            name,
            scientific_name
          )
        `,
				)
				.eq('class_name', className)
				.single();

			if (error) throw error;

			return {
				success: true,
				data,
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to fetch disease',
			};
		}
	}

	/**
	 * Search diseases by name or description
	 */
	static async searchDiseases(searchTerm) {
		try {
			if (!supabase) {
				throw new Error('Supabase not configured');
			}

			const { data, error } = await supabase
				.from('diseases')
				.select(
					`
          *,
          crops (
            id,
            name,
            scientific_name
          )
        `,
				)
				.or(
					`display_name.ilike.%${searchTerm}%,description.ilike.%${searchTerm}%`,
				)
				.order('display_name');

			if (error) throw error;

			return {
				success: true,
				data: data || [],
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to search diseases',
			};
		}
	}

	/**
	 * Add new disease
	 */
	static async addDisease(diseaseData) {
		try {
			if (!supabase) {
				throw new Error('Supabase not configured');
			}

			const { data, error } = await supabase
				.from('diseases')
				.insert([diseaseData])
				.select(
					`
          *,
          crops (
            id,
            name,
            scientific_name
          )
        `,
				)
				.single();

			if (error) throw error;

			return {
				success: true,
				data,
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to add disease',
			};
		}
	}

	/**
	 * Update disease
	 */
	static async updateDisease(id, diseaseData) {
		try {
			if (!supabase) {
				throw new Error('Supabase not configured');
			}

			const { data, error } = await supabase
				.from('diseases')
				.update(diseaseData)
				.eq('id', id)
				.select(
					`
          *,
          crops (
            id,
            name,
            scientific_name
          )
        `,
				)
				.single();

			if (error) throw error;

			return {
				success: true,
				data,
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to update disease',
			};
		}
	}

	/**
	 * USERS OPERATIONS (for future authentication)
	 */

	/**
	 * Get user by username
	 */
	static async getUserByUsername(username) {
		try {
			if (!supabase) {
				throw new Error('Supabase not configured');
			}

			const { data, error } = await supabase
				.from('users')
				.select('*')
				.eq('username', username)
				.single();

			if (error) throw error;

			return {
				success: true,
				data,
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to fetch user',
			};
		}
	}

	/**
	 * Create new user
	 */
	static async createUser(userData) {
		try {
			if (!supabase) {
				throw new Error('Supabase not configured');
			}

			const { data, error } = await supabase
				.from('users')
				.insert([
					{
						...userData,
						created_at: new Date().toISOString(),
					},
				])
				.select()
				.single();

			if (error) throw error;

			return {
				success: true,
				data,
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to create user',
			};
		}
	}
}

export default DatabaseService;
