import { supabase } from './SupabaseService';
import AsyncStorage from '@react-native-async-storage/async-storage';

class AuthService {
	/**
	 * Sign up with email and password
	 */
	static async signUp(email, password, userData = {}) {
		try {
			if (!supabase) {
				throw new Error('Supabase not configured');
			}

			const { data, error } = await supabase.auth.signUp({
				email,
				password,
				options: {
					data: {
						username: userData.username || email.split('@')[0],
						phone: userData.phone || null,
					},
				},
			});

			if (error) throw error;

			// If user is created, create profile
			if (data.user) {
				await this.createUserProfile(data.user.id, {
					username: userData.username || email.split('@')[0],
					role: 'user',
					location: userData.location || null,
				});
			}

			return {
				success: true,
				user: data.user,
				session: data.session,
				message:
					'Account created successfully! Please check your email for verification.',
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to create account',
			};
		}
	}

	/**
	 * Sign in with email and password
	 */
	static async signIn(email, password) {
		try {
			if (!supabase) {
				throw new Error('Supabase not configured');
			}

			const { data, error } = await supabase.auth.signInWithPassword({
				email,
				password,
			});

			if (error) throw error;

			// Store session info
			if (data.session) {
				await AsyncStorage.setItem(
					'user_session',
					JSON.stringify(data.session),
				);
			}

			return {
				success: true,
				user: data.user,
				session: data.session,
				message: 'Signed in successfully!',
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to sign in',
			};
		}
	}

	/**
	 * Sign out
	 */
	static async signOut() {
		try {
			if (!supabase) {
				throw new Error('Supabase not configured');
			}

			const { error } = await supabase.auth.signOut();

			if (error) throw error;

			// Clear stored session
			await AsyncStorage.removeItem('user_session');
			await AsyncStorage.removeItem('profile');

			return {
				success: true,
				message: 'Signed out successfully!',
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to sign out',
			};
		}
	}

	/**
	 * Get current user
	 */
	static async getCurrentUser() {
		try {
			if (!supabase) {
				return { success: false, user: null };
			}

			const {
				data: { user },
				error,
			} = await supabase.auth.getUser();

			if (error) throw error;

			return {
				success: true,
				user,
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to get current user',
			};
		}
	}

	/**
	 * Get current session
	 */
	static async getCurrentSession() {
		try {
			if (!supabase) {
				return { success: false, session: null };
			}

			const {
				data: { session },
				error,
			} = await supabase.auth.getSession();

			if (error) throw error;

			return {
				success: true,
				session,
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to get current session',
			};
		}
	}

	/**
	 * Reset password
	 */
	static async resetPassword(email) {
		try {
			if (!supabase) {
				throw new Error('Supabase not configured');
			}

			const { error } = await supabase.auth.resetPasswordForEmail(email);

			if (error) throw error;

			return {
				success: true,
				message: 'Password reset email sent! Please check your inbox.',
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to send reset email',
			};
		}
	}

	/**
	 * Create user profile in profiles table
	 */
	static async createUserProfile(userId, profileData) {
		try {
			if (!supabase) {
				throw new Error('Supabase not configured');
			}

			const { data, error } = await supabase
				.from('plant_disease.profiles')
				.insert([
					{
						id: userId,
						...profileData,
						created_at: new Date().toISOString(),
						updated_at: new Date().toISOString(),
					},
				])
				.select()
				.single();

			if (error) throw error;

			return {
				success: true,
				profile: data,
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to create user profile',
			};
		}
	}

	/**
	 * Get user profile
	 */
	static async getUserProfile(userId) {
		try {
			if (!supabase) {
				throw new Error('Supabase not configured');
			}

			const { data, error } = await supabase
				.from('profiles')
				.select('*')
				.eq('id', userId)
				.single();

			if (error) throw error;

			return {
				success: true,
				profile: data,
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to get user profiles',
			};
		}
	}

	/**
	 * Update user profile
	 */
	static async updateUserProfile(userId, updates) {
		try {
			if (!supabase) {
				throw new Error('Supabase not configured');
			}

			const { data, error } = await supabase
				.from('profiles')
				.update({
					...updates,
					updated_at: new Date().toISOString(),
				})
				.eq('id', userId)
				.select()
				.single();

			if (error) throw error;

			return {
				success: true,
				profile: data,
			};
		} catch (error) {
			return {
				success: false,
				error: error.message || 'Failed to update user profile',
			};
		}
	}

	/**
	 * Check if user is authenticated
	 */
	static async isAuthenticated() {
		const sessionResult = await this.getCurrentSession();
		return sessionResult.success && sessionResult.session !== null;
	}

	/**
	 * Listen to auth state changes
	 */
	static onAuthStateChange(callback) {
		if (!supabase) {
			return { data: { subscription: null } };
		}

		return supabase.auth.onAuthStateChange(callback);
	}
}

export default AuthService;
