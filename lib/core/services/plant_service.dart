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
      // Return empty list instead of fallback data to force database usage
      return {
        'success': false,
        'error': error.toString(),
        'data': <Map<String, dynamic>>[],
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
        'data': null,
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
}
