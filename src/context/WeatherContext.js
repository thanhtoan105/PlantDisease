import React, { createContext, useContext, useReducer, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { WeatherApiService } from '../services/WeatherApiService';
import { LocationService } from '../services/LocationService';

// Weather Context
const WeatherContext = createContext();

// Action types
const WEATHER_ACTIONS = {
	SET_LOADING: 'SET_LOADING',
	SET_REFRESHING: 'SET_REFRESHING',
	SET_WEATHER_DATA: 'SET_WEATHER_DATA',
	SET_FORECAST_DATA: 'SET_FORECAST_DATA',
	SET_ERROR: 'SET_ERROR',
	SET_SELECTED_CITY: 'SET_SELECTED_CITY',
	SET_LOCATION_INFO: 'SET_LOCATION_INFO',
	SET_LOCATION_HISTORY: 'SET_LOCATION_HISTORY',
	CLEAR_ERROR: 'CLEAR_ERROR',
};

// Initial state
const initialState = {
	isLoading: false,
	isRefreshing: false,
	currentWeather: null,
	forecast: null,
	selectedCity: null,
	locationInfo: null, // For storing current location details
	locationHistory: [], // For storing previously selected cities
	error: null,
	lastUpdated: null,
};

// Reducer
const weatherReducer = (state, action) => {
	switch (action.type) {
		case WEATHER_ACTIONS.SET_LOADING:
			return {
				...state,
				isLoading: action.payload,
				error: action.payload ? null : state.error,
			};

		case WEATHER_ACTIONS.SET_REFRESHING:
			return {
				...state,
				isRefreshing: action.payload,
			};

		case WEATHER_ACTIONS.SET_WEATHER_DATA:
			return {
				...state,
				currentWeather: action.payload.current,
				forecast: action.payload.forecast,
				error: null,
				lastUpdated: new Date(),
			};

		case WEATHER_ACTIONS.SET_FORECAST_DATA:
			return {
				...state,
				forecast: action.payload,
			};

		case WEATHER_ACTIONS.SET_ERROR:
			return {
				...state,
				error: action.payload,
				isLoading: false,
				isRefreshing: false,
			};

		case WEATHER_ACTIONS.SET_SELECTED_CITY:
			return {
				...state,
				selectedCity: action.payload,
			};

		case WEATHER_ACTIONS.SET_LOCATION_INFO:
			return {
				...state,
				locationInfo: action.payload,
			};

		case WEATHER_ACTIONS.SET_LOCATION_HISTORY:
			return {
				...state,
				locationHistory: action.payload,
			};

		case WEATHER_ACTIONS.CLEAR_ERROR:
			return {
				...state,
				error: null,
			};

		default:
			return state;
	}
};

// Weather Provider Component
export const WeatherProvider = ({ children }) => {
	const [state, dispatch] = useReducer(weatherReducer, initialState);

	// Load selected city and location history from storage on mount
	useEffect(() => {
		loadSelectedCity();
		loadLocationHistory();
	}, []);

	// Load weather data when component mounts or selected city changes
	useEffect(() => {
		// Temporarily disabled to prevent location permission errors
		// loadWeatherData();
	}, [state.selectedCity]);

	/**
	 * Load selected city from AsyncStorage
	 */
	const loadSelectedCity = async () => {
		try {
			const cityData = await AsyncStorage.getItem('selected_city');
			if (cityData) {
				const city = JSON.parse(cityData);
				dispatch({
					type: WEATHER_ACTIONS.SET_SELECTED_CITY,
					payload: city,
				});
			}
		} catch (error) {
			console.error('Error loading selected city:', error);
		}
	};

	/**
	 * Load location history from AsyncStorage
	 */
	const loadLocationHistory = async () => {
		try {
			const historyData = await AsyncStorage.getItem('location_history');
			if (historyData) {
				const history = JSON.parse(historyData);
				dispatch({
					type: WEATHER_ACTIONS.SET_LOCATION_HISTORY,
					payload: history,
				});
			}
		} catch (error) {
			console.error('Error loading location history:', error);
		}
	};

	/**
	 * Add city to location history
	 */
	const addToLocationHistory = async (city) => {
		try {
			const currentHistory = state.locationHistory || [];

			// Check if city already exists in history
			const existingIndex = currentHistory.findIndex(
				(item) =>
					item.latitude === city.latitude && item.longitude === city.longitude,
			);

			let newHistory;
			if (existingIndex >= 0) {
				// Move existing city to front
				newHistory = [
					city,
					...currentHistory.filter((_, index) => index !== existingIndex),
				];
			} else {
				// Add new city to front, limit to 10 cities
				newHistory = [city, ...currentHistory].slice(0, 10);
			}

			// Save to AsyncStorage
			await AsyncStorage.setItem(
				'location_history',
				JSON.stringify(newHistory),
			);

			// Update state
			dispatch({
				type: WEATHER_ACTIONS.SET_LOCATION_HISTORY,
				payload: newHistory,
			});
		} catch (error) {
			console.error('Error adding to location history:', error);
		}
	};

	/**
	 * Remove city from location history
	 */
	const removeFromLocationHistory = async (cityToRemove) => {
		try {
			const currentHistory = state.locationHistory || [];
			const newHistory = currentHistory.filter(
				(city) =>
					!(
						city.latitude === cityToRemove.latitude &&
						city.longitude === cityToRemove.longitude
					),
			);

			// Save to AsyncStorage
			await AsyncStorage.setItem(
				'location_history',
				JSON.stringify(newHistory),
			);

			// Update state
			dispatch({
				type: WEATHER_ACTIONS.SET_LOCATION_HISTORY,
				payload: newHistory,
			});
		} catch (error) {
			console.error('Error removing from location history:', error);
		}
	};

	/**
	 * Load weather data using One Call API 3.0
	 */
	const loadWeatherData = async () => {
		try {
			dispatch({ type: WEATHER_ACTIONS.SET_LOADING, payload: true });

			let coordinates;
			let locationInfo = null;

			if (state.selectedCity) {
				// Use selected city coordinates
				coordinates = {
					latitude: state.selectedCity.latitude,
					longitude: state.selectedCity.longitude,
				};
				locationInfo = {
					name: state.selectedCity.name,
					country: state.selectedCity.country,
					state: state.selectedCity.state,
				};
			} else {
				// Get current location
				const locationResult = await LocationService.getCurrentLocation();
				if (!locationResult.success) {
					throw new Error(locationResult.error);
				}
				coordinates = locationResult.data;

				// Get location name from coordinates
				const locationNameResult =
					await WeatherApiService.getLocationFromCoordinates(
						coordinates.latitude,
						coordinates.longitude,
					);
				if (locationNameResult.success) {
					locationInfo = locationNameResult.data;
				}
			}

			// Store location info
			dispatch({
				type: WEATHER_ACTIONS.SET_LOCATION_INFO,
				payload: locationInfo,
			});

			// Get comprehensive weather data using One Call API 3.0
			const weatherResult =
				await WeatherApiService.getCurrentWeatherAndForecasts(
					coordinates.latitude,
					coordinates.longitude,
				);

			if (!weatherResult.success) {
				throw new Error(weatherResult.error);
			}

			const weatherData = weatherResult.data;

			// Process and structure the data for the app
			const processedData = {
				current: {
					// Core temperature data
					temperature: weatherData.current?.temperature || 0,
					feelsLike: weatherData.current?.feelsLike || 0,
					tempMin:
						weatherData.daily?.[0]?.temperature?.min ||
						weatherData.current?.temperature ||
						0,
					tempMax:
						weatherData.daily?.[0]?.temperature?.max ||
						weatherData.current?.temperature ||
						0,

					// Weather condition
					condition: weatherData.current?.condition || {
						main: 'Clear',
						description: 'clear sky',
						icon: '01d',
					},

					// Environmental data
					humidity: weatherData.current?.humidity || 0,
					pressure: weatherData.current?.pressure || 1013,
					visibility: weatherData.current?.visibility || 10,
					windSpeed: weatherData.current?.windSpeed || 0,
					windDegree: weatherData.current?.windDegree || 0,
					windDirection: weatherData.current?.windDirection || 'N',
					cloudiness: weatherData.current?.cloudiness || 0,
					uvIndex: weatherData.current?.uvIndex || 0,
					dewPoint: weatherData.current?.dewPoint || 0,

					// Time data
					sunrise: weatherData.current?.sunrise || new Date(),
					sunset: weatherData.current?.sunset || new Date(),
					timestamp: weatherData.current?.timestamp || new Date(),

					// Location info
					location: locationInfo || {
						name: 'Unknown Location',
						country: '',
						coordinates: coordinates,
					},
				},
				forecast: {
					// Hourly forecast (48 hours)
					hourly: weatherData.hourly || [],
					// Daily forecast (8 days)
					daily: weatherData.daily || [],
					// Minutely forecast if available
					minutely: weatherData.minutely || [],
					// Weather alerts
					alerts: weatherData.alerts || [],
					// Timezone info
					timezone: weatherData.timezone || 'UTC',
					timezone_offset: weatherData.timezone_offset || 0,
				},
			};

			dispatch({
				type: WEATHER_ACTIONS.SET_WEATHER_DATA,
				payload: processedData,
			});
		} catch (error) {
			console.error('Weather load error:', error);
			dispatch({
				type: WEATHER_ACTIONS.SET_ERROR,
				payload: error.message,
			});
		} finally {
			dispatch({ type: WEATHER_ACTIONS.SET_LOADING, payload: false });
		}
	};

	/**
	 * Refresh weather data
	 */
	const refreshWeatherData = async () => {
		dispatch({ type: WEATHER_ACTIONS.SET_REFRESHING, payload: true });
		await loadWeatherData();
		dispatch({ type: WEATHER_ACTIONS.SET_REFRESHING, payload: false });
	};

	/**
	 * Select a city for weather
	 */
	const selectCity = async (city) => {
		try {
			// Save to AsyncStorage
			await AsyncStorage.setItem('selected_city', JSON.stringify(city));

			// Add to location history
			await addToLocationHistory(city);

			// Update state
			dispatch({
				type: WEATHER_ACTIONS.SET_SELECTED_CITY,
				payload: city,
			});
		} catch (error) {
			console.error('Error selecting city:', error);
			dispatch({
				type: WEATHER_ACTIONS.SET_ERROR,
				payload: 'Failed to select city',
			});
		}
	};

	/**
	 * Use current location instead of selected city
	 */
	const useCurrentLocation = async () => {
		try {
			// Clear selected city from storage
			await AsyncStorage.removeItem('selected_city');

			// Update state
			dispatch({
				type: WEATHER_ACTIONS.SET_SELECTED_CITY,
				payload: null,
			});
		} catch (error) {
			console.error('Error using current location:', error);
			dispatch({
				type: WEATHER_ACTIONS.SET_ERROR,
				payload: 'Failed to use current location',
			});
		}
	};

	/**
	 * Search cities
	 */
	const searchCities = async (query) => {
		try {
			if (!query || query.trim().length === 0) {
				return [];
			}

			const result = await WeatherApiService.searchCities(query);
			if (result.success && Array.isArray(result.data)) {
				return result.data;
			} else {
				console.error('City search failed:', result.error);
				return [];
			}
		} catch (error) {
			console.error('City search error:', error);
			return [];
		}
	};

	/**
	 * Clear error
	 */
	const clearError = () => {
		dispatch({ type: WEATHER_ACTIONS.CLEAR_ERROR });
	};

	/**
	 * Get weather for specific city (for preview) using One Call API 3.0
	 */
	const getWeatherForCity = async (latitude, longitude) => {
		try {
			const result = await WeatherApiService.getCurrentWeatherAndForecasts(
				latitude,
				longitude,
				'minutely,daily,alerts', // Exclude unnecessary data for preview
			);

			if (result.success && result.data.current) {
				return result.data.current;
			} else {
				throw new Error(result.error);
			}
		} catch (error) {
			console.error('City weather error:', error);
			throw error;
		}
	};

	/**
	 * Get weather overview with AI summary (API 3.0 feature)
	 */
	const getWeatherOverview = async (date = null) => {
		try {
			let coordinates;

			if (state.selectedCity) {
				coordinates = {
					latitude: state.selectedCity.latitude,
					longitude: state.selectedCity.longitude,
				};
			} else if (state.locationInfo) {
				coordinates = state.locationInfo.coordinates;
			} else {
				throw new Error('No location available');
			}

			const result = await WeatherApiService.getWeatherOverview(
				coordinates.latitude,
				coordinates.longitude,
				date,
			);

			return result;
		} catch (error) {
			console.error('Weather overview error:', error);
			return { success: false, error: error.message };
		}
	};

	/**
	 * Get historical weather data (API 3.0 feature)
	 */
	const getHistoricalWeather = async (timestamp) => {
		try {
			let coordinates;

			if (state.selectedCity) {
				coordinates = {
					latitude: state.selectedCity.latitude,
					longitude: state.selectedCity.longitude,
				};
			} else if (state.locationInfo) {
				coordinates = state.locationInfo.coordinates;
			} else {
				throw new Error('No location available');
			}

			const result = await WeatherApiService.getHistoricalWeather(
				coordinates.latitude,
				coordinates.longitude,
				timestamp,
			);

			return result;
		} catch (error) {
			console.error('Historical weather error:', error);
			return { success: false, error: error.message };
		}
	};

	const value = {
		// State
		...state,

		// Actions
		loadWeatherData,
		refreshWeatherData,
		selectCity,
		useCurrentLocation,
		searchCities,
		clearError,
		getWeatherForCity,
		getWeatherOverview,
		getHistoricalWeather,
		addToLocationHistory,
		removeFromLocationHistory,
	};

	return (
		<WeatherContext.Provider value={value}>{children}</WeatherContext.Provider>
	);
};

// Custom hook to use weather context
export const useWeather = () => {
	const context = useContext(WeatherContext);
	if (!context) {
		throw new Error('useWeather must be used within a WeatherProvider');
	}
	return context;
};

export default WeatherContext;
