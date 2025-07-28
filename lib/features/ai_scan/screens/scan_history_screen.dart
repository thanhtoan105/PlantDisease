import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/scan_history_provider.dart';
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
              // Use plantName and plantImage from ScanHistory
              String plantName = scan.plantName;
              String plantImage = scan.plantImage.isNotEmpty ? scan.plantImage : scan.imageUri;
              // Location
              String location = 'Unknown location';
              if (scan.locationData != null && scan.locationData!['address'] != null) {
                location = scan.locationData!['address'];
              }
              // Disease result
              String diseaseResult = 'Không nhận ra bệnh, cần chụp cận vết bệnh';
              if (scan.detectedDiseases.isNotEmpty) {
                final firstDisease = scan.detectedDiseases.first;
                if (firstDisease is Map && firstDisease['name'] != null) {
                  diseaseResult = firstDisease['name'];
                } else if (firstDisease is String) {
                  diseaseResult = firstDisease;
                }
              }
              return ScanHistoryItem(
                imageUrl: plantImage,
                plantName: plantName,
                location: location,
                analysisDate: scan.analysisDate,
                diseaseResult: diseaseResult,
                confidenceScore: scan.confidenceScore,
              );
            },
          );
        },
      ),
    );
  }
}
