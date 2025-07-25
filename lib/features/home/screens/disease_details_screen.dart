import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/custom_card.dart';

class DiseaseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> disease;

  const DiseaseDetailsScreen({
    super.key,
    required this.disease,
  });

  @override
  State<DiseaseDetailsScreen> createState() => _DiseaseDetailsScreenState();
}

class _DiseaseDetailsScreenState extends State<DiseaseDetailsScreen>
    with TickerProviderStateMixin {
  String _activeTab = 'cause';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.disease.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.lightGray,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                Text(
                  'Disease not found',
                  style: AppTypography.headlineSmall,
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  'Unable to load disease information.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCauseContent(),
                  _buildTreatmentContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final disease = widget.disease;
    final imageUrl = disease['image_url'] as String?;

    return Container(
      height: 250,
      child: Stack(
        children: [
          // Disease Image
          Container(
            width: double.infinity,
            height: double.infinity,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: AppColors.mediumGray,
                        ),
                      );
                    },
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryGreen.withValues(alpha: 0.8),
                          AppColors.primaryGreen.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.coronavirus,
                      size: 80,
                      color: AppColors.white,
                    ),
                  ),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 20,
            left: 20,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Disease Info
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  disease['display_name'] ??
                      disease['name'] ??
                      'Unknown Disease',
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  'Disease Information',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryGreen,
        unselectedLabelColor: AppColors.mediumGray,
        indicatorColor: AppColors.primaryGreen,
        tabs: const [
          Tab(
            icon: Icon(Icons.info),
            text: 'Cause',
          ),
          Tab(
            icon: Icon(Icons.medical_services),
            text: 'Treatment Tips',
          ),
        ],
      ),
    );
  }

  Widget _buildCauseContent() {
    final disease = widget.disease;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info,
                  size: 24,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Text(
                  'Disease Cause',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              disease['description'] ??
                  'Cause information not available for this disease.',
              style: AppTypography.bodyMedium,
            ),

            // Additional symptoms if available
            if (disease['symptoms'] != null) ...[
              const SizedBox(height: AppDimensions.spacingLg),
              Text(
                'Common Symptoms',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              ...((disease['symptoms'] as List?) ?? []).map<Widget>((symptom) {
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppDimensions.spacingXs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(
                          symptom.toString(),
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentContent() {
    final disease = widget.disease;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.medical_services,
                  size: 24,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Text(
                  'Treatment Tips',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              disease['treatment'] ??
                  'Treatment information not available for this disease.',
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
