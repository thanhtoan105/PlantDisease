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
      _crops = List<Map<String, dynamic>>.from(result['data']);
    } catch (error) {
      debugPrint('Error loading crops: $error');
      _setError('Could not load crops. Please check your connection.');
      _crops = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Map<String, dynamic>>> searchCrops(String searchTerm) async {
    try {
      final result = await PlantService.searchCrops(searchTerm);
      return List<Map<String, dynamic>>.from(result['data']);
    } catch (error) {
      debugPrint('Error searching crops: $error');
      _setError('Could not perform search. Please check your connection.');
      return [];
    }
  }

  /// Get crop details by ID
  Future<Map<String, dynamic>?> getCropDetails(String cropId) async {
    _setLoading(true);
    _clearError();
    try {
      final result = await PlantService.getCropDetails(cropId);
      return result['data'];
    } catch (error) {
      debugPrint('Error getting crop details: $error');
      _setError('Could not load crop details. Please check your connection.');
      return null;
    } finally {
      _setLoading(false);
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
