import * as Location from 'expo-location';

class LocationService {
  /**
   * Request location permissions
   */
  static async requestLocationPermission() {
    try {
      const { status } = await Location.requestForegroundPermissionsAsync();
      return {
        success: status === 'granted',
        status,
      };
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
      // Check if location services are enabled
      const servicesEnabled = await this.isLocationEnabled();
      if (!servicesEnabled.success || !servicesEnabled.enabled) {
        return {
          success: false,
          error: 'Location services are disabled. Please enable location services in your device settings.',
        };
      }

      // Check permissions
      const permission = await Location.getForegroundPermissionsAsync();
      if (permission.status !== 'granted') {
        const requestResult = await this.requestLocationPermission();
        if (!requestResult.success) {
          return {
            success: false,
            error: 'Location permission denied. Please grant location permission to get weather data.',
          };
        }
      }

      // Get current position
      const location = await Location.getCurrentPositionAsync({
        accuracy: Location.Accuracy.Balanced,
        timeInterval: 10000, // 10 seconds timeout
      });

      return {
        success: true,
        data: {
          latitude: location.coords.latitude,
          longitude: location.coords.longitude,
          accuracy: location.coords.accuracy,
          timestamp: new Date(location.timestamp),
        },
      };
    } catch (error) {
      console.error('Get location error:', error);
      
      let errorMessage = 'Unable to get your location.';
      
      if (error.code === 'E_LOCATION_TIMEOUT') {
        errorMessage = 'Location request timed out. Please try again.';
      } else if (error.code === 'E_LOCATION_UNAVAILABLE') {
        errorMessage = 'Location is temporarily unavailable. Please try again later.';
      } else if (error.code === 'E_LOCATION_SETTINGS_UNSATISFIED') {
        errorMessage = 'Location settings are not satisfied. Please check your location settings.';
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
      const permission = await Location.getForegroundPermissionsAsync();
      if (permission.status !== 'granted') {
        const requestResult = await this.requestLocationPermission();
        if (!requestResult.success) {
          throw new Error('Location permission denied');
        }
      }

      const subscription = await Location.watchPositionAsync(
        {
          accuracy: Location.Accuracy.Balanced,
          timeInterval: 60000, // Update every minute
          distanceInterval: 1000, // Update every 1km
        },
        (location) => {
          callback({
            success: true,
            data: {
              latitude: location.coords.latitude,
              longitude: location.coords.longitude,
              accuracy: location.coords.accuracy,
              timestamp: new Date(location.timestamp),
            },
          });
        }
      );

      return {
        success: true,
        subscription,
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
      const permission = await Location.getForegroundPermissionsAsync();
      return {
        success: true,
        status: permission.status,
        canAskAgain: permission.canAskAgain,
      };
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