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
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Plant Care',
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    'AI Leaf Disease Scanner',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    'Tap to scan your plant leaf',
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
              'Crops Collection',
              style: AppTypography.headlineMedium,
            ),
            Consumer<PlantProvider>(
              builder: (context, plantProvider, child) {
                // Show "View All" button only if there are more than 3 crops
                if (plantProvider.crops.length > 3) {
                  return GestureDetector(
                    onTap: () {
                      // TODO: Navigate to full crops library screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Full crops library coming soon')),
                      );
                    },
                    child: Text(
                      'View All (${plantProvider.crops.length})',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        Consumer<PlantProvider>(
          builder: (context, plantProvider, child) {
            if (plantProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Limit to maximum 3 crops for home screen display
            final displayCrops = plantProvider.crops.take(3).toList();

            if (displayCrops.isEmpty) {
              return CustomCard(
                child: SizedBox(
                  height: 100,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.eco,
                          size: 32,
                          color: AppColors.mediumGray,
                        ),
                        const SizedBox(height: AppDimensions.spacingSm),
                        Text(
                          'No crops available',
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

            return SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: displayCrops.length,
                itemBuilder: (context, index) {
                  final crop = displayCrops[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < displayCrops.length - 1
                          ? AppDimensions.spacingMd
                          : 0,
                    ),
                    child: CropCard(
                      name: crop['name'],
                      emoji: crop['emoji'],
                      diseaseCount: crop['diseaseCount'],
                      onTap: () {
                        context.push(
                            '${RouteNames.cropDetails}/${crop['id']}',
                            extra: crop
                        );
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
