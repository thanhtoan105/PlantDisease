import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../core/providers/scan_history_provider.dart';
import '../../../core/services/plant_service.dart';
import '../models/scan_history.dart';
import 'scan_history_item.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
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
              String plantImage = scan.plantImage.isNotEmpty ? scan.plantImage : scan.imageUri;
              // Location: prefer name if available, optimized for performance
              String location = scan.locationData != null && scan.locationData!['name'] != null && scan.locationData!['name'].toString().trim().isNotEmpty
                  ? scan.locationData!['name']
                  : (scan.locationData != null && scan.locationData!['location_name'] != null && scan.locationData!['location_name'].toString().trim().isNotEmpty
                      ? scan.locationData!['location_name']
                      : (scan.locationData != null && scan.locationData!['latitude'] != null && scan.locationData!['longitude'] != null
                          ? '${scan.locationData!['latitude']}, ${scan.locationData!['longitude']}'
                          : 'Unknown location'));
              // Disease result
              String diseaseResult = 'Cannot detect disease';
              if (scan.detectedDiseases.isNotEmpty) {
                var firstDisease = scan.detectedDiseases.first;
                // If firstDisease is a String that looks like a JSON array, decode it
                if (firstDisease is String) {
                  try {
                    final decoded = jsonDecode(firstDisease);
                    if (decoded is List && decoded.isNotEmpty && decoded[0] is Map) {
                      final map = decoded[0];
                      if (map['disease'] != null && map['disease'].toString().trim().isNotEmpty) {
                        diseaseResult = map['disease'].toString().trim();
                      } else if (map['name'] != null && map['name'].toString().trim().isNotEmpty) {
                        diseaseResult = map['name'].toString().trim();
                      }
                    }
                  } catch (e) {
                    // fallback: just show the string
                    diseaseResult = firstDisease;
                  }
                } else if (firstDisease is Map) {
                  if (firstDisease['disease'] != null && firstDisease['disease'].toString().trim().isNotEmpty) {
                    diseaseResult = firstDisease['disease'].toString().trim();
                  } else if (firstDisease['name'] != null && firstDisease['name'].toString().trim().isNotEmpty) {
                    diseaseResult = firstDisease['name'].toString().trim();
                  }
                }
              }
              // Format analysisDate to a readable string (e.g., '2 days ago' or date)
              String timeAgo = _formatTimeAgo(scan.analysisDate);
              // Extract confidence score from detectedDiseases if available
              double confidenceScore = scan.confidenceScore;
              if (scan.detectedDiseases.isNotEmpty) {
                var firstDisease = scan.detectedDiseases.first;
                Map? map;
                if (firstDisease is String) {
                  try {
                    final decoded = jsonDecode(firstDisease);
                    if (decoded is List && decoded.isNotEmpty && decoded[0] is Map) {
                      map = decoded[0];
                    }
                  } catch (_) {}
                } else if (firstDisease is Map) {
                  map = firstDisease;
                }
                if (map != null && map['confidence'] != null) {
                  confidenceScore = double.tryParse(map['confidence'].toString()) ?? confidenceScore;
                }
              }
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
