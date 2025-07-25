import Geolocation from 'react-native-geolocation-service';
import { PermissionsAndroid, Platform } from 'react-native';

class LocationService {
	/**
	 * Request location permissions
	 */
	static async requestLocationPermission() {
		try {
			if (Platform.OS === 'android') {
				const granted = await PermissionsAndroid.request(
					PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
					{
						title: 'Location Permission',
						message:
							'This app needs access to location to provide weather information.',
						buttonNeutral: 'Ask Me Later',
						buttonNegative: 'Cancel',
						buttonPositive: 'OK',
					},
				);
				return {
					success: granted === PermissionsAndroid.RESULTS.GRANTED,
					status: granted,
				};
			} else {
				// iOS permissions are handled automatically by Geolocation
				return {
					success: true,
					status: 'granted',
				};
			}
		} catch (error) {
			console.error('Permission request error:', error);
			return {
				success: false,
				error: 'Failed to request location permission',
			};
		}
	}

	/**
	 * Check if location services are enabled
	 */
	static async isLocationEnabled() {
		try {
			const enabled = await Location.hasServicesEnabledAsync();
			return {
				success: true,
				enabled,
			};
		} catch (error) {
			console.error('Location services check error:', error);
			return {
				success: false,
				error: 'Failed to check location services',
			};
		}
	}

	/**
	 * Get current location
	 */
	static async getCurrentLocation() {
		try {
			// Check permissions first
			const permissionResult = await this.requestLocationPermission();
			if (!permissionResult.success) {
				return {
					success: false,
					error:
						'Location permission denied. Please grant location permission to get weather data.',
				};
			}

			// Get current position using promise wrapper
			return new Promise((resolve) => {
				Geolocation.getCurrentPosition(
					(position) => {
						resolve({
							success: true,
							data: {
								latitude: position.coords.latitude,
								longitude: position.coords.longitude,
								accuracy: position.coords.accuracy,
								timestamp: new Date(position.timestamp),
							},
						});
					},
					(error) => {
						console.error('Geolocation error:', error);
						resolve({
							success: false,
							error: `Failed to get location: ${error.message}`,
						});
					},
					{
						enableHighAccuracy: true,
						timeout: 15000,
						maximumAge: 10000,
					},
				);
			});
		} catch (error) {
			console.error('Get location error:', error);

			let errorMessage = 'Unable to get your location.';

			if (error.code === 'E_LOCATION_TIMEOUT') {
				errorMessage = 'Location request timed out. Please try again.';
			} else if (error.code === 'E_LOCATION_UNAVAILABLE') {
				errorMessage =
					'Location is temporarily unavailable. Please try again later.';
			} else if (error.code === 'E_LOCATION_SETTINGS_UNSATISFIED') {
				errorMessage =
					'Location settings are not satisfied. Please check your location settings.';
			}

			return {
				success: false,
				error: errorMessage,
			};
		}
	}

	/**
	 * Watch location changes (for real-time updates)
	 */
	static async watchLocation(callback) {
		try {
			const permission = await this.requestLocationPermission();
			if (!permission.success) {
				throw new Error('Location permission denied');
			}

			const watchId = Geolocation.watchPosition(
				(position) => {
					callback({
						success: true,
						data: {
							latitude: position.coords.latitude,
							longitude: position.coords.longitude,
							accuracy: position.coords.accuracy,
							timestamp: new Date(position.timestamp),
						},
					});
				},
				(error) => {
					console.error('Watch location error:', error);
					callback({
						success: false,
						error: `Failed to watch location: ${error.message}`,
					});
				},
				{
					enableHighAccuracy: true,
					timeout: 60000,
					maximumAge: 10000,
					distanceFilter: 1000, // Update every 1km
				},
			);

			return {
				success: true,
				subscription: {
					remove: () => Geolocation.clearWatch(watchId),
				},
			};
		} catch (error) {
			console.error('Watch location error:', error);
			return {
				success: false,
				error: 'Failed to watch location changes',
			};
		}
	}

	/**
	 * Get location permission status
	 */
	static async getLocationPermissionStatus() {
		try {
			if (Platform.OS === 'android') {
				const status = await PermissionsAndroid.check(
					PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
				);
				return {
					success: true,
					status: status ? 'granted' : 'denied',
					canAskAgain: true,
				};
			} else {
				// iOS - we can't check permission status directly with react-native-geolocation-service
				// We'll assume it's available and let the actual location request handle permissions
				return {
					success: true,
					status: 'granted',
					canAskAgain: true,
				};
			}
		} catch (error) {
			console.error('Permission status error:', error);
			return {
				success: false,
				error: 'Failed to get permission status',
			};
		}
	}
}

export default LocationService;
export { LocationService };
