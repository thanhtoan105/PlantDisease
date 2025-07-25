import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/providers/plant_provider.dart';
import '../../../shared/widgets/custom_search_bar.dart';

import '../widgets/crop_card.dart';
import '../../../navigation/route_names.dart';

class CropLibraryScreen extends StatefulWidget {
  const CropLibraryScreen({super.key});

  @override
  State<CropLibraryScreen> createState() => _CropLibraryScreenState();
}

class _CropLibraryScreenState extends State<CropLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredCrops = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeCrops();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeCrops() {
    final plantProvider = context.read<PlantProvider>();
    _filteredCrops = plantProvider.crops;
  }

  void _onSearchChanged(String query) async {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      setState(() {
        _filteredCrops = context.read<PlantProvider>().crops;
      });
      return;
    }

    try {
      final plantProvider = context.read<PlantProvider>();
      final results = await plantProvider.searchCrops(query);
      setState(() {
        _filteredCrops = results;
      });
    } catch (error) {
      // Fallback to local filtering
      final allCrops = context.read<PlantProvider>().crops;
      setState(() {
        _filteredCrops = allCrops
            .where((crop) =>
                crop['name']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                crop['description']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void _handleCropPress(Map<String, dynamic> crop) {
    // Navigate to crop details screen
    context.push('${RouteNames.cropDetails}/${crop['id']}', extra: crop);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Consumer<PlantProvider>(
                builder: (context, plantProvider, child) {
                  if (plantProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await plantProvider.refreshCrops();
                      _initializeCrops();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _buildSearchSection(),
                          _buildStatsSection(),
                          _buildSectionHeader(),
                          _buildCropsGrid(),
                          if (_filteredCrops.isEmpty) _buildEmptyState(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.lightGray,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMedium),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.darkNavy,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Crop Library',
              style: AppTypography.headlineLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40), // Spacer to center the title
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      color: AppColors.white,
      child: CustomSearchBar(
        placeholder: 'Search crops...',
        value: _searchController.text,
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildStatsSection() {
    final totalCrops = context.read<PlantProvider>().crops.length;
    final totalDiseases = context
        .read<PlantProvider>()
        .crops
        .fold<int>(0, (sum, crop) => sum + (crop['diseaseCount'] as int? ?? 0));

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingLg),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: AppDimensions.spacingLg,
      ),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  totalCrops.toString(),
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  'Total Crops',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.lightGray,
            margin:
                const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  totalDiseases.toString(),
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  'Diseases Covered',
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

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Crops',
                style: AppTypography.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            '${_filteredCrops.length} crop${_filteredCrops.length != 1 ? 's' : ''} found',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
        ],
      ),
    );
  }

  Widget _buildCropsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.spacingMd,
          mainAxisSpacing: AppDimensions.spacingLg,
          childAspectRatio: 0.85,
        ),
        itemCount: _filteredCrops.length,
        itemBuilder: (context, index) {
          final crop = _filteredCrops[index];
          return CropCard(
            name: crop['name'],
            emoji: crop['emoji'],
            diseaseCount: crop['diseaseCount'],
            onTap: () => _handleCropPress(crop),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      child: Column(
        children: [
          Icon(
            _isSearching ? Icons.search_off : Icons.agriculture,
            size: 64,
            color: AppColors.mediumGray,
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Text(
            _isSearching ? 'No crops found' : 'No crops available',
            style: AppTypography.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            _isSearching
                ? 'Try adjusting your search terms'
                : 'Check your internet connection and try again',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
