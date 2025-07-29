import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/providers/plant_provider.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_spinner.dart';

class CropDetailsScreen extends StatefulWidget {
  final String cropId;
  final Map<String, dynamic>? crop;
  final String? initialTab; // Add initial tab parameter

  const CropDetailsScreen({
    super.key,
    required this.cropId,
    this.crop,
    this.initialTab, // Add initial tab parameter
  });

  @override
  State<CropDetailsScreen> createState() => _CropDetailsScreenState();
}

class _CropDetailsScreenState extends State<CropDetailsScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _cropDetails;
  bool _isLoading = true;
  String? _error;
  String _activeTab = 'overview';
  Map<String, bool> _expandedSections = {};
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Set initial tab if provided
    if (widget.initialTab != null) {
      _activeTab = widget.initialTab!;
    }

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeInOut));

    _loadCropDetails();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadCropDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final plantProvider = context.read<PlantProvider>();
      final details = await plantProvider.getCropDetails(widget.cropId);

      if (mounted) {
        setState(() {
          _cropDetails = details;
          _isLoading = false;
        });
        _fadeController.forward();
        _slideController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _toggleSection(String sectionId) {
    setState(() {
      _expandedSections[sectionId] = !(_expandedSections[sectionId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: Consumer<PlantProvider>(
          builder: (context, plantProvider, child) {
            if (plantProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              );
            }

            if (plantProvider.error != null && _cropDetails == null) {
              return _buildErrorState(plantProvider.error!);
            }

            if (_cropDetails == null) {
              return Scaffold(
                backgroundColor: AppColors.lightGray,
                body: SafeArea(
                  child: Center(
                    child: Text(
                      'No crop data available',
                      style: AppTypography.headlineSmall,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final crop = _cropDetails ?? widget.crop ?? {};
    final imageUrl = crop['image_url'] ??
        'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&h=300&fit=crop';

    return Container(
      height: 280,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(imageUrl),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            // Fallback to default image
          },
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Navigation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement favorite functionality
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                // Crop title and subtitle
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            crop['name'] ?? 'Unknown Crop',
                            style: AppTypography.headlineLarge.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingXs),
                          Text(
                            crop['scientificName'] ??
                                'Scientific name not available',
                            style: AppTypography.bodyLarge.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontStyle: FontStyle.italic,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
    final tabs = [
      {'id': 'overview', 'label': 'Overview', 'icon': Icons.info},
      {'id': 'diseases', 'label': 'Diseases', 'icon': Icons.bug_report},
      {'id': 'tips', 'label': 'Growing Tips', 'icon': Icons.eco},
    ];

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
      child: Row(
        children: tabs.map((tab) {
          final isActive = _activeTab == tab['id'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _activeTab = tab['id'] as String;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.spacingMd),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive
                          ? AppColors.primaryGreen
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 20,
                      color: isActive
                          ? AppColors.primaryGreen
                          : AppColors.mediumGray,
                    ),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Text(
                      tab['label'] as String,
                      style: AppTypography.labelMedium.copyWith(
                        color: isActive
                            ? AppColors.primaryGreen
                            : AppColors.mediumGray,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_activeTab) {
      case 'diseases':
        return _buildDiseasesTab();
      case 'tips':
        return _buildTipsTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    final crop = _cropDetails ?? widget.crop ?? {};

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          children: [
            // Quick Stats
            _buildQuickStats(),
            const SizedBox(height: AppDimensions.spacingLg),

            // Description Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Text(
                    crop['description'] ?? 'No description available',
                    style: AppTypography.bodyMedium.copyWith(
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),

            // Basic Information - Expandable
            _buildExpandableSection(
              'Basic Information',
              _buildBasicInfo(crop),
              'basic-info',
              Icons.info,
            ),

            // Growing Conditions - Expandable
            if (crop['growingConditions'] != null)
              _buildExpandableSection(
                'Growing Conditions',
                _buildGrowingConditionsContent(crop['growingConditions']),
                'growing-conditions',
                Icons.eco,
              ),

            // Growing Season - Expandable
            if (crop['seasons'] != null)
              _buildExpandableSection(
                'Growing Season',
                _buildGrowingSeasonsContent(crop['seasons']),
                'growing-season',
                Icons.schedule,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.thermostat,
            iconColor: AppColors.primaryGreen,
            value: '20-25°C',
            label: 'Temperature',
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        Expanded(
          child: _buildStatCard(
            icon: Icons.wb_sunny,
            iconColor: AppColors.warning,
            value: '6-8 hrs',
            label: 'Sunlight',
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        Expanded(
          child: _buildStatCard(
            icon: Icons.opacity,
            iconColor: AppColors.info,
            value: 'Regular',
            label: 'Watering',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            value,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(
    String title,
    Widget content,
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
              child: content,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBasicInfo(Map<String, dynamic> crop) {
    final info = {
      'Family': crop['family'],
      'Origin': crop['origin'],
      'Tree Type': crop['treeType'],
      'Mature Height': crop['matureHeight'],
      'Mature Width': crop['matureWidth'],
      'Lifespan': crop['lifespan'],
    };

    return Column(
      children: info.entries.map((entry) {
        return _buildInfoRow(entry.key, entry.value ?? 'N/A');
      }).toList(),
    );
  }

  Widget _buildGrowingConditionsContent(Map<String, dynamic> conditions) {
    final info = {
      'Climate': conditions['climate'],
      'Hardiness Zones': conditions['hardinessZones'],
      'Temperature': conditions['temperature'],
      'Sunlight': conditions['sunlight'],
      'Soil Type': conditions['soilType'],
      'Soil pH': conditions['soilPh'],
      'Water Requirements': conditions['waterRequirements'],
      'Spacing': conditions['spacing'],
    };

    return Column(
      children: info.entries.map((entry) {
        return _buildInfoRow(entry.key, entry.value ?? 'N/A');
      }).toList(),
    );
  }

  Widget _buildGrowingSeasonsContent(Map<String, dynamic> seasons) {
    final info = {
      'Planting Time': seasons['plantingTime'],
      'Blooming Period': seasons['bloomingPeriod'],
      'Fruit Development': seasons['fruitDevelopment'],
      'Harvest Time': seasons['harvestTime'],
      'First Harvest': seasons['firstHarvest'],
      'Dormancy': seasons['dormancy'],
    };

    return Column(
      children: info.entries.map((entry) {
        return _buildInfoRow(entry.key, entry.value ?? 'N/A');
      }).toList(),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsTab() {
    final tips = _cropDetails?['growing_tips'] as List<dynamic>? ?? [];

    if (tips.isEmpty) {
      return const Center(
        child: Text('No growing tips available.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      itemCount: tips.length,
      itemBuilder: (context, index) {
        final tip = tips[index] as Map<String, dynamic>;
        return _buildExpandableSection(
          tip['title'] ?? 'Tip',
          Text(tip['description'] ?? 'No description'),
          'tip-$index',
          Icons.eco,
        );
      },
    );
  }

  Widget _buildDiseasesTab() {
    final diseases = _cropDetails?['diseases'] as List<dynamic>? ?? [];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Text(
              'Common Diseases',
              style: AppTypography.headlineMedium,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              '${diseases.length} disease${diseases.length != 1 ? 's' : ''} identified',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),

            // Disease Cards
            if (diseases.isNotEmpty)
              _buildDiseaseGrid(diseases)
            else
              _buildEmptyDiseaseState(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseGrid(List diseases) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.spacingMd,
        mainAxisSpacing: AppDimensions.spacingMd,
        childAspectRatio: 0.8,
      ),
      itemCount: diseases.length,
      itemBuilder: (context, index) {
        final disease = diseases[index];
        return _buildDiseaseCard(disease);
      },
    );
  }

  Widget _buildDiseaseCard(Map<String, dynamic> disease) {
    final imageUrl = disease['image_url'] ??
        'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&h=300&fit=crop';

    return GestureDetector(
      onTap: () {
        context.push('/disease-details', extra: disease);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Disease Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.borderRadiusLarge),
                    topRight: Radius.circular(AppDimensions.borderRadiusLarge),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.borderRadiusLarge),
                    topRight: Radius.circular(AppDimensions.borderRadiusLarge),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      color: AppColors.lightGray,
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          color: AppColors.mediumGray,
                          size: 32,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.lightGray,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: AppColors.mediumGray,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Disease Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      disease['display_name'] ??
                          disease['name'] ??
                          'Unknown Disease',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkNavy,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDiseaseState() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXxl),
        child: Column(
          children: [
            Icon(
              Icons.bug_report,
              size: 48,
              color: AppColors.mediumGray,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              'No disease data available',
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              'Disease information for this crop is not yet available.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              'Unable to load crop details',
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              error,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            CustomButton(
              text: 'Retry',
              type: ButtonType.primary,
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                  _cropDetails = null;
                });
                _loadCropDetails();
              },
            ),
          ],
        ),
      ),
    );
  }
}
