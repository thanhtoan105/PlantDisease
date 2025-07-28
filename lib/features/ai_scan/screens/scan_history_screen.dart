import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/scan_history_provider.dart';
import '../models/scan_history.dart';

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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: scan.imageUri.isNotEmpty
                      ? Image.network(scan.imageUri, width: 56, height: 56, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported),
                  title: Text('Scan #${scan.id}'),
                  subtitle: Text('Confidence: ${scan.confidenceScore.toStringAsFixed(2)}\nDate: ${scan.analysisDate.toLocal()}'),
                  onTap: () {
                    // Optionally show details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
