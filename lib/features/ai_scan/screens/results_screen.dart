import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/utils/custom_snackbars.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../home/screens/disease_details_screen.dart';

class ResultsScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> analysisResult;
  final String? locationData;  // Changed from Map to String

  const ResultsScreen({
    super.key,
    required this.imagePath,
    required this.analysisResult,
    required this.locationData,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final Map<String, bool> _expandedSections = {};
  Map<String, dynamic>? _diseaseDetails;
  bool _isLoadingDiseaseDetails = false;
  bool _isSaving = false;
  bool _isSaved = false; // New variable to track if the result has been saved
  String? _locationData;  // Changed from Map to String

  // Add missing properties to fix compilation errors
  bool get isDemoResult => widget.analysisResult['isDemoResult'] == true;
  Map<String, dynamic>? get topPrediction => widget.analysisResult['topPrediction'];
  bool get isHealthy => topPrediction == null || topPrediction!['className'] == 'healthy';

  @override
  void initState() {
    super.initState();
    _loadDiseaseDetails();
    _locationData = widget.locationData;
  }

  void _toggleSection(String sectionId) {
    setState(() {
      _expandedSections[sectionId] = !(_expandedSections[sectionId] ?? false);
    });
  }

  // Format disease label for display: "Apple___Apple_scab" -> "Apple Scab"
  String _formatDiseaseLabel(String label) {
    if (label.isEmpty || label == 'Unknown') return label;

    // Split on '___' and take the last part (disease name)
    final parts = label.split('___');
    final diseasePart = parts.length > 1 ? parts.last : label;

    // Replace underscores with spaces and capitalize each word
    return diseasePart
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  Future<void> _loadDiseaseDetails() async {
    final topPrediction = widget.analysisResult['topPrediction'];
    if (topPrediction == null || topPrediction == 'healthy') return;

    setState(() {
      _isLoadingDiseaseDetails = true;
    });

    try {
      // Try to get disease details from database using the prediction class name
      debugPrint('🔍 Searching for disease: $topPrediction');
      final diseaseData = await SupabaseService.searchDiseases(topPrediction);
      debugPrint('📊 Found ${diseaseData.length} disease results');
      if (diseaseData.isNotEmpty) {
        debugPrint('✅ Using disease: ${diseaseData.first['name']}');
        setState(() {
          _diseaseDetails = diseaseData.first;
        });
      } else {
        debugPrint('❌ No disease found for: $topPrediction');
      }
    } catch (error) {
      debugPrint('❌ Error loading disease details: $error');
    } finally {
      setState(() {
        _isLoadingDiseaseDetails = false;
      });
    }
  }

  Future<void> _saveResult() async {
    setState(() {
      _isSaving = true;
    });
    try {
      final userId = SupabaseService.currentUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be signed in to save results.')),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }
      final imagePath = widget.imagePath;
      final detectedDiseases = widget.analysisResult['detectedDiseases'] ?? [];
      final locationData = _locationData;
      final analysisDate = DateTime.now().toIso8601String();
      await SupabaseService.saveAnalysisResult(
        userId: userId,
        imagePath: imagePath,
        detectedDiseases: detectedDiseases,
        locationData: locationData,
        analysisDate: analysisDate,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Result saved successfully!')),
        );
        setState(() {
          _isSaved = true; // Update saved state
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save result: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Analysis Results',
      ),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Demo result banner
                  if (isDemoResult) _buildDemoResultBanner(),

                  // Image display with rounded corners and better styling
                  _buildImageCard(),

                  const SizedBox(height: AppDimensions.spacingLg),

                  // Detected Diseases List (Top 3)
                  _buildDetectedDiseasesList(),

                  const SizedBox(height: AppDimensions.spacingLg),

                  // Disease Information (Causes and Treatment)
                  if (!isHealthy && _isLoadingDiseaseDetails)
                    _buildLoadingDiseaseInfo(),
                  if (!isHealthy &&
                      !_isLoadingDiseaseDetails &&
                      _diseaseDetails != null)
                    _buildDiseaseInformation(),


                  // Add bottom padding to ensure content doesn't get hidden behind button
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Fixed bottom button (like in your reference image)
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: SafeArea(
              child: CustomButton(
                text: _isSaving
                    ? 'Saving Results...'
                    : (_isSaved
                        ? 'The result has been saved'
                        : 'Save Disease Detection'),
                onPressed: (_isSaving || _isSaved) ? null : _saveResult,
                type: ButtonType.primary,
                icon: _isSaved
                    ? null
                    : Icon(
                        _isSaving
                            ? Icons.hourglass_empty
                            : Icons.bookmark,
                        color: AppColors.white,
                      ),
              ),
            ),
          ),
        ],
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        child: Image.file(
          File(widget.imagePath),
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDetectedDiseasesList() {
    final detectedDiseases = widget.analysisResult['detectedDiseases'] ?? [];

    // Get top 3 diseases
    final topDiseases = detectedDiseases.take(3).toList();

    if (topDiseases.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detected Diseases',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.darkNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        ...topDiseases.asMap().entries.map((entry) {
          final index = entry.key;
          final disease = entry.value;
          return _buildDiseaseItem(disease, index);
        }).toList(),
      ],
    );
  }

  Widget _buildDiseaseItem(Map<String, dynamic> disease, int index) {
    // Extract label and format it for display
    final label = disease['label'] ?? 'Unknown';
    final diseaseName = _formatDiseaseLabel(label);
    final confidence = (disease['confidence'] ?? 0.0) as double;

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(
          color: AppColors.lightGray,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Image/Icon Section
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.all(AppDimensions.spacingSm),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Disease Info Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.spacingSm,
                horizontal: AppDimensions.spacingXs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Disease #${index + 1}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.mediumGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    diseaseName,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkNavy,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Arrow Button
          GestureDetector(
            onTap: () => _navigateToDiseaseDetailsFromList(disease),
            child: Container(
              margin: const EdgeInsets.all(AppDimensions.spacingSm),
              padding: const EdgeInsets.all(AppDimensions.spacingSm),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Simplified navigation from disease list - same as Search Screen approach
  Future<void> _navigateToDiseaseDetailsFromList(Map<String, dynamic> disease) async {
    try {
      final label = disease['label'] ?? '';

      if (label.isEmpty) return;

      final diseaseResults = await SupabaseService.searchDiseases(label);

      if (mounted) {
        if (diseaseResults.isNotEmpty) {
          // Use database result directly (same as Search Screen)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DiseaseDetailsScreen(disease: diseaseResults.first),
            ),
          );
        } else {
          CustomSnackbars.showError(
            context: context,
            message: 'Disease information not found in database',
          );
        }
      }
    } catch (error) {
      if (mounted) {
        CustomSnackbars.showError(
          context: context,
          message: 'Could not load disease information',
        );
      }
    }
  }

  Widget _buildDiseaseInformation() {
    if (_diseaseDetails == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Causes Section
        _buildExpandableSection(
          'Causes',
          _diseaseDetails!['overview'] ?? 'No cause information available.',
          'causes',
          Icons.info_outline,
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        // Treatment Section
        _buildExpandableSection(
          'Treatment',
          _diseaseDetails!['treatment'] ??
              'No treatment information available.',
          'treatment',
          Icons.medical_services,
        ),
      ],
    );
  }

  Widget _buildExpandableSection(
    String title,
    String content,
    String sectionId,
    IconData icon,
  ) {
    final isExpanded = _expandedSections[sectionId] ?? false;

    return CustomCard(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _toggleSection(sectionId),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: AppDimensions.spacingSm),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: AppColors.primaryGreen),
                  const SizedBox(width: AppDimensions.spacingXs),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.darkNavy,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 24,
                    color: AppColors.mediumGray,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.spacingSm),
              child: Text(
                content,
                style: AppTypography.bodyMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingDiseaseInfo() {
    return CustomCard(
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            'Loading disease information...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
}
