import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../core/services/supabase_service.dart';

class ResultsScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> analysisResult;

  const ResultsScreen({
    super.key,
    required this.imagePath,
    required this.analysisResult,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final Map<String, bool> _expandedSections = {};
  Map<String, dynamic>? _diseaseDetails;
  bool _isLoadingDiseaseDetails = false;
  bool _isSaving = false;
  Map<String, dynamic>? _locationData;

  @override
  void initState() {
    super.initState();
    _loadDiseaseDetails();
    _fetchLocationAndWeather();
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

  Future<void> _fetchLocationAndWeather() async {
    // Example: Use geolocator to get location, then fetch weather
    // Replace with your actual API key and endpoint
    const apiKey = 'YOUR_WEATHER_API_KEY';
    double latitude = 0.0;
    double longitude = 0.0;
    // TODO: Use geolocator or similar to get real location
    // For demo, use fixed coordinates
    latitude = 10.762622;
    longitude = 106.660172;
    final weatherUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';
    try {
      final response = await http.get(Uri.parse(weatherUrl));
      if (response.statusCode == 200) {
        final weatherData = jsonDecode(response.body);
        setState(() {
          _locationData = {
            'latitude': latitude,
            'longitude': longitude,
            'weather': weatherData,
          };
        });
      } else {
        setState(() {
          _locationData = {
            'latitude': latitude,
            'longitude': longitude,
            'weather': null,
          };
        });
      }
    } catch (e) {
      setState(() {
        _locationData = {
          'latitude': latitude,
          'longitude': longitude,
          'weather': null,
          'error': e.toString(),
        };
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
      final confidenceScore = widget.analysisResult['confidence'] ?? 0.0;
      final locationData = _locationData;
      final analysisDate = DateTime.now().toIso8601String();
      await SupabaseService.saveAnalysisResult(
        userId: userId,
        imagePath: imagePath,
        detectedDiseases: detectedDiseases,
        confidenceScore: confidenceScore,
        locationData: locationData,
        analysisDate: analysisDate,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Result saved successfully!')),
      );
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

  @override
  Widget build(BuildContext context) {
    final topPrediction = widget.analysisResult['topPrediction'];
    final isHealthy = widget.analysisResult['isHealthy'] ?? false;
    final confidence = (widget.analysisResult['confidence'] ?? 0.0) as double;
    final isDemoResult = widget.analysisResult['isDemoResult'] ?? false;

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
              File(widget.imagePath),
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

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: _isSaving ? 'Saving...' : 'Save Results',
          onPressed: _isSaving ? null : _saveResult,
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
