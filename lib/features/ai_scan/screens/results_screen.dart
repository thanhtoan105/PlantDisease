import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../home/screens/disease_details_screen.dart';

class ResultsScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> analysisResult;
  final Map<String, dynamic>? locationData;

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
  Map<String, dynamic>? _locationData;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Result saved successfully!')),
      );
      setState(() {
        _isSaved = true; // Update saved state
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save result: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _navigateToDiseaseDetails(Map<String, dynamic>? prediction) async {
    if (prediction == null) return;

    try {
      // Get the class name from the AI model prediction
      final className = prediction['className'] ?? '';
      debugPrint('🔍 Fetching detailed data for class: $className');

      // Fetch detailed disease information from Supabase using the class name
      List<Map<String, dynamic>> diseaseResults = [];
      if (className.isNotEmpty) {
        diseaseResults = await SupabaseService.searchDiseases(className);
        debugPrint('📊 Found ${diseaseResults.length} disease records in database');
      }

      // Use the first matching result or create fallback data
      Map<String, dynamic> diseaseData;
      if (diseaseResults.isNotEmpty) {
        final dbDisease = diseaseResults.first;
        diseaseData = {
          'id': dbDisease['id'],
          'class_name': dbDisease['className'],
          'display_name': dbDisease['name'],
          'description': dbDisease['description'],
          'treatment': dbDisease['treatment'],
          'crop_name': dbDisease['cropName'],
          'crop_scientific_name': dbDisease['cropScientificName'],
          'confidence': prediction['confidence'] ?? 0.0,
          'ai_prediction': prediction, // Include original AI prediction
        };
        debugPrint('✅ Using database disease: ${diseaseData['display_name']}');
      } else {
        // Fallback data when no database match is found
        diseaseData = {
          'class_name': className,
          'display_name': prediction['displayName'] ?? className,
          'description': 'This disease was detected by our AI model. For detailed information about this condition, please consult with a plant pathologist or agricultural expert.',
          'treatment': 'Treatment recommendations are not available in our database for this specific condition. We recommend consulting with local agricultural experts or plant pathologists for appropriate treatment options.',
          'confidence': prediction['confidence'] ?? 0.0,
          'ai_prediction': prediction,
        };
        debugPrint('⚠️ Using fallback data for: ${diseaseData['display_name']}');
      }

      debugPrint('➡️ Navigating to disease details with complete data');

      // Navigate to disease details screen with rich data
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DiseaseDetailsScreen(disease: diseaseData),
          ),
        );
      }
    } catch (error) {
      debugPrint('❌ Error fetching disease details: $error');

      // Show error message and navigate with basic data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load detailed information: ${error.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );

        // Still navigate with basic prediction data
        final fallbackData = {
          'class_name': prediction['className'] ?? '',
          'display_name': prediction['displayName'] ?? prediction['className'] ?? '',
          'description': 'Disease information could not be loaded from the database.',
          'treatment': 'Please consult with a plant pathologist or agricultural expert.',
          'confidence': prediction['confidence'] ?? 0.0,
          'ai_prediction': prediction,
        };

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DiseaseDetailsScreen(disease: fallbackData),
          ),
        );
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

                  // Main result with improved design
                  _buildMainResult(topPrediction, isHealthy),

                  const SizedBox(height: AppDimensions.spacingLg),

                  // Disease Information (Causes and Treatment)
                  if (!isHealthy && _isLoadingDiseaseDetails)
                    _buildLoadingDiseaseInfo(),
                  if (!isHealthy &&
                      !_isLoadingDiseaseDetails &&
                      _diseaseDetails != null)
                    _buildDiseaseInformation(),

                  // Fallback recommendations for healthy plants or when no disease details
                  if (isHealthy ||
                      (!_isLoadingDiseaseDetails && _diseaseDetails == null))
                    _buildFallbackRecommendations(isHealthy, topPrediction),

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
                  color: Colors.black.withOpacity(0.1),
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
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildMainResult(
      Map<String, dynamic>? topPrediction, bool isHealthy) {
    final resultColor =
        isHealthy ? AppColors.successGreen : AppColors.warningOrange;
    final resultIcon = isHealthy ? Icons.check_circle : Icons.warning;
    final resultText =
        isHealthy ? 'Plant appears healthy!' : 'Disease detected';

    // Extract confidence from detectedDiseases
    final detectedDiseases = widget.analysisResult['detectedDiseases'] ?? [];
    double confidence = 0.0;
    if (detectedDiseases.isNotEmpty && detectedDiseases[0] is Map && detectedDiseases[0]['confidence'] != null) {
      confidence = (detectedDiseases[0]['confidence'] as num).toDouble();
    }

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
                  color: resultColor.withValues(alpha: 0.1),
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
                    if (confidence > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: confidence,
                              minHeight: 8,
                              backgroundColor: Colors.grey[200],
                              color: resultColor,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                              style: AppTypography.bodySmall.copyWith(color: resultColor),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseInformation() {
    if (_diseaseDetails == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Causes Section
        _buildExpandableSection(
          'Causes',
          _diseaseDetails!['description'] ?? 'No cause information available.',
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

  Widget _buildFallbackRecommendations(
      bool isHealthy, Map<String, dynamic>? topPrediction) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommendations',
                style: AppTypography.headlineMedium,
              ),
              // Add "View More" button for disease cases
              if (!isHealthy && topPrediction != null)
                GestureDetector(
                  onTap: () => _navigateToDiseaseDetails(topPrediction),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryGreen,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View More',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: AppColors.primaryGreen,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
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

  Widget _buildDiseaseRecommendations() {
    final disease = _diseaseDetails!;
    final causes = disease['description'] as String? ?? '';
    final treatment = disease['treatment'] as String? ?? '';
    final displayName = disease['display_name'] as String? ?? '';
    final className = disease['class_name'] as String? ?? '';

    // Debug information
    debugPrint('🔍 Building disease recommendations with data: $disease');
    debugPrint('📝 Display name: $displayName');
    debugPrint('🏷️ Class name: $className');
    debugPrint('📄 Description: ${causes.length} characters');
    debugPrint('💊 Treatment: ${treatment.length} characters');

    return Column(
      children: [
        // Debug info card (remove this in production)
        CustomCard(
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.spacingSm),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
            ),
            child: Text(
              'DEBUG: Disease details loaded - ${disease.keys.join(', ')}',
              style: AppTypography.bodySmall.copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.spacingMd),

        // Disease Title Card
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName.isNotEmpty ? displayName : (className.isNotEmpty ? className : 'Unknown Disease'),
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.warningOrange,
                ),
              ),
              if (className.isNotEmpty && displayName.isNotEmpty && className != displayName) ...[
                const SizedBox(height: AppDimensions.spacingXs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingSm,
                    vertical: AppDimensions.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                  ),
                  child: Text(
                    'Class: $className',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primaryGreen,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.spacingMd),

        // Causes Section
        if (causes.isNotEmpty)
          _buildDetailSection(
            'Causes',
            causes,
            Icons.info_outline,
            AppColors.info,
          ),

        // Treatment Section
        if (treatment.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacingMd),
          _buildDetailSection(
            'Treatment',
            treatment,
            Icons.medical_services_outlined,
            AppColors.successGreen,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon, Color color) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            content,
            style: AppTypography.bodyMedium.copyWith(
              height: 1.5,
            ),
          ),
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
              color: color.withValues(alpha: 0.1),
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
}
