import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../../features/ai_scan/models/scan_history.dart';

class ScanHistoryProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<ScanHistory> _history = [];
  String? _error;

  bool get isLoading => _isLoading;
  List<ScanHistory> get history => _history;
  String? get error => _error;

  Future<void> fetchScanHistory(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Use SupabaseService's getUserScanHistory which includes the crops table join
      final response = await SupabaseService.getUserScanHistory(userId: userId);
      _history = response
          .map((json) => ScanHistory.fromJson(json as Map<String, dynamic>))
          .toList();

      if (_history.isEmpty) {
        _error = 'No scan history found.';
      }
    } catch (e) {
      debugPrint('Error fetching scan history: $e');
      _error = 'Failed to fetch scan history. ${e.toString()}';
      _history = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
