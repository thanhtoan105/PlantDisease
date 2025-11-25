import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_card.dart';
import '../models/scan_history.dart';

class ScanHistoryDetailScreen extends StatelessWidget {
  final ScanHistory scanHistory;

  const ScanHistoryDetailScreen({
    super.key,
    required this.scanHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Scan Detail',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          children: [
            _buildImageCard(),
            const SizedBox(height: AppDimensions.spacingLg),
            _buildTopInfoCard(),
            const SizedBox(height: AppDimensions.spacingLg),
          ],
        ),
      ),
    );
  }

  /// Image card with Hero animation
  Widget _buildImageCard() {
    final imageUrl = scanHistory.plantImage.isNotEmpty
        ? scanHistory.plantImage
        : scanHistory.imageUrl;

    return Hero(
      tag: 'scan_${scanHistory.id}',
      child: CustomCard(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          child: Image.network(
            imageUrl,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 80, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  /// Top info card with main details
  Widget _buildTopInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top 1 Name (Disease)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingSm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                ),
                child: const Text(
                  'PRIMARY DIAGNOSIS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            scanHistory.diseaseDisplayName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),

          // Location
          _buildInfoRow(
            Icons.location_on_outlined,
            'Location',
            _parseLocation(scanHistory.locationData),
          ),
          const SizedBox(height: AppDimensions.spacingMd),

          // Time
          _buildInfoRow(
            Icons.access_time_outlined,
            'Time',
            _formatDateTime(scanHistory.analysisDate),
          ),
          const SizedBox(height: AppDimensions.spacingMd),

          // Confidence
          _buildConfidenceRow(),

          // Alternative Possibilities (Relevant Diseases) - inline
          if (scanHistory.relevantDiseases != null &&
              scanHistory.relevantDiseases!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingLg),
            const Divider(height: 1),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              'Alternative Possibilities',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            ..._buildAlternativePredictions(),
          ],
        ],
      ),
    );
  }

  /// Info row helper
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Confidence row with progress bar
  Widget _buildConfidenceRow() {
    final confidence = scanHistory.topConfidence;
    final confidenceColor = _getConfidenceColor(confidence);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.verified_user, size: 20, color: confidenceColor),
            const SizedBox(width: AppDimensions.spacingSm),
            Text(
              'Confidence: ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${confidence.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: confidenceColor,
              ),
            ),
            const Spacer(),
            Text(
              _getConfidenceLabel(confidence),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: confidenceColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
          child: LinearProgressIndicator(
            value: confidence / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(confidenceColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  /// Build alternative predictions from relevantDiseases (simplified inline version)
  List<Widget> _buildAlternativePredictions() {
    if (scanHistory.relevantDiseases == null) return [];

    final widgets = <Widget>[];

    for (var i = 0; i < scanHistory.relevantDiseases!.length && i < 2; i++) {
      final disease = scanHistory.relevantDiseases![i];
      if (disease == null) continue;

      final name = _parseDiseaseName(disease['label']?.toString() ?? 'Unknown');
      final confidence = (disease['confidence'] as num?)?.toDouble() ?? 0.0;
      final color = Colors.grey[600]!;

      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingSm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                      child: LinearProgressIndicator(
                        value: confidence / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  SizedBox(
                    width: 50,
                    child: Text(
                      '${confidence.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      if (i < scanHistory.relevantDiseases!.length - 1 && i < 1) {
        widgets.add(const SizedBox(height: AppDimensions.spacingSm));
      }
    }

    return widgets;
  }

  /// Helper: Parse disease name from label
  String _parseDiseaseName(String label) {
    try {
      if (label.contains('___')) {
        final parts = label.split('___');
        if (parts.length >= 2) {
          final plant = parts[0].replaceAll('_', ' ');
          final disease = parts[1].replaceAll('_', ' ');
          return '$plant - $disease';
        }
      }
      return label.replaceAll('_', ' ');
    } catch (e) {
      return 'Unknown Disease';
    }
  }

  /// Helper: Parse location
  String _parseLocation(String? locationData) {
    if (locationData == null || locationData.trim().isEmpty) {
      return 'Unknown location';
    }
    return locationData;
  }

  /// Helper: Format DateTime to exact date and time
  String _formatDateTime(DateTime dateTime) {
    // Always show exact date and time: DD/MM/YYYY at HH:MM
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} - ${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  /// Helper: Get confidence color
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) return Colors.green;
    if (confidence >= 60) return Colors.orange;
    return Colors.red;
  }

  /// Helper: Get confidence label
  String _getConfidenceLabel(double confidence) {
    if (confidence >= 80) return 'High';
    if (confidence >= 60) return 'Medium';
    return 'Low';
  }
}

