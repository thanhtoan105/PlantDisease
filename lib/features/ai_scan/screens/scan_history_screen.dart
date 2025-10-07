import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/scan_history_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../models/scan_history.dart';
import 'scan_history_item.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchScanHistory();
    });
  }

  Future<void> _fetchScanHistory() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated && authProvider.user?.id != null) {
      await Provider.of<ScanHistoryProvider>(context, listen: false)
          .fetchScanHistory(authProvider.user!.id);
    }
  }

  /// OPTIMIZED: Extract location parsing to a separate method
  /// This reduces CPU cycles by avoiding deeply nested inline conditionals
  String _parseLocation(Map<String, dynamic>? locationData) {
    if (locationData == null) {
      debugPrint('Location data is null');
      return 'Unknown location';
    }

    // Debug: Print the entire location data
    debugPrint('Location data: $locationData');

    // Check for 'name' field
    final name = locationData['name'];
    debugPrint('Name field: $name');
    if (name != null && name.toString().trim().isNotEmpty) {
      debugPrint('Returning name: ${name.toString()}');
      return name.toString();
    }

    // Check for 'location_name' field
    final locationName = locationData['location_name'];
    if (locationName != null && locationName.toString().trim().isNotEmpty) {
      debugPrint('Returning location_name: ${locationName.toString()}');
      return locationName.toString();
    }

    // Fallback to coordinates if available
    final lat = locationData['latitude'];
    final lng = locationData['longitude'];
    if (lat != null && lng != null) {
      debugPrint('Returning coordinates: $lat, $lng');
      return '$lat, $lng';
    }

    debugPrint('Returning unknown location');
    return 'Unknown location';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Scan History',
      ),
      body: Consumer<ScanHistoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }
          if (provider.history.isEmpty) {
            return const Center(child: Text('No scan history found.'));
          }
          return ListView.builder(
            itemCount: provider.history.length,
            itemBuilder: (context, index) {
              final scan = provider.history[index];
              
              // Extract disease info
              String diseaseResult = '';
              double confidenceScore = 0.0;
              
              if (scan.detectedDiseases.isNotEmpty) {
                final firstDisease = scan.detectedDiseases[0];
                if (firstDisease is Map) {
                  diseaseResult = firstDisease['disease']?.toString().trim() ?? '';
                  confidenceScore = (firstDisease['confidence'] as num?)?.toDouble() ?? 0.0;
                }
              }
              
              final plantName = 'Tomato';
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
          );
        },
      ),
    );
  }

  // Helper function to format DateTime to 'time ago' string
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
}
