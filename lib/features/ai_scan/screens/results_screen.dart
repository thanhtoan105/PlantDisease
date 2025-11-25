import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/utils/custom_snackbars.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/gemini_service.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../home/screens/disease_details_screen.dart';

class ResultsScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> analysisResult;
  final String? locationData; // Changed from Map to String
  final Map<String, dynamic>? weatherData; // Add weather data

  const ResultsScreen({
    super.key,
    required this.imagePath,
    required this.analysisResult,
    this.locationData, // Optional since it's nullable
    this.weatherData, // Optional weather data
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isSaving = false;
  bool _isSaved = false; // New variable to track if the result has been saved
  bool _isNavigating = false; // Prevent multiple navigation
  String? _locationData; // Changed from Map to String

  // Add missing properties to fix compilation errors
  bool get isDemoResult => widget.analysisResult['isDemoResult'] == true;

  Map<String, dynamic>? get topPrediction {
    try {
      final tp = widget.analysisResult['topPrediction'];
      if (tp is Map<String, dynamic>) {
        return tp;
      } else if (tp is Map) {
        return Map<String, dynamic>.from(tp);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error accessing topPrediction: $e');
      return null;
    }
  }

  bool get isHealthy {
    try {
      if (topPrediction == null) return true;
      final label = topPrediction!['label']?.toString() ?? '';
      return label.toLowerCase().contains('healthy');
    } catch (e) {
      debugPrint('❌ Error in isHealthy: $e');
      return true;
    }
  }

  @override
  void initState() {
    super.initState();

    try {
      debugPrint(
          '\n╔════════════════════════════════════════════════════════════╗');
      debugPrint(
          '║         RESULTS SCREEN INITIALIZATION DEBUG               ║');
      debugPrint(
          '╚════════════════════════════════════════════════════════════╝\n');

      // 1. Debug imagePath
      debugPrint('📸 IMAGE PATH:');
      debugPrint('  Type: ${widget.imagePath.runtimeType}');
      debugPrint('  Value: ${widget.imagePath}');
      debugPrint('  Length: ${widget.imagePath.length} characters\n');

      // 2. Debug analysisResult
      debugPrint('🔬 ANALYSIS RESULT:');
      debugPrint('  Type: ${widget.analysisResult.runtimeType}');
      debugPrint('  Keys: ${widget.analysisResult.keys.toList()}');

      // Debug each key in analysisResult
      widget.analysisResult.forEach((key, value) {
        debugPrint('  [$key]:');
        debugPrint('    Type: ${value.runtimeType}');
        if (value is List && value.isNotEmpty) {
          debugPrint('    Length: ${value.length}');
          debugPrint('    First item type: ${value.first.runtimeType}');
        } else if (value is Map) {
          debugPrint('    Keys: ${value.keys.toList()}');
        }
      });
      debugPrint('');

      // 3. Debug locationData - THE CRITICAL PART
      debugPrint('📍 LOCATION DATA (CRITICAL DEBUG):');
      debugPrint('  Raw Type: ${widget.locationData.runtimeType}');
      debugPrint('  Raw Value: ${widget.locationData}');
      debugPrint('  Is null? ${widget.locationData == null}');
      debugPrint('  Is String? ${widget.locationData is String}');
      debugPrint('  Is Map? ${widget.locationData is Map}');
      debugPrint(
          '  Is Map<String, dynamic>? ${widget.locationData is Map<String, dynamic>}');

      // Handle locationData based on actual type with extensive debugging
      if (widget.locationData == null) {
        debugPrint('  ✅ locationData is null - setting to null');
        _locationData = null;
      } else if (widget.locationData is String) {
        debugPrint('  ✅ locationData is String - using it directly');
        _locationData = widget.locationData;
        debugPrint('  Final value: "$_locationData"');
      } else if (widget.locationData is Map) {
        debugPrint('  ⚠️⚠️⚠️ WARNING: locationData is Map!');
        final locationMap = widget.locationData as Map;
        debugPrint('  Map type: ${locationMap.runtimeType}');
        debugPrint('  Map keys: ${locationMap.keys.toList()}');
        debugPrint('  Map values: ${locationMap.values.toList()}');
        debugPrint('  Full map: $locationMap');

        // Try to extract 'data' field
        if (locationMap.containsKey('data')) {
          final dataValue = locationMap['data'];
          debugPrint('  Found "data" field in Map:');
          debugPrint('    Type: ${dataValue.runtimeType}');
          debugPrint('    Value: $dataValue');

          if (dataValue is String) {
            _locationData = dataValue;
            debugPrint(
                '  ✅ Extracted string from Map["data"]: "$_locationData"');
          } else {
            _locationData = dataValue.toString();
            debugPrint(
                '  ⚠️ Converted non-string data to string: "$_locationData"');
          }
        } else {
          // No 'data' key, convert entire map to string
          _locationData = locationMap.toString();
          debugPrint(
              '  ⚠️ No "data" key found, using map.toString(): "$_locationData"');
        }
      } else {
        // Unknown type, convert to string
        debugPrint('  ❌❌❌ ERROR: Unknown type detected!');
        debugPrint('  Converting to string...');
        _locationData = widget.locationData.toString();
        debugPrint('  Result: "$_locationData"');
      }

      debugPrint('  \n  ✅ FINAL _locationData:');
      debugPrint('     Type: ${_locationData.runtimeType}');
      debugPrint('     Value: "$_locationData"\n');

      // 4. Debug topPrediction
      debugPrint('🎯 TOP PREDICTION:');
      try {
        final tp = topPrediction;
        if (tp != null) {
          debugPrint('  Type: ${tp.runtimeType}');
          debugPrint('  Keys: ${tp.keys.toList()}');
          tp.forEach((key, value) {
            debugPrint('  [$key]: ${value.runtimeType} = $value');
          });
        } else {
          debugPrint('  ⚠️ topPrediction is null');
        }
      } catch (e) {
        debugPrint('  ❌ Error accessing topPrediction: $e');
      }
      debugPrint('');

      // 5. Debug detectedDiseases
      debugPrint('🦠 DETECTED DISEASES:');
      try {
        final diseases = widget.analysisResult['detectedDiseases'];
        if (diseases != null) {
          debugPrint('  Type: ${diseases.runtimeType}');
          debugPrint('  Is List? ${diseases is List}');
          if (diseases is List) {
            debugPrint('  Count: ${diseases.length}');
            for (int i = 0; i < diseases.length && i < 3; i++) {
              debugPrint('  Disease #$i:');
              debugPrint('    Type: ${diseases[i].runtimeType}');
              if (diseases[i] is Map) {
                final diseaseMap = diseases[i] as Map;
                debugPrint('    Keys: ${diseaseMap.keys.toList()}');
                diseaseMap.forEach((key, value) {
                  debugPrint('      [$key]: ${value.runtimeType} = $value');
                });
              } else {
                debugPrint('    Value: ${diseases[i]}');
              }
            }
          }
        } else {
          debugPrint('  ⚠️ detectedDiseases is null');
        }
      } catch (e) {
        debugPrint('  ❌ Error accessing detectedDiseases: $e');
      }
      debugPrint('');

      debugPrint(
          '╔════════════════════════════════════════════════════════════╗');
      debugPrint(
          '║         INITIALIZATION COMPLETE ✅                         ║');
      debugPrint(
          '╚════════════════════════════════════════════════════════════╝\n');
    } catch (e, stackTrace) {
      debugPrint(
          '\n╔════════════════════════════════════════════════════════════╗');
      debugPrint('║         ❌❌❌ CRITICAL ERROR ❌❌❌                      ║');
      debugPrint(
          '╚════════════════════════════════════════════════════════════╝');
      debugPrint('Error: $e');
      debugPrint('Error Type: ${e.runtimeType}');
      debugPrint('\n📋 STACK TRACE:');
      debugPrint(stackTrace.toString());
      debugPrint('\n📊 ERROR CONTEXT:');
      debugPrint(
          '  widget.locationData type: ${widget.locationData.runtimeType}');
      debugPrint('  widget.locationData value: ${widget.locationData}');
      debugPrint('  widget.imagePath: ${widget.imagePath}');
      debugPrint(
          '  widget.analysisResult keys: ${widget.analysisResult.keys.toList()}');

      // Set safe fallback
      _locationData = 'Unknown Location';

      // Show error on screen
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Initialization Error: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        });
      }
    }
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

  Future<void> _saveResult() async {
    setState(() {
      _isSaving = true;
    });
    try {
      final userId = SupabaseService.currentUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You must be signed in to save results.')),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }
      final imagePath = widget.imagePath;
      final allPredictions = widget.analysisResult['detectedDiseases'] ?? [];
      final locationData = _locationData;
      final analysisDate = DateTime.now().toIso8601String();

      await SupabaseService.saveAnalysisResult(
        userId: userId,
        imagePath: imagePath,
        allPredictions: allPredictions, // Send all predictions for processing
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

  void _showAITipsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while loading
      builder: (BuildContext context) {
        return _AITipsDialog(
          diseaseName: topPrediction?['label'] ?? 'Unknown',
          confidence: (topPrediction?['confidence'] ?? 0.0) as double,
          locationData: _locationData,
          weatherData: widget.weatherData,
        );
      },
    );
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
                        _isSaving ? Icons.hourglass_empty : Icons.bookmark,
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
    try {
      final detectedDiseases = widget.analysisResult['detectedDiseases'];

      if (detectedDiseases == null || detectedDiseases is! List) {
        debugPrint('⚠️ detectedDiseases is null or not a List');
        return const SizedBox.shrink();
      }

      // Get top 3 diseases
      final topDiseases = detectedDiseases.take(3).toList();

      if (topDiseases.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Detected Diseases',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: _showAITipsDialog,
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI Tips',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          ...topDiseases.asMap().entries.map((entry) {
            final index = entry.key;
            final disease = entry.value;
            if (disease is Map) {
              return _buildDiseaseItem(
                  Map<String, dynamic>.from(disease), index);
            } else {
              debugPrint(
                  '⚠️ Disease at index $index is not a Map: ${disease.runtimeType}');
              return const SizedBox.shrink();
            }
          }).toList(),
        ],
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in _buildDetectedDiseasesList: $e');
      debugPrint('Stack trace: $stackTrace');
      return const SizedBox.shrink();
    }
  }

  Widget _buildDiseaseItem(Map<String, dynamic> disease, int index) {
    // Extract label and format it for display
    final label = disease['label'] ?? disease['className'] ?? 'Unknown';
    final diseaseName = _formatDiseaseLabel(label);
    final confidence = (disease['confidence'] ?? 0.0) as double;

    // Only first disease (top prediction) gets arrow button
    final bool isTopPrediction = index == 0;
    final String diseaseLabel =
        isTopPrediction ? 'Top Prediction' : 'Alternative #${index}';

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(
          color: isTopPrediction ? AppColors.primaryGreen : AppColors.lightGray,
          width: isTopPrediction ? 2 : 1,
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
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusSmall),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusSmall),
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
                    diseaseLabel,
                    style: AppTypography.bodySmall.copyWith(
                      color: isTopPrediction
                          ? AppColors.primaryGreen
                          : AppColors.mediumGray,
                      fontWeight: FontWeight.w600,
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

          // Arrow Button - Available for ALL diseases
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
  Future<void> _navigateToDiseaseDetailsFromList(
      Map<String, dynamic> disease) async {
    // Prevent multiple navigation
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    try {
      final label = disease['label'] ?? '';

      if (label.isEmpty) {
        setState(() {
          _isNavigating = false;
        });
        return;
      }

      final diseaseResults = await SupabaseService.searchDiseases(label);

      if (mounted) {
        if (diseaseResults.isNotEmpty) {
          // Use database result directly (same as Search Screen)
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  DiseaseDetailsScreen(disease: diseaseResults.first),
            ),
          );

          // Reset navigation flag when returning from disease details screen
          if (mounted) {
            setState(() {
              _isNavigating = false;
            });
          }
        } else {
          setState(() {
            _isNavigating = false;
          });
          CustomSnackbars.showError(
            context: context,
            message: 'Disease information not found in database',
          );
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
        CustomSnackbars.showError(
          context: context,
          message: 'Could not load disease information',
        );
      }
    }
  }
}

