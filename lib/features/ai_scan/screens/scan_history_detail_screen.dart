import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_card.dart';
import '../models/scan_history.dart';

/// Scan History Detail Screen
/// Displays detailed information about a specific scan
class ScanHistoryDetailScreen extends StatefulWidget {
  final ScanHistory scanHistory;

  const ScanHistoryDetailScreen({
    super.key,
    required this.scanHistory,
  });

  @override
  State<ScanHistoryDetailScreen> createState() => _ScanHistoryDetailScreenState();
}

class _ScanHistoryDetailScreenState extends State<ScanHistoryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Scan Details',
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlantNameHeading(),
            const SizedBox(height: AppDimensions.spacingMd),
            _buildPlantImage(),
            const SizedBox(height: AppDimensions.spacingMd),
            _buildMetadataSection(),
            const SizedBox(height: AppDimensions.spacingMd),
            Expanded(child: _buildTopPredictionsSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantNameHeading() {
    final plantName = _extractPlantNameFromDisease(widget.scanHistory.firstLabel);

    return Text(
      plantName,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        height: 1.2,
      ),
    );
  }

  Widget _buildPlantImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      child: Container(
        width: double.infinity,
        height: 210,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        ),
        child: Image.network(
          widget.scanHistory.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 40, color: Colors.grey[400]),
                const SizedBox(height: 4),
                Text(
                  'Image not available',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.primaryGreen,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetadataSection() {
    final coordinates = _getCoordinates(widget.scanHistory.locationData);
    final formattedTime = _getFormattedDateTime(widget.scanHistory.analysisDate);
    final confidencePercentage = '${(widget.scanHistory.firstConfidence * 100).toStringAsFixed(1)}%';

    return CustomCard(
      padding: AppDimensions.spacingSm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetadataRow('Location', coordinates),
          const SizedBox(height: 12),
          _buildMetadataRow('Time', formattedTime),
          const SizedBox(height: 12),
          _buildMetadataRow('Confidence', confidencePercentage),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String key, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            '$key:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: key == 'Confidence' ? AppColors.primaryGreen : Colors.black87,
              fontWeight: key == 'Confidence' ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTopPredictionsSection() {
    final topPredictions = _getTopPredictions();

    if (topPredictions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Predictions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: topPredictions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final prediction = topPredictions[index];
              return _buildPredictionItem(
                prediction['label'] as String,
                prediction['confidence'] as double,
                index + 1,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionItem(String label, double confidence, int rank) {
    final confidencePercentage = (confidence * 100).toStringAsFixed(1);

    return CustomCard(
      padding: AppDimensions.spacingMd,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            child: Container(
              width: 70,
              height: 70,
              color: Colors.grey[200],
              child: Image.network(
                widget.scanHistory.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.image, color: Colors.grey[500], size: 28),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$confidencePercentage%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rank #$rank',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods

  String _extractPlantNameFromDisease(String diseaseLabel) {
    if (diseaseLabel.contains('___')) {
      return diseaseLabel.split('___')[0].replaceAll('_', ' ');
    } else if (diseaseLabel.contains('_')) {
      final parts = diseaseLabel.split('_');
      return parts[0];
    }
    return diseaseLabel;
  }

  String _getCoordinates(Map<String, dynamic>? locationData) {
    if (locationData == null) return 'Not available';

    final lat = locationData['latitude'];
    final lng = locationData['longitude'];

    if (lat != null && lng != null) {
      return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
    }

    return 'Not available';
  }

  String _getFormattedDateTime(DateTime dateTime) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    return '${dateFormat.format(dateTime)} at ${timeFormat.format(dateTime)}';
  }

  List<Map<String, dynamic>> _getTopPredictions() {
    final predictions = <Map<String, dynamic>>[];

    for (var disease in widget.scanHistory.detectedDiseases) {
      String label = '';
      double confidence = 0.0;

      if (disease is Map) {
        label = disease['label']?.toString() ??
                disease['disease']?.toString() ??
                'Unknown';
        confidence = (disease['confidence'] as num?)?.toDouble() ?? 0.0;
      } else {
        label = disease.toString();
      }

      if (confidence > 0.0) {
        predictions.add({
          'label': label,
          'confidence': confidence,
        });
      }
    }

    predictions.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
    return predictions.take(3).toList();
  }
}
