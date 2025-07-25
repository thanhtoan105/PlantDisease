import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

/// Plant Service - Provides a clean interface for plant-related data operations
/// This service acts as a bridge between the UI components and the database
class PlantService {
  /// Get all crops for display in lists (HomeTab, CropLibrary)
  static Future<Map<String, dynamic>> getAllCrops() async {
    try {
      final crops = await SupabaseService.getAllCrops();
      return {
        'success': true,
        'data': crops,
      };
    } catch (error) {
      debugPrint('PlantService - Error fetching crops: $error');
      // Return fallback data when database is unavailable
      return {
        'success': false,
        'error': error.toString(),
        'data': getFallbackCrops(),
      };
    }
  }

  /// Get detailed crop information including diseases and growing conditions
  static Future<Map<String, dynamic>> getCropDetails(String cropId) async {
    try {
      final cropDetails = await SupabaseService.getCropById(cropId);

      // Add additional data that might not be in database
      final enrichedDetails = {
        ...cropDetails,
        'growingConditions': cropDetails['growingConditions'] ??
            getGrowingConditions(cropDetails['name']),
        'seasons':
            cropDetails['seasons'] ?? getGrowingSeasons(cropDetails['name']),
        'tips': cropDetails['tips'] ?? getGrowingTips(cropDetails['name']),
      };

      return {
        'success': true,
        'data': enrichedDetails,
      };
    } catch (error) {
      debugPrint('PlantService - Error fetching crop details: $error');
      return {
        'success': false,
        'error': error.toString(),
        'data': getFallbackCropDetails(cropId),
      };
    }
  }

  /// Search crops by term
  static Future<Map<String, dynamic>> searchCrops(String searchTerm) async {
    try {
      final crops = await SupabaseService.searchCrops(searchTerm);
      return {
        'success': true,
        'data': crops,
      };
    } catch (error) {
      debugPrint('PlantService - Error searching crops: $error');
      // Return empty list to force database usage
      return {
        'success': false,
        'error': error.toString(),
        'data': <Map<String, dynamic>>[],
      };
    }
  }

  /// Search diseases by term
  static Future<Map<String, dynamic>> searchDiseases(String searchTerm) async {
    try {
      final diseases = await SupabaseService.searchDiseases(searchTerm);
      return {
        'success': true,
        'data': diseases,
      };
    } catch (error) {
      debugPrint('PlantService - Error searching diseases: $error');
      return {
        'success': false,
        'error': error.toString(),
        'data': <Map<String, dynamic>>[],
      };
    }
  }

  /// Search all content (crops and diseases)
  static Future<Map<String, dynamic>> searchAll(String searchTerm) async {
    try {
      final cropsResult = await searchCrops(searchTerm);
      final diseasesResult = await searchDiseases(searchTerm);

      final allResults = <Map<String, dynamic>>[];

      if (cropsResult['success']) {
        allResults.addAll(List<Map<String, dynamic>>.from(cropsResult['data']));
      }

      if (diseasesResult['success']) {
        allResults
            .addAll(List<Map<String, dynamic>>.from(diseasesResult['data']));
      }

      return {
        'success': true,
        'data': allResults,
      };
    } catch (error) {
      debugPrint('PlantService - Error searching all: $error');
      return {
        'success': false,
        'error': error.toString(),
        'data': <Map<String, dynamic>>[],
      };
    }
  }

  /// Get growing conditions for a crop
  static Map<String, dynamic> getGrowingConditions(String cropName) {
    final conditionsMap = {
      'Apple Tree': {
        'temperature': '15-25°C',
        'humidity': '60-70%',
        'sunlight': 'Full sun (6-8 hours)',
        'soil': 'Well-drained, slightly acidic',
        'water': 'Regular, deep watering',
      },
      'Tomato': {
        'temperature': '18-24°C',
        'humidity': '65-75%',
        'sunlight': 'Full sun (6-8 hours)',
        'soil': 'Rich, well-drained',
        'water': 'Consistent moisture',
      },
    };

    return conditionsMap[cropName] ??
        {
          'temperature': 'Varies',
          'humidity': 'Moderate',
          'sunlight': 'Full to partial sun',
          'soil': 'Well-drained',
          'water': 'Regular watering',
        };
  }

  /// Get growing seasons for a crop
  static List<String> getGrowingSeasons(String cropName) {
    final seasonsMap = {
      'Apple Tree': ['Spring', 'Summer', 'Fall'],
      'Tomato': ['Spring', 'Summer'],
      'Potato': ['Spring', 'Fall'],
      'Corn': ['Spring', 'Summer'],
    };

    return seasonsMap[cropName] ?? ['Spring', 'Summer'];
  }

