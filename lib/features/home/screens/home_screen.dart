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

  Widget _buildCropLibrary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Crops',
              style: AppTypography.headlineMedium,
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        Consumer<PlantProvider>(
          builder: (context, plantProvider, child) {
            if (plantProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SizedBox(
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
            );
          },
        ),
      ],
    );
  }
}
