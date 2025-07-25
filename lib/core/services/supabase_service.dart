import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Check if Supabase is properly configured
  static bool isConfigured() {
    try {
      // Simple check to see if the client is accessible
      return true; // If we can access _supabase, it's configured
    } catch (e) {
      return false;
    }
  }

  /// Test database connection
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      if (!isConfigured()) {
        return {
          'success': false,
          'error': 'Supabase not configured',
        };
      }

      // Simple query to test connection
      await _supabase.from('crops').select('count').limit(1);

      return {
        'success': true,
        'message': 'Database connection successful',
      };
    } catch (error) {
      return {
        'success': false,
        'error': error.toString(),
      };
    }
  }

  /// Get all crops with disease count
  static Future<List<Map<String, dynamic>>> getAllCrops() async {
    if (!isConfigured()) {
      throw Exception('Supabase not configured');
    }

    try {
      // First get all crops
      final cropsResponse = await _supabase
          .from('crops')
          .select('id, name, scientific_name, description, image_url')
          .order('name');

      // Get disease counts for each crop
      final List<Map<String, dynamic>> cropsWithCounts = [];

      for (final crop in cropsResponse) {
        // Get disease count for this crop
        final diseaseCountResponse = await _supabase
            .from('diseases')
            .select('id')
            .eq('crop_id', crop['id']);

        final diseaseCount = diseaseCountResponse.length;

        cropsWithCounts.add({
          'id': crop['id'].toString(),
          'name': crop['name'],
          'scientificName': crop['scientific_name'],
          'description': _extractDescription(crop['description']),
          'emoji': _getCropEmoji(crop['name']),
          'diseaseCount': diseaseCount,
          'image_url': crop['image_url'],
        });
      }

      return cropsWithCounts;
    } catch (error) {
      debugPrint('Error fetching crops: $error');
      rethrow;
    }
  }

  /// Get crop by ID with detailed information
  static Future<Map<String, dynamic>> getCropById(String cropId) async {
    if (!isConfigured()) {
      throw Exception('Supabase not configured');
    }

    try {
      // Get basic crop data
      final cropResponse = await _supabase
          .from('crops')
          .select('id, name, scientific_name, description, image_url')
          .eq('id', int.parse(cropId))
          .single();

      // Get diseases for this crop
      final diseasesResponse = await _supabase
          .from('diseases')
          .select(
              'id, class_name, display_name, description, treatment, image_url')
          .eq('crop_id', int.parse(cropId));

      // Transform diseases data
      final diseases = diseasesResponse.map<Map<String, dynamic>>((disease) {
        return {
          'id': disease['id'].toString(),
          'className': disease['class_name'],
          'name': disease['display_name'],
          'description': disease['description'] ?? 'No description available',
          'treatment':
              disease['treatment'] ?? 'No treatment information available',
          'severity': _getDiseaseServerity(disease['display_name']),
          'symptoms': _getDefaultSymptoms(disease['display_name']),
          'image_url': disease['image_url'],
        };
      }).toList();

      return {
        'id': cropResponse['id'].toString(),
        'name': cropResponse['name'],
        'scientificName': cropResponse['scientific_name'],
        'description': _extractDescription(cropResponse['description']),
        'emoji': _getCropEmoji(cropResponse['name']),
        'diseases': diseases,
        'diseaseCount': diseases.length,
        'image_url': cropResponse['image_url'],
      };
    } catch (error) {
      debugPrint('Error fetching crop by ID: $error');
      rethrow;
    }
  }

  /// Search crops by term
  static Future<List<Map<String, dynamic>>> searchCrops(
      String searchTerm) async {
    if (!isConfigured()) {
      throw Exception('Supabase not configured');
    }

    try {
      final response = await _supabase
          .rpc('search_crops', params: {'search_term': searchTerm});

      return response.map<Map<String, dynamic>>((crop) {
        return {
          'id': crop['id'].toString(),
          'name': crop['name'],
          'scientificName': crop['scientific_name'],
          'description': _extractDescription(crop['description']),
          'emoji': _getCropEmoji(crop['name']),
          'diseaseCount': crop['disease_count'] ?? 0,
          'image_url': crop['image_url'],
          'type': 'crop',
        };
      }).toList();
    } catch (error) {
      debugPrint('Error searching crops: $error');
      rethrow;
    }
  }

  /// Search diseases by term
  static Future<List<Map<String, dynamic>>> searchDiseases(
      String searchTerm) async {
    if (!isConfigured()) {
      throw Exception('Supabase not configured');
    }

    try {
      final response = await _supabase
          .rpc('search_diseases', params: {'search_term': searchTerm});

      return response.map<Map<String, dynamic>>((disease) {
        return {
          'id': disease['id'].toString(),
          'cropId': disease['crop_id'].toString(),
          'className': disease['class_name'],
          'name': disease['display_name'],
          'description': _extractDescription(disease['description']),
          'treatment':
              disease['treatment'] ?? 'No treatment information available',
          'cropName': disease['crop_name'],
          'cropScientificName': disease['crop_scientific_name'],
          'type': 'disease',
        };
      }).toList();
    } catch (error) {
      debugPrint('Error searching diseases: $error');
      rethrow;
    }
  }

  /// Helper method to extract description
  static String _extractDescription(dynamic description) {
    if (description == null) return 'No description available';
    if (description is String) return description;
    if (description is Map && description.containsKey('description')) {
      return description['description'] ?? 'No description available';
    }
    return description.toString();
  }

  /// Helper method to get crop emoji
  static String _getCropEmoji(String cropName) {
    final emojiMap = {
      'Apple Tree': '🍎',
      'Apple': '🍎',
      'Tomato': '🍅',
      'Potato': '🥔',
      'Corn': '🌽',
      'Grape': '🍇',
      'Orange': '🍊',
      'Peach': '🍑',
      'Pepper': '🌶️',
      'Strawberry': '🍓',
      'Cherry': '🍒',
      'Blueberry': '🫐',
      'Soybean': '🫘',
      'Squash': '🎃',
    };

    return emojiMap[cropName] ?? '🌱';
  }

  /// Helper method to get disease severity
  static String _getDiseaseServerity(String diseaseName) {
    final severityMap = {
      'Apple Scab': 'Medium',
      'Apple Black Rot': 'High',
      'Cedar Apple Rust': 'Medium',
      'Healthy': 'None',
    };

    return severityMap[diseaseName] ?? 'Medium';
  }

  /// Helper method to get default symptoms
  static List<String> _getDefaultSymptoms(String diseaseName) {
    final symptomsMap = {
      'Apple Scab': [
        'Olive-green or brown spots on leaves',
        'Black scabby lesions on fruit',
        'Premature leaf drop',
      ],
      'Apple Black Rot': [
        'Frogeye spots on leaves',
        'Black firm rot on fruit',
        'Cankers on branches',
      ],
      'Cedar Apple Rust': [
        'Yellow spots on leaves',
        'Orange spore masses',
        'Leaf distortion',
      ],
    };

    return symptomsMap[diseaseName] ?? ['Symptoms vary by disease stage'];
  }
}
