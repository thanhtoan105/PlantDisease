import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../core/providers/scan_history_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/plant_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/scan_history.dart';
import 'scan_history_item.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        title: Text(
          'Scan History',
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
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
              // Hard code plant name to 'Tomato'
              String plantName = 'Tomato';
              String plantImage = scan.plantImage.isNotEmpty ? scan.plantImage : scan.imageUrl;
              // Location: prefer name if available, optimized for performance
              String location = scan.locationData != null && scan.locationData!['name'] != null && scan.locationData!['name'].toString().trim().isNotEmpty
                  ? scan.locationData!['name']
                  : (scan.locationData != null && scan.locationData!['location_name'] != null && scan.locationData!['location_name'].toString().trim().isNotEmpty
                      ? scan.locationData!['location_name']
                      : (scan.locationData != null && scan.locationData!['latitude'] != null && scan.locationData!['longitude'] != null
                          ? '${scan.locationData!['latitude']}, ${scan.locationData!['longitude']}'
                          : 'Unknown location'));
              // Format analysisDate to a readable string (e.g., '2 days ago' or date)
              String timeAgo = _formatTimeAgo(scan.analysisDate);
              return ScanHistoryItem(
                imageUrl: plantImage,
                plantName: plantName,
                location: location,
                timeAgo: timeAgo,
                detectedDiseasesJson: jsonEncode(scan.detectedDiseases),
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
