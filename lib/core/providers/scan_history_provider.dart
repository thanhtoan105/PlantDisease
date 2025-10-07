import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../../features/ai_scan/models/scan_history.dart';

class ScanHistoryProvider extends ChangeNotifier {
  // Loading states
  bool _isLoading = false;
  bool _isLoadingMore = false;

  // Data
  List<ScanHistory> _history = [];
  String? _error;

  // Pagination
  static const int _pageSize = 15; // Load 15 items at a time
  int _currentOffset = 0;
  bool _hasMoreData = true;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  List<ScanHistory> get history => _history;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;

  /// Initial fetch - loads first page
  Future<void> fetchScanHistory(String userId) async {
    _isLoading = true;
    _error = null;
    _currentOffset = 0;
    _hasMoreData = true;
    notifyListeners();

    try {
      final response = await SupabaseService.getUserScanHistory(
        userId: userId,
        limit: _pageSize,
        offset: 0,
      );

      _history = response
          .map((json) => ScanHistory.fromJson(json))
          .toList();

      // Check if there's more data
      _hasMoreData = response.length == _pageSize;
      _currentOffset = _pageSize;

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

  /// Load more data for infinite scrolling
  Future<void> loadMoreHistory(String userId) async {
    // Prevent duplicate loading
    if (_isLoadingMore || !_hasMoreData || _isLoading) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await SupabaseService.getUserScanHistory(
        userId: userId,
        limit: _pageSize,
        offset: _currentOffset,
      );

      final newItems = response
          .map((json) => ScanHistory.fromJson(json))
          .toList();

      // Append new items to existing history
      _history.addAll(newItems);

      // Update pagination state
      _hasMoreData = newItems.length == _pageSize;
      _currentOffset += newItems.length;

      debugPrint('✅ Loaded ${newItems.length} more items. Total: ${_history.length}');
    } catch (e) {
      debugPrint('Error loading more history: $e');
      // Don't show error for "load more" failures, just stop loading
      _hasMoreData = false;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Refresh the entire list (pull to refresh)
  Future<void> refreshHistory(String userId) async {
    _currentOffset = 0;
    _hasMoreData = true;
    await fetchScanHistory(userId);
  }

  /// Clear all data
  void clear() {
    _history = [];
    _error = null;
    _currentOffset = 0;
    _hasMoreData = true;
    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }
}
