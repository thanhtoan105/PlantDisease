import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/providers/plant_provider.dart';
import '../../../core/providers/weather_provider.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_search_bar.dart';
import '../../../navigation/route_names.dart';
import '../widgets/weather_widget.dart';
import '../widgets/crop_card.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToAIScan;

  const HomeScreen({super.key, this.onNavigateToAIScan});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlantProvider>().loadCrops();
      context.read<WeatherProvider>().loadWeatherData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Plant Disease Detection',
                style: AppTypography.headlineLarge,
              ),

              const SizedBox(height: AppDimensions.spacingLg),

              // Search bar
              CustomSearchBar(
                placeholder: 'Search plants, diseases...',
                enabled: false,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // AI Scan button
              _buildAIScanButton(),

              const SizedBox(height: AppDimensions.spacingXl),

              // Function cards
              _buildFunctionCards(),

              const SizedBox(height: AppDimensions.spacingXl),

              // Weather widget
              Consumer<WeatherProvider>(
                builder: (context, weatherProvider, child) {
                  return const WeatherWidget();
                },
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // Crop library
              _buildCropLibrary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIScanButton() {
    return CustomCard(
      backgroundColor: AppColors.primaryGreen,
      onTap: () {
        // Switch to AI Scan tab using callback
        widget.onNavigateToAIScan?.call();
      },
      child: SizedBox(
        height: 80,
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusLarge),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: AppColors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingLg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'AI Plant Disease Scanner',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    'Tap to scan your plant for diseases',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _handleFunctionCardTap(String title) {
    switch (title) {
      case 'Plant Details':
        context.push(RouteNames.cropLibrary);
        break;
      case 'Weather':
        // Navigate to weather details or show weather widget
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Weather details coming soon')),
        );
        break;
      case 'Disease Library':
        // Navigate to crop details with diseases tab active
        final plantProvider = context.read<PlantProvider>();
        if (plantProvider.crops.isNotEmpty) {
          final firstCrop = plantProvider.crops.first;
          context.push(
              '${RouteNames.cropDetails}/${firstCrop['id']}?tab=diseases',
              extra: firstCrop);
        } else {
          // Fallback to crop library if no crops available
          context.push(RouteNames.cropLibrary);
        }
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title coming soon')),
        );
    }
  }

  Widget _buildFunctionCards() {
    final functionCards = [
      {
        'title': 'Plant Details',
        'icon': Icons.eco,
        'color': AppColors.secondary,
      },
      // {
      //   'title': 'Weather',
      //   'icon': Icons.wb_sunny,
      //   'color': AppColors.primaryGreen,
      // },
      {
        'title': 'Disease Library',
        'icon': Icons.bug_report,
        'color': AppColors.accentOrange,
      },
    ];

    return Row(
      children: functionCards.map((card) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CustomCard(
              onTap: () => _handleFunctionCardTap(card['title'] as String),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (card['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusMedium),
                    ),
                    child: Icon(
                      card['icon'] as IconData,
                      color: card['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    card['title'] as String,
                    style: AppTypography.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCropLibrary() {
    return Consumer<PlantProvider>(
      builder: (context, plantProvider, child) {
        if (plantProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Crop Library',
                  style: AppTypography.headlineMedium,
                ),
                GestureDetector(
                  onTap: () => context.push(RouteNames.cropLibrary),
                  child: Text(
                    'View All',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            SizedBox(
              height: 120, // Reduced from 140 to 120 to fit optimized cards
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: plantProvider.crops.length,
                itemBuilder: (context, index) {
                  final crop = plantProvider.crops[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < plantProvider.crops.length - 1
                          ? AppDimensions.spacingMd
                          : 0,
                    ),
                    child: CropCard(
                      name: crop['name'],
                      emoji: crop['emoji'],
                      diseaseCount: crop['diseaseCount'],
                      onTap: () {
                        context.push('${RouteNames.cropDetails}/${crop['id']}',
                            extra: crop);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
