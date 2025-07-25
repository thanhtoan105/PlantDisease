import React, { createContext, useContext, useReducer, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
// Temporarily disable AuthService to debug the crash
import AuthService from '../services/AuthService';

// Auth Context
const AuthContext = createContext();

// Action types
const AUTH_ACTIONS = {
	SET_LOADING: 'SET_LOADING',
	SET_USER: 'SET_USER',
	SET_SESSION: 'SET_SESSION',
	SET_PROFILE: 'SET_PROFILE',
	SET_ERROR: 'SET_ERROR',
	CLEAR_ERROR: 'CLEAR_ERROR',
	SET_ONBOARDING_COMPLETED: 'SET_ONBOARDING_COMPLETED',
	SET_GUEST_MODE: 'SET_GUEST_MODE',
	LOGOUT: 'LOGOUT',
};

// Initial state
const initialState = {
	isLoading: true,
	isAuthenticated: false,
	isGuestMode: false,
	user: null,
	session: null,
	profile: null,
	error: null,
	onboardingCompleted: false,
};

// Auth reducer
const authReducer = (state, action) => {
	switch (action.type) {
		case AUTH_ACTIONS.SET_LOADING:
			return {
				...state,
				isLoading: action.payload,
			};

		case AUTH_ACTIONS.SET_USER:
			return {
				...state,
				user: action.payload,
				isAuthenticated: !!action.payload,
				isLoading: false,
			};

		case AUTH_ACTIONS.SET_SESSION:
			return {
				...state,
				session: action.payload,
				isAuthenticated: !!action.payload,
			};

		case AUTH_ACTIONS.SET_PROFILE:
			return {
				...state,
				profile: action.payload,
			};

		case AUTH_ACTIONS.SET_ERROR:
			return {
				...state,
				error: action.payload,
				isLoading: false,
			};

		case AUTH_ACTIONS.CLEAR_ERROR:
			return {
				...state,
				error: null,
			};

		case AUTH_ACTIONS.SET_ONBOARDING_COMPLETED:
			return {
				...state,
				onboardingCompleted: action.payload,
			};

		case AUTH_ACTIONS.SET_GUEST_MODE:
			return {
				...state,
				isGuestMode: action.payload,
			};

		case AUTH_ACTIONS.LOGOUT:
			return {
				...initialState,
				isLoading: false,
				onboardingCompleted: state.onboardingCompleted,
				isGuestMode: false,
			};

		default:
			return state;
	}
};

// Auth Provider Component
export const AuthProvider = ({ children }) => {
	const [state, dispatch] = useReducer(authReducer, initialState);

	// Initialize auth state on mount
	useEffect(() => {
		initializeAuth();
	}, []);

	// Listen to auth state changes
	useEffect(() => {
		// Temporarily disabled to debug crash
		const {
			data: { subscription },
		} = AuthService.onAuthStateChange(async (event, session) => {
			console.log('Auth state changed:', event, session?.user?.email);
			if (event === 'SIGNED_IN' && session) {
				dispatch({ type: AUTH_ACTIONS.SET_USER, payload: session.user });
				dispatch({ type: AUTH_ACTIONS.SET_SESSION, payload: session });
				await loadUserProfile(session.user.id);
				// Complete onboarding when user signs in
				await completeOnboarding();
			} else if (event === 'SIGNED_OUT') {
				dispatch({ type: AUTH_ACTIONS.LOGOUT });
			}
		});
		return () => {
			subscription?.unsubscribe();
		};
	}, []);

	/**
	 * Initialize authentication state
	 */
	const initializeAuth = async () => {
		try {
			dispatch({ type: AUTH_ACTIONS.SET_LOADING, payload: true });

			// Check onboarding status
			const onboardingCompleted = await AsyncStorage.getItem(
				'onboarding_completed',
			);
			if (onboardingCompleted) {
				dispatch({
					type: AUTH_ACTIONS.SET_ONBOARDING_COMPLETED,
					payload: JSON.parse(onboardingCompleted),
				});
			}

			// Check guest mode status
			const guestMode = await AsyncStorage.getItem('guest_mode');
			if (guestMode) {
				dispatch({
					type: AUTH_ACTIONS.SET_GUEST_MODE,
					payload: JSON.parse(guestMode),
				});
			}

			// Check current session
			const sessionResult = await AuthService.getCurrentSession();
			if (sessionResult.success && sessionResult.session) {
				dispatch({
					type: AUTH_ACTIONS.SET_SESSION,
					payload: sessionResult.session,
				});
				dispatch({
					type: AUTH_ACTIONS.SET_USER,
					payload: sessionResult.session.user,
				});
				await loadUserProfile(sessionResult.session.user.id);
			}
		} catch (error) {
			console.error('Error initializing auth:', error);
			dispatch({ type: AUTH_ACTIONS.SET_ERROR, payload: error.message });
		} finally {
			dispatch({ type: AUTH_ACTIONS.SET_LOADING, payload: false });
		}
	};

	/**
	 * Load user profile
	 */
	const loadUserProfile = async (userId) => {
		try {
			const profileResult = await AuthService.getUserProfile(userId);
			if (profileResult.success) {
				dispatch({
					type: AUTH_ACTIONS.SET_PROFILE,
					payload: profileResult.profile,
				});
			}
		} catch (error) {
			console.error('Error loading user profile:', error);
		}
	};

	/**
	 * Sign up
	 */
	const signUp = async (email, password, userData = {}) => {
		try {
			dispatch({ type: AUTH_ACTIONS.SET_LOADING, payload: true });
			dispatch({ type: AUTH_ACTIONS.CLEAR_ERROR });

			const result = await AuthService.signUp(email, password, userData);

			if (result.success) {
				// Auth state change will be handled by the listener
				return result;
			} else {
				dispatch({ type: AUTH_ACTIONS.SET_ERROR, payload: result.error });
				return result;
			}
		} catch (error) {
			const errorMessage = error.message || 'Failed to create account';
			dispatch({ type: AUTH_ACTIONS.SET_ERROR, payload: errorMessage });
			return { success: false, error: errorMessage };
		} finally {
			dispatch({ type: AUTH_ACTIONS.SET_LOADING, payload: false });
		}
	};

	/**
	 * Sign in
	 */
	const signIn = async (email, password) => {
		try {
			dispatch({ type: AUTH_ACTIONS.SET_LOADING, payload: true });
			dispatch({ type: AUTH_ACTIONS.CLEAR_ERROR });

			const result = await AuthService.signIn(email, password);

			if (result.success) {
				// The listener will handle auth state change
				return result;
			} else {
				dispatch({ type: AUTH_ACTIONS.SET_ERROR, payload: result.error });
				return result;
			}
		} catch (error) {
			const errorMessage = error.message || 'Failed to sign in';
			dispatch({ type: AUTH_ACTIONS.SET_ERROR, payload: errorMessage });
			return { success: false, error: errorMessage };
		} finally {
			dispatch({ type: AUTH_ACTIONS.SET_LOADING, payload: false });
		}
	};

	/**
	 * Sign out
	 */
	const signOut = async () => {
		try {
			dispatch({ type: AUTH_ACTIONS.SET_LOADING, payload: true });

			const result = await AuthService.signOut();

			if (result.success) {
				// Clear guest mode when signing out
				await AsyncStorage.removeItem('guest_mode');
				dispatch({ type: AUTH_ACTIONS.LOGOUT });
			}

			return result;
		} catch (error) {
			const errorMessage = error.message || 'Failed to sign out';
			dispatch({ type: AUTH_ACTIONS.SET_ERROR, payload: errorMessage });
			return { success: false, error: errorMessage };
		} finally {
			dispatch({ type: AUTH_ACTIONS.SET_LOADING, payload: false });
		}
	};

	/**
	 * Reset password
	 */
	const resetPassword = async (email) => {
		try {
			dispatch({ type: AUTH_ACTIONS.CLEAR_ERROR });
			return await AuthService.resetPassword(email);
		} catch (error) {
			const errorMessage = error.message || 'Failed to reset password';
			dispatch({ type: AUTH_ACTIONS.SET_ERROR, payload: errorMessage });
			return { success: false, error: errorMessage };
		}
	};

	/**
	 * Complete onboarding
	 */
	const completeOnboarding = async () => {
		try {
			await AsyncStorage.setItem('onboarding_completed', JSON.stringify(true));
			dispatch({ type: AUTH_ACTIONS.SET_ONBOARDING_COMPLETED, payload: true });
		} catch (error) {
			console.error('Error completing onboarding:', error);
		}
	};

	/**
	 * Skip authentication (guest mode)
	 */
	const skipAuth = async () => {
		try {
			await AsyncStorage.setItem('guest_mode', JSON.stringify(true));
			await completeOnboarding();
			// Update both onboarding and guest mode state
			dispatch({ type: AUTH_ACTIONS.SET_ONBOARDING_COMPLETED, payload: true });
			dispatch({ type: AUTH_ACTIONS.SET_GUEST_MODE, payload: true });
		} catch (error) {
			console.error('Error setting guest mode:', error);
		}
	};

	/**
	 * Clear error
	 */
	const clearError = () => {
		dispatch({ type: AUTH_ACTIONS.CLEAR_ERROR });
	};

	/**
	 * Reset onboarding (for testing)
	 */
	const resetOnboarding = async () => {
		try {
			await AsyncStorage.removeItem('onboarding_completed');
			await AsyncStorage.removeItem('guest_mode');
			dispatch({ type: AUTH_ACTIONS.SET_ONBOARDING_COMPLETED, payload: false });
		} catch (error) {
			console.error('Error resetting onboarding:', error);
		}
	};

	/**
	 * Update profile
	 */
	const updateProfile = async (updates) => {
		try {
			if (!state.user) {
				throw new Error('No user logged in');
			}

			const result = await AuthService.updateUserProfile(
				state.user.id,
				updates,
			);

			if (result.success) {
				dispatch({ type: AUTH_ACTIONS.SET_PROFILE, payload: result.profile });
			}

			return result;
		} catch (error) {
			const errorMessage = error.message || 'Failed to update profile';
			dispatch({ type: AUTH_ACTIONS.SET_ERROR, payload: errorMessage });
			return { success: false, error: errorMessage };
		}
	};

	const value = {
		// State
		...state,

		// Actions
		signUp,
		signIn,
		signOut,
		resetPassword,
		completeOnboarding,
		skipAuth,
		clearError,
		updateProfile,
		resetOnboarding,
	};

	return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

// Custom hook to use auth context
export const useAuth = () => {
	const context = useContext(AuthContext);
	if (!context) {
		throw new Error('useAuth must be used within an AuthProvider');
	}
	return context;
};

export default AuthContext;