  /// Get growing tips for a crop
  static List<Map<String, dynamic>> getGrowingTips(String cropName) {
    final tipsMap = {
      'Apple Tree': [
        {
          'category': 'watering',
          'title': 'Deep Watering',
          'description':
              'Water deeply but less frequently to encourage deep root growth.',
        },
        {
          'category': 'pruning',
          'title': 'Annual Pruning',
          'description':
              'Prune in late winter to improve air circulation and fruit quality.',
        },
        {
          'category': 'fertilizing',
          'title': 'Balanced Fertilizer',
          'description':
              'Apply balanced fertilizer in early spring before bud break.',
        },
      ],
      'Tomato': [
        {
          'category': 'watering',
          'title': 'Consistent Moisture',
          'description':
              'Maintain consistent soil moisture to prevent blossom end rot.',
        },
        {
          'category': 'support',
          'title': 'Staking',
          'description':
              'Stake or cage plants early to support heavy fruit loads.',
        },
      ],
    };

    return tipsMap[cropName] ??
        [
          {
            'category': 'general',
            'title': 'Basic Care',
            'description':
                'Provide adequate water, sunlight, and nutrients for healthy growth.',
          },
        ];
  }

  /// Check if the service is properly configured
  static bool isConfigured() {
    return SupabaseService.isConfigured();
  }

  /// Test database connection
  static Future<Map<String, dynamic>> testConnection() async {
    return await SupabaseService.testConnection();
  }

  /// Get fallback crop details when database is unavailable
  static Map<String, dynamic> getFallbackCropDetails(String cropId) {
    final fallbackDetails = {
      '1': {
        'id': '1',
        'name': 'Apple Tree',
        'scientificName': 'Malus domestica',
        'description':
            'Apple trees are deciduous trees in the rose family best known for their sweet, pomaceous fruit, the apple. They are widely cultivated worldwide and are susceptible to various fungal diseases.',
        'emoji': '🍎',
        'diseases': [
          {
            'id': '101',
            'className': 'Apple___Apple_scab',
            'name': 'Apple Scab',
            'description':
                'Caused by the fungus Venturia inaequalis. Symptoms include olive-green or brown spots on leaves and fruit, which later become black and scabby.',
            'treatment':
                'Apply fungicides like captan, myclobutanil, or propiconazole. Remove fallen leaves and improve air circulation.',
            'severity': 'High',
            'symptoms': [
              'Dark spots on leaves',
              'Scabby fruit lesions',
              'Premature leaf drop',
            ],
          },
          {
            'id': '102',
            'className': 'Apple___Black_rot',
            'name': 'Apple Black Rot',
            'description':
                'Caused by the fungus Botryosphaeria obtusa. On leaves, it creates "frogeye" spots with a tan center. On fruit, it causes a black, firm rot that spreads rapidly.',
            'treatment':
                'Remove infected plant parts, apply copper-based fungicides, and ensure proper pruning for air circulation.',
            'severity': 'Medium',
            'symptoms': [
              'Frogeye spots on leaves',
              'Black rot on fruit',
              'Rapid spread of infection',
            ],
          },
          {
            'id': '103',
            'className': 'Apple___Cedar_apple_rust',
            'name': 'Cedar Apple Rust',
            'description':
                'Caused by the fungus Gymnosporangium juniperi-virginianae. On apple leaves, it creates small, yellow spots that enlarge and turn bright orange with black spots in the center.',
            'treatment':
                'Remove nearby cedar trees if possible, apply preventive fungicides in spring, and choose resistant apple varieties.',
            'severity': 'Medium',
            'symptoms': [
              'Yellow spots on leaves',
              'Orange discoloration',
              'Black spots in center',
            ],
          },
          {
            'id': '104',
            'className': 'Apple___healthy',
            'name': 'Healthy',
            'description':
                'The leaf shows no visible signs of common diseases. The surface is green, with no spots, distortions, or unusual discoloration.',
            'treatment':
                'Continue regular care: proper watering, fertilization, and monitoring for early disease detection.',
            'severity': 'None',
            'symptoms': [
              'Green, healthy appearance',
              'No visible spots or discoloration',
              'Normal leaf structure',
            ],
          },
        ],
        'diseaseCount': 4,
        'growingConditions': getGrowingConditions('Apple Tree'),
        'seasons': getGrowingSeasons('Apple Tree'),
        'tips': getGrowingTips('Apple Tree'),
        'image_url':
            'https://images.pexels.com/photos/347926/pexels-photo-347926.jpeg?auto=compress&cs=tinysrgb&w=400',
      },
    };

    return fallbackDetails[cropId] ??
        {
          'id': cropId,
          'name': 'Unknown Crop',
          'scientificName': 'Not available',
          'description': 'Detailed information not available for this crop.',
          'emoji': '🌱',
          'diseases': <Map<String, dynamic>>[],
          'diseaseCount': 0,
          'growingConditions': getGrowingConditions('Unknown'),
          'seasons': getGrowingSeasons('Unknown'),
          'tips': getGrowingTips('Unknown'),
          'image_url': '',
        };
  }

  /// Get fallback crops list when database is unavailable
  static List<Map<String, dynamic>> getFallbackCrops() {
    return [
      {
        'id': '1',
        'name': 'Apple Tree',
        'scientificName': 'Malus domestica',
        'description':
            'A popular fruit tree susceptible to various fungal diseases.',
        'emoji': '🍎',
        'diseaseCount': 4,
        'image_url':
            'https://images.pexels.com/photos/347926/pexels-photo-347926.jpeg?auto=compress&cs=tinysrgb&w=400',
      },
    ];
  }
}
