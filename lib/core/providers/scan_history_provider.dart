import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/ai_scan/models/scan_history.dart';

class ScanHistoryProvider extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;
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
      final response = await supabase
          .from('analysis_results')
          .select()
          .eq('user_id', userId)
          .order('analysis_date', ascending: false);
      _history = (response as List)
          .map((json) => ScanHistory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = 'Failed to fetch scan history.';
      _history = [];
    }
    _isLoading = false;
    notifyListeners();
  }
}

