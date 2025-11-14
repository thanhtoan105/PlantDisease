import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/scan_history_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import 'scan_history_item.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Fetch initial data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Fetch initial page of scan history
  Future<void> _fetchInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated && authProvider.user?.id != null) {
      _userId = authProvider.user!.id;
      await Provider.of<ScanHistoryProvider>(context, listen: false)
          .fetchScanHistory(_userId!);
    }
  }

  /// Handle scroll events for infinite scrolling
  void _onScroll() {
    if (_isNearBottom && _userId != null) {
      final provider = Provider.of<ScanHistoryProvider>(context, listen: false);
      provider.loadMoreHistory(_userId!);
    }
  }

  /// Check if user has scrolled near the bottom
  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Trigger load more when 200 pixels from bottom
    return currentScroll >= (maxScroll - 200);
  }

  /// Handle pull-to-refresh
  Future<void> _onRefresh() async {
    if (_userId != null) {
      await Provider.of<ScanHistoryProvider>(context, listen: false)
          .refreshHistory(_userId!);
    }
  }

  /// Parse location data to extract name
  String _parseLocation(String? locationData) {
    if (locationData == null || locationData.trim().isEmpty) {
      return 'Unknown location';
    }
    return locationData;
  }

  /// Format DateTime to 'time ago' string
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Parse label to extract plant name
  /// Example: "Durian___Leaf_Algal" -> "Durian"
  String _parseLabelToPlantName(String label) {
    if (label.contains('___')) {
      final parts = label.split('___');
      if (parts.isNotEmpty) {
        return parts[0].replaceAll('_', ' ').trim();
      }
    }
    return 'Unknown Plant';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Scan History',
      ),
      body: Consumer<ScanHistoryProvider>(
        builder: (context, provider, child) {
          // Initial loading state
          if (provider.isLoading && provider.history.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            );
          }

          // Error state
          if (provider.error != null && provider.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (provider.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No scan history found.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start scanning plants to see your history',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          // List with pull-to-refresh
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primaryGreen,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: provider.history.length + (provider.hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator at the bottom
                if (index == provider.history.length) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: provider.isLoadingMore
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryGreen,
                            ),
                          )
                        : const SizedBox.shrink(),
                  );
                }

                // Render scan history item
                final scan = provider.history[index];

                // Extract disease info
                String diseaseResult = '';
                String plantName = 'Unknown Plant';
                double confidenceScore = 0.0;

                if (scan.detectedDiseases.isNotEmpty) {
                  final firstDisease = scan.detectedDiseases[0];
                  if (firstDisease is Map) {
                    // Get the label directly without parsing
                    String? label = firstDisease['label']?.toString().trim();

                    if (label != null && label.isNotEmpty) {
                      // Show the raw label as is
                      diseaseResult = label;
                      // Extract plant name from label for display
                      plantName = _parseLabelToPlantName(label);
                    }

                    confidenceScore = (firstDisease['confidence'] as num?)?.toDouble() ?? 0.0;
                  }
                }

                final plantImage = scan.plantImage.isNotEmpty ? scan.plantImage : scan.imageUrl;
                final location = _parseLocation(scan.locationData);
                final timeAgo = _formatTimeAgo(scan.analysisDate);

                return ScanHistoryItem(
                  imageUrl: plantImage,
                  plantName: plantName,
                  location: location,
                  timeAgo: timeAgo,
                  diseaseResult: diseaseResult,
                  confidenceScore: confidenceScore,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
