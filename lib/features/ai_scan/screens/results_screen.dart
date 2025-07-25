import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';

class ResultsScreen extends StatelessWidget {
  final String imagePath;
  final Map<String, dynamic> analysisResult;

  const ResultsScreen({
    super.key,
    required this.imagePath,
    required this.analysisResult,
  });

  @override
  Widget build(BuildContext context) {
    final topPrediction = analysisResult['topPrediction'];
    final predictions = analysisResult['predictions'] as List<dynamic>? ?? [];
    final isHealthy = analysisResult['isHealthy'] ?? false;
    final confidence = (analysisResult['confidence'] ?? 0.0) as double;
    final isDemoResult = analysisResult['isDemoResult'] ?? false;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text('Analysis Results'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Demo result banner
            if (isDemoResult) _buildDemoResultBanner(),

            // Image display
            _buildImageCard(),

            const SizedBox(height: AppDimensions.spacingXl),

            // Main result
            _buildMainResult(topPrediction, isHealthy, confidence),

            const SizedBox(height: AppDimensions.spacingXl),

            // Detailed predictions
            if (predictions.isNotEmpty) _buildDetailedPredictions(predictions),

            const SizedBox(height: AppDimensions.spacingXl),

            // Recommendations
            _buildRecommendations(isHealthy, topPrediction),

            const SizedBox(height: AppDimensions.spacingXl),

            // Action buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoResultBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingLg),
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Text(
              'Demo Mode: AI model file not found. Showing simulated results.',
              style: AppTypography.bodySmall.copyWith(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analyzed Image',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusMedium),
            child: Image.file(
              File(imagePath),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainResult(
      Map<String, dynamic>? topPrediction, bool isHealthy, double confidence) {
    final resultColor =
        isHealthy ? AppColors.successGreen : AppColors.warningOrange;
    final resultIcon = isHealthy ? Icons.check_circle : Icons.warning;
    final resultText =
        isHealthy ? 'Plant appears healthy!' : 'Disease detected';

    return CustomCard(
      child: Column(
        children: [
          // Status icon and text
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: resultColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  resultIcon,
                  color: resultColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resultText,
                      style: AppTypography.headlineMedium.copyWith(
                        color: resultColor,
                      ),
                    ),
                    if (topPrediction != null)
                      Text(
                        topPrediction['displayName'] ?? 'Unknown',
                        style: AppTypography.bodyLarge,
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          // Confidence meter
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confidence',
                    style: AppTypography.labelMedium,
                  ),
                  Text(
                    '${(confidence * 100).toStringAsFixed(1)}%',
                    style: AppTypography.labelMedium.copyWith(
                      color: resultColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              LinearProgressIndicator(
                value: confidence,
                backgroundColor: AppColors.lightGray,
                valueColor: AlwaysStoppedAnimation<Color>(resultColor),
                minHeight: 8,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedPredictions(List<dynamic> predictions) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Analysis',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          ...predictions.take(5).map((prediction) {
            final confidence = (prediction['confidence'] as double) * 100;
            final displayName = prediction['displayName'] ?? 'Unknown';

            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                  Text(
                    '${confidence.toStringAsFixed(1)}%',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecommendations(
      bool isHealthy, Map<String, dynamic>? topPrediction) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommendations',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          if (isHealthy) ...[
            _buildRecommendationItem(
              Icons.check_circle_outline,
              'Continue Care',
              'Your plant looks healthy! Keep up the good work with regular watering and proper lighting.',
              AppColors.successGreen,
            ),
            _buildRecommendationItem(
              Icons.visibility,
              'Monitor Regularly',
              'Check your plant regularly for any signs of disease or pest issues.',
              AppColors.info,
            ),
          ] else ...[
            _buildRecommendationItem(
              Icons.medical_services,
              'Treatment Required',
              'Consider applying appropriate fungicide or treatment for the detected condition.',
              AppColors.warningOrange,
            ),
            _buildRecommendationItem(
              Icons.person_search,
              'Consult Expert',
              'For severe cases, consult with a plant pathologist or agricultural expert.',
              AppColors.info,
            ),
            _buildRecommendationItem(
              Icons.cleaning_services,
              'Improve Conditions',
              'Ensure proper air circulation, avoid overwatering, and remove affected leaves.',
              AppColors.primaryGreen,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(
      IconData icon, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingLg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMedium,
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: 'Save Results',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Save functionality coming soon')),
            );
          },
          type: ButtonType.primary,
          icon: const Icon(Icons.save, color: AppColors.white),
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        CustomButton(
          text: 'Scan Another Plant',
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          type: ButtonType.secondary,
          icon: const Icon(Icons.camera_alt, color: AppColors.primaryGreen),
        ),
      ],
    );
  }
}
