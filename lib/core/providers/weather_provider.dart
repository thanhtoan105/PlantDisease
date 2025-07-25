import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isRefreshing = false;
  Map<String, dynamic>? _currentWeather;
  Map<String, dynamic>? _forecast;
  String? _selectedCity;
  Map<String, dynamic>? _locationInfo;
  List<Map<String, dynamic>> _locationHistory = [];
  String? _error;
  String? _errorType;
  DateTime? _lastUpdated;
  bool _hasLocationPermission = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  Map<String, dynamic>? get currentWeather => _currentWeather;
  Map<String, dynamic>? get forecast => _forecast;
  String? get selectedCity => _selectedCity;
  Map<String, dynamic>? get locationInfo => _locationInfo;
  List<Map<String, dynamic>> get locationHistory => _locationHistory;
  String? get error => _error;
  String? get errorType => _errorType;
  DateTime? get lastUpdated => _lastUpdated;
  bool get hasLocationPermission => _hasLocationPermission;

  // Helper getters for error types
  bool get isLocationError =>
      _errorType == 'location_timeout' || _errorType == 'service_disabled';
  bool get isPermissionError =>
      _errorType == 'permission_denied' ||
      _errorType == 'permission_denied_forever';
  bool get canRetry => _errorType != 'permission_denied_forever';

  WeatherProvider() {
    _initializeWeather();
  }

  Future<void> _initializeWeather() async {
    await _loadLocationHistory();
    await loadWeatherData();
  }

  Future<void> loadWeatherData() async {
    _setLoading(true);
    _clearError();

    try {
      // Try to get current location first
      final locationResult = await WeatherService.getCurrentLocation();

      if (locationResult['success']) {
        _locationInfo = locationResult['data'];
        _selectedCity = _locationInfo!['name'];
        _hasLocationPermission = true;

        // Get weather for current location
        final weatherResult = await WeatherService.getCurrentWeather(
          _locationInfo!['latitude'],
          _locationInfo!['longitude'],
        );

        if (weatherResult['success']) {
          _currentWeather = weatherResult['data'];
          _lastUpdated = DateTime.now();
          await _saveLocationToHistory(_locationInfo!);
        } else {
          _setError(weatherResult['error'], 'api_error');
          // Fallback to mock data
          _loadMockData();
        }
      } else {
        _setError(locationResult['error'], locationResult['errorType']);
        _hasLocationPermission =
            locationResult['errorType'] != 'permission_denied' &&
                locationResult['errorType'] != 'permission_denied_forever';
        // Fallback to mock data
        _loadMockData();
      }
    } catch (e) {
      _setError('Failed to load weather data: $e');
      _loadMockData();
    } finally {
      _setLoading(false);
    }
  }

  void _loadMockData() {
    final mockData = WeatherService.getMockWeatherData();
    _currentWeather = mockData['data'];
    _selectedCity = 'Sample Location';
    _lastUpdated = DateTime.now();
  }

  Future<void> refreshWeatherData() async {
    _setRefreshing(true);
    await loadWeatherData();
    _setRefreshing(false);
  }

  Future<void> selectCity(
      String cityName, double latitude, double longitude) async {
    _setLoading(true);
    _clearError();

    try {
      final weatherResult =
          await WeatherService.getCurrentWeather(latitude, longitude);

      if (weatherResult['success']) {
        _currentWeather = weatherResult['data'];
        _selectedCity = cityName;
        _locationInfo = {
          'name': cityName,
          'latitude': latitude,
          'longitude': longitude,
        };
        _lastUpdated = DateTime.now();
        await _saveLocationToHistory(_locationInfo!);
      } else {
        _setError(weatherResult['error']);
      }
    } catch (e) {
      _setError('Failed to load weather for $cityName: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Map<String, dynamic>>> searchCities(String query) async {
    try {
      final result = await WeatherService.searchCities(query);
      if (result['success']) {
        return List<Map<String, dynamic>>.from(result['data']);
      }
      return [];
    } catch (e) {
      debugPrint('City search error: $e');
      return [];
    }
  }

  Future<void> _loadLocationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('weather_location_history') ?? [];
      _locationHistory = historyJson.map((json) {
        final parts = json.split('|');
        return {
          'name': parts[0],
          'latitude': double.parse(parts[1]),
          'longitude': double.parse(parts[2]),
        };
      }).toList();
    } catch (e) {
      debugPrint('Failed to load location history: $e');
      _locationHistory = [];
    }
  }

  Future<void> _saveLocationToHistory(Map<String, dynamic> location) async {
    try {
      // Remove if already exists
      _locationHistory.removeWhere((item) => item['name'] == location['name']);

      // Add to beginning
      _locationHistory.insert(0, location);

      // Keep only last 10 locations
      if (_locationHistory.length > 10) {
        _locationHistory = _locationHistory.take(10).toList();
      }

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _locationHistory.map((loc) {
        return '${loc['name']}|${loc['latitude']}|${loc['longitude']}';
      }).toList();
      await prefs.setStringList('weather_location_history', historyJson);

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save location history: $e');
    }
  }

  void _clearError() {
    _error = null;
    _errorType = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setRefreshing(bool refreshing) {
    _isRefreshing = refreshing;
    notifyListeners();
  }

  void _setError(String? error, [String? errorType]) {
    _error = error;
    _errorType = errorType;
    notifyListeners();
  }
}