// AI Tips Dialog Widget
class _AITipsDialog extends StatefulWidget {
  final String diseaseName;
  final double confidence;
  final String? locationData;
  final Map<String, dynamic>? weatherData;

  const _AITipsDialog({
    required this.diseaseName,
    required this.confidence,
    this.locationData,
    this.weatherData,
  });

  @override
  State<_AITipsDialog> createState() => _AITipsDialogState();
}

class _AITipsDialogState extends State<_AITipsDialog> {
  bool _isLoading = true;
  String _recommendation = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRecommendation();
  }

  Future<void> _fetchRecommendation() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final recommendation = await GeminiService.generateDiseaseRecommendation(
        diseaseName: widget.diseaseName,
        confidence: widget.confidence,
        locationData: widget.locationData,
        weatherData: widget.weatherData,
      );

      if (mounted) {
        setState(() {
          _recommendation = recommendation;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetching AI recommendation: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to generate AI recommendations. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: AppColors.primaryGreen,
                  size: 28,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: Text(
                    'AI Tips',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.darkNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.mediumGray),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMd),

            // Divider
            Divider(color: AppColors.lightGray, height: 1),
            const SizedBox(height: AppDimensions.spacingMd),

            // Content
            Flexible(
              child: SingleChildScrollView(
                child: _buildContent(),
              ),
            ),

            const SizedBox(height: AppDimensions.spacingLg),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: _isLoading ? 'Loading...' : 'Got it',
                onPressed:
                    _isLoading ? null : () => Navigator.of(context).pop(),
                type: ButtonType.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return _buildRecommendationContent();
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            'Analyzing with Gemini AI...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'Generating personalized recommendations based on disease, location, and weather conditions',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.spacingXs),
              Text(
                'Error',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            _error ?? 'An error occurred',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Retry',
              onPressed: _fetchRecommendation,
              type: ButtonType.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationContent() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with AI badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingSm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppColors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Gemini AI',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Expanded(
                child: Text(
                  'AI Recommendations',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),

          // AI-generated content rendered as Markdown
          MarkdownBody(
            data: _recommendation,
            selectable: true,
            styleSheet:
                MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              h1: AppTypography.headlineMedium
                  .copyWith(color: AppColors.darkNavy),
              h2: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold, color: AppColors.darkNavy),
              h3: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold, color: AppColors.darkNavy),
              p: AppTypography.bodyMedium
                  .copyWith(height: 1.4, color: AppColors.darkNavy),
              listBullet:
                  AppTypography.bodyMedium.copyWith(color: AppColors.darkNavy),
              codeblockDecoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              code: AppTypography.bodySmall
                  .copyWith(fontFamily: 'monospace', color: Colors.deepPurple),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingSm),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusSmall),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.amber.shade700,
                  size: 16,
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                Expanded(
                  child: Text(
                    'AI-generated advice. Always consult agricultural experts for critical decisions.',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.amber.shade900,
                      fontSize: 11,
                    ),
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
