import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/services/plant_service.dart';
import '../../../shared/widgets/custom_search_bar.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/loading_spinner.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../navigation/route_names.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Constants
  static const List<String> _popularSearches = [
    'Apple',
    'Tomato',
    'Durian',
    'Plant care tips',
    'Pest control',
    'Blight',
    'Algal',
    'Colletotrichum',
    'Rhizoctonia',
  ];

  // State variables
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchQuery = '';
        _searchResults = [];
        _searchError = null;
      });
      return;
    }

    setState(() {
      _searchQuery = query;
      _isSearching = true;
      _searchError = null;
    });

    try {
      final result = await PlantService.searchAll(query.trim());

      if (mounted) {
        setState(() {
          if (result['success']) {
            _searchResults = List<Map<String, dynamic>>.from(result['data']);
          } else {
            _searchError = result['error'];
            _searchResults = [];
          }
          _isSearching = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _searchError = error.toString();
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchResults = [];
      _searchError = null;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _searchQuery.isEmpty,
      onPopInvoked: (didPop) {
        if (!didPop && _searchQuery.isNotEmpty) {
          _clearSearch();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: const CustomAppBar(
          title: 'Search',
        ),
        body: _searchQuery.isEmpty
            ? _buildSearchSuggestions()
            : _buildSearchResults(),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        // Search bar at top
        Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: CustomSearchBar(
            placeholder: 'Search plants, diseases...',
            controller: _searchController,
            onChanged: _performSearch,
          ),
        ),
        // Content based on state
        Expanded(
          child: _buildSearchContent(),
        ),
      ],
    );
  }

  Widget _buildSearchContent() {
    if (_isSearching) {
      return const Center(
        child: LoadingSpinner(size: 48),
      );
    }

    if (_searchError != null) {
      return _buildErrorState();
    }

    if (_searchResults.isEmpty) {
      return _buildNoResults();
    }

    return _buildResultsList();
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          CustomSearchBar(
            placeholder: 'Search plants, diseases...',
            controller: _searchController,
            onChanged: _performSearch,
          ),
          const SizedBox(height: AppDimensions.spacingXl),

          // Popular searches section
          Text(
            'Popular Searches',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),

          // Popular search chips
          Wrap(
            spacing: AppDimensions.spacingSm,
            runSpacing: AppDimensions.spacingSm,
            children: _popularSearches.map((suggestion) {
              return ActionChip(
                label: Text(suggestion),
                onPressed: () {
                  _searchController.text = suggestion;
                  _performSearch(suggestion);
                },
                backgroundColor: AppColors.lightGray,
                side: BorderSide.none,
                labelStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.darkNavy,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              'Search Error',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              _searchError ?? 'An error occurred while searching',
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

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 40,
                color: AppColors.mediumGray.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              'No results found',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              'Try searching for different keywords',
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

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return _buildResultCard(result);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    final isDisease = result['type'] == 'disease';
    final color = isDisease ? AppColors.accentOrange : AppColors.primaryGreen;
    final icon = isDisease ? Icons.bug_report : Icons.eco;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      child: CustomCard(
        onTap: () => _handleResultTap(result),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMedium),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: AppDimensions.spacingLg),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    result['name'] ?? 'Unknown',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.darkNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // Crop name for diseases
                  if (isDisease && result['cropName'] != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Affects: ${result['cropName']}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.mediumGray,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  // Description
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    result['description'] ?? 'No description available',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.mediumGray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Type badge
                  const SizedBox(height: AppDimensions.spacingSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingSm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusSmall),
                    ),
                    child: Text(
                      isDisease ? 'Disease' : 'Crop',
                      style: AppTypography.bodySmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            const SizedBox(width: AppDimensions.spacingMd),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.mediumGray.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _handleResultTap(Map<String, dynamic> result) {
    final isDisease = result['type'] == 'disease';

    if (isDisease) {
      context.push('/disease-details', extra: result);
    } else {
      context.push('${RouteNames.cropDetails}/${result['id']}', extra: result);
    }
  }
}
