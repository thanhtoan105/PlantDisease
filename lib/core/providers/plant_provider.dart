import 'package:flutter/foundation.dart';
import '../services/plant_service.dart';

class PlantProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _crops = [];
  List<Map<String, dynamic>> _diseases = [];
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get crops => _crops;
  List<Map<String, dynamic>> get diseases => _diseases;
  String? get error => _error;

  PlantProvider() {
    _initializePlantData();
  }

  Future<void> _initializePlantData() async {
    await loadCrops();
  }

  Future<void> loadCrops() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await PlantService.getAllCrops();

      if (result['success']) {
        _crops = List<Map<String, dynamic>>.from(result['data']);
      } else {
        _setError(result['error']);
        // Use fallback data even on error
        _crops = List<Map<String, dynamic>>.from(result['data']);
      }
    } catch (error) {
      debugPrint('Error loading crops: $error');
      _setError(error.toString());
      // Keep empty list to force database usage
      _crops = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Search crops by term
  Future<List<Map<String, dynamic>>> searchCrops(String searchTerm) async {
    try {
      final result = await PlantService.searchCrops(searchTerm);
      return List<Map<String, dynamic>>.from(result['data']);
    } catch (error) {
      debugPrint('Error searching crops: $error');
      // Fallback to local search
      return _crops
          .where((crop) =>
              crop['name']
                  .toString()
                  .toLowerCase()
                  .contains(searchTerm.toLowerCase()) ||
              crop['description']
                  .toString()
                  .toLowerCase()
                  .contains(searchTerm.toLowerCase()))
          .toList();
    }
  }

  /// Get crop details by ID
  Future<Map<String, dynamic>?> getCropDetails(String cropId) async {
    try {
      final result = await PlantService.getCropDetails(cropId);
      return result['data'];
    } catch (error) {
      debugPrint('Error getting crop details: $error');
      _setError(error.toString());
      return null;
    }
  }

  /// Refresh crops data
  Future<void> refreshCrops() async {
    await loadCrops();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
