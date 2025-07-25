import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/services/plant_service.dart';
import '../../../shared/widgets/custom_search_bar.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/loading_spinner.dart';
import '../../../navigation/route_names.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeFilter = 'all';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  final List<Map<String, String>> _filters = [
    {'id': 'all', 'label': 'All', 'icon': 'search'},
    {'id': 'crops', 'label': 'Crops', 'icon': 'agriculture'},
    {'id': 'diseases', 'label': 'Diseases', 'icon': 'bug_report'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
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
      Map<String, dynamic> result;

      switch (_activeFilter) {
        case 'crops':
          result = await PlantService.searchCrops(query.trim());
          break;
        case 'diseases':
          result = await PlantService.searchDiseases(query.trim());
          break;
        default:
          result = await PlantService.searchAll(query.trim());
      }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            color: AppColors.primaryGreen,
            child: CustomSearchBar(
              placeholder: 'Search plants, diseases, tips...',
              value: _searchController.text,
              onChanged: (value) {
                _searchController.text = value;
                _performSearch(value);
              },
            ),
          ),

          // Filter tabs
          _buildFilterTabs(),

          // Search results
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      color: AppColors.white,
      child: Row(
        children: _filters.map((filter) {
          final isActive = _activeFilter == filter['id'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _activeFilter = filter['id']!;
                });
                _performSearch(_searchController.text);
              },
              child: Container(
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
                child: Center(
                  child: Text(
                    filter['label']!,
                    style: AppTypography.labelMedium.copyWith(
                      color: isActive
                          ? AppColors.primaryGreen
                          : AppColors.mediumGray,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return _buildSearchSuggestions();
    }

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
          Text(
            'Popular Searches',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppDimensions.spacingLg),

          // Popular search chips
          Wrap(
            spacing: AppDimensions.spacingSm,
            runSpacing: AppDimensions.spacingSm,
            children: [
              'Apple diseases',
              'Tomato blight',
              'Plant care tips',
              'Pest control',
              'Organic farming',
              'Weather forecast',
            ].map((suggestion) {
              return ActionChip(
                label: Text(suggestion),
                onPressed: () {
                  _searchController.text = suggestion;
                  _performSearch(suggestion);
                },
                backgroundColor: AppColors.white,
                labelStyle: AppTypography.bodyMedium,
              );
            }).toList(),
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          // Recent searches (if any)
          Text(
            'Browse Categories',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppDimensions.spacingLg),

          _buildCategoryCard(
              '🍎', 'Fruit Trees', 'Apple, Orange, Mango diseases'),
          _buildCategoryCard(
              '🥬', 'Vegetables', 'Tomato, Potato, Lettuce care'),
          _buildCategoryCard('🌾', 'Grains', 'Wheat, Rice, Corn cultivation'),
          _buildCategoryCard('🌿', 'Herbs', 'Basil, Mint, Oregano growing'),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String emoji, String title, String description) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      onTap: () {
        _searchController.text = title;
        _performSearch(title);
      },
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge,
                ),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.mediumGray,
            size: 16,
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
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              'Search Error',
              style: AppTypography.headlineMedium,
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
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.mediumGray.withOpacity(0.5),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              'No results found',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              'Try searching for different keywords or browse our categories',
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
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        final isDisease = result['type'] == 'disease';

        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
          child: CustomCard(
            onTap: () => _handleResultTap(result),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusMedium),
                  ),
                  child: Center(
                    child: Icon(
                      isDisease ? Icons.bug_report : Icons.eco,
                      color: isDisease
                          ? AppColors.accentOrange
                          : AppColors.primaryGreen,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingLg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result['name'] ?? 'Unknown',
                        style: AppTypography.labelLarge,
                      ),
                      if (isDisease && result['cropName'] != null) ...[
                        Text(
                          'Affects: ${result['cropName']}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.mediumGray,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXs),
                      ],
                      Text(
                        result['description'] ?? 'No description available',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.mediumGray,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingSm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (isDisease
                                  ? AppColors.accentOrange
                                  : AppColors.primaryGreen)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusSmall),
                        ),
                        child: Text(
                          isDisease ? 'Disease' : 'Crop',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDisease
                                ? AppColors.accentOrange
                                : AppColors.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.mediumGray,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleResultTap(Map<String, dynamic> result) {
    final isDisease = result['type'] == 'disease';

    if (isDisease) {
      // Navigate to disease details
      context.push('/disease-details', extra: result);
    } else {
      // Navigate to crop details
      context.push('${RouteNames.cropDetails}/${result['id']}', extra: result);
    }
  }
}
