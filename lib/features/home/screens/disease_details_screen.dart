import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    final rawUrl = disease['image_url'] as String?;
    final imageUrl = (rawUrl != null && rawUrl.isNotEmpty)
        ? rawUrl
        : 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&h=300&fit=crop';

    return Container(
      height: 280,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(imageUrl),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {},
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button (standardized size)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 44), // keep symmetrical spacing
                  ],
                ),

                // Disease title and subtitle
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        disease['display_name'] ??
                            disease['name'] ??
                            'Unknown Disease',
                        style: AppTypography.headlineLarge.copyWith(
                          fontSize: 24, // slightly smaller than plant title
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        'Disease Information',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
            text: 'Description',
          ),
          Tab(
            icon: Icon(Icons.medical_services),
            text: 'Treatment',
          ),
        ],
      ),
    );
  }

  Widget _buildCauseContent() {
    final disease = widget.disease;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        children: [
          // Information Card
          CustomCard(
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
                      'Information',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                Text(
                  disease['overview'] ??
                      'Cause information not available for this disease.',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          // Prevention Card
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shield,
                      size: 24,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    Text(
                      'Prevention',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                Text(
                  disease['prevention'] ??
                      'Prevention information not available for this disease.',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentContent() {
    final disease = widget.disease;
    final organicTreatment = disease['organic_treatment'] as String?;
    final chemicalTreatment = disease['chemical_treatment'] as String?;

    // Check if we have any treatment data
    final hasOrganicTreatment = organicTreatment != null &&
        organicTreatment.isNotEmpty &&
        organicTreatment != 'No organic treatment information available';
    final hasChemicalTreatment = chemicalTreatment != null &&
        chemicalTreatment.isNotEmpty &&
        chemicalTreatment != 'No chemical treatment information available';

    if (hasOrganicTreatment || hasChemicalTreatment) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          children: [
            // Organic Treatment
            if (hasOrganicTreatment)
              _buildTreatmentCard(
                'Organic Treatment',
                organicTreatment,
                Icons.eco,
                AppColors.successGreen,
              ),

            // Chemical Treatment
            if (hasChemicalTreatment) ...[
              const SizedBox(height: AppDimensions.spacingMd),
              _buildTreatmentCard(
                'Chemical Treatment',
                chemicalTreatment,
                Icons.science,
                AppColors.accentOrange,
              ),
            ],
          ],
        ),
      );
    }

    // Fallback if no treatment data
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
              'Treatment information not available for this disease.',
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentCard(String title, String content, IconData icon, Color color) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: color,
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            content,
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}
