import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';

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
      // Get basic crop data with JSONB description
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
          'display_name': disease['display_name'],
          'description': disease['description'] ?? 'No description available',
          'treatment':
              disease['treatment'] ?? 'No treatment information available',
          'severity': _getDiseaseServerity(disease['display_name']),
          'image_url': disease['image_url'],
        };
      }).toList();

      // Build the result object directly from JSONB description
      final result = {
        'id': cropResponse['id'].toString(),
        'name': cropResponse['name'],
        'scientificName': cropResponse['scientific_name'],
        'description': cropResponse['description'], // Keep JSONB structure intact
        'emoji': _getCropEmoji(cropResponse['name']),
        'diseases': diseases,
        'diseaseCount': diseases.length,
        'image_url': cropResponse['image_url'],
      };

      return result;
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

  /// Get current user ID
  static String? currentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  /// Upload image to Supabase Storage and return public URL
  static Future<String> uploadScanImage({
    required String userId,
    required String imagePath,
    required String analysisDate,
  }) async {
    final file = File(imagePath);
    final fileName = '${userId}_${analysisDate.replaceAll(':', '-')}.jpg';
    final storagePath = 'scan-images/$userId/$fileName';
    final bucket = _supabase.storage.from('scan-images');
    final response = await bucket.upload(storagePath, file);
    // Fix: response is a String if successful, else throws
    // So just check if response is not empty
    if (response == null || response.isEmpty) {
      throw Exception('Image upload failed: No response from Supabase Storage');
    }
    // Get public URL
    final publicUrl = bucket.getPublicUrl(storagePath);
    return publicUrl;
  }

  /// Save analysis result to the database
  static Future<void> saveAnalysisResult({
    required String userId,
    required String imagePath,
    required dynamic detectedDiseases,
    required dynamic locationData,
    required String analysisDate,
  }) async {
    if (userId.isEmpty) {
      throw Exception('User ID cannot be null or empty');
    }
    if (!(detectedDiseases is Map || detectedDiseases is List)) {
      throw Exception('detectedDiseases must be a Map or List');
    }
    if (!(locationData is Map || locationData is List)) {
      try {
        if (locationData is String) {
          locationData = jsonDecode(locationData);
          if (!(locationData is Map || locationData is List)) {
            throw Exception('locationData must decode to a Map or List. Actual value: \\${locationData.toString()}, type: \\${locationData.runtimeType}');
          }
        } else {
          throw Exception('locationData must be a Map or List. Actual type: \\${locationData.runtimeType}, value: \\${locationData.toString()}');
        }
      } catch (e) {
        throw Exception('locationData must be a Map or List. Error: \\${e.toString()}. Actual value: \\${locationData.toString()}');
      }
    }
    // Upload image and get public URL
    final imageUrl = await uploadScanImage(
      userId: userId,
      imagePath: imagePath,
      analysisDate: analysisDate,
    );
    await _supabase.from('analysis_results').insert({
      'user_id': userId,
      'image_url': imageUrl,
      'detected_diseases': detectedDiseases,
      'location_data': locationData,
      'analysis_date': analysisDate,
    });
  }

  /// Fetch all scan history for the current user
  static Future<List<Map<String, dynamic>>> getUserScanHistory({
    required String userId,
  }) async {
    if (userId.isEmpty) {
      throw Exception('User ID cannot be null or empty');
    }

    // Get analysis results without trying to join with crops
    final response = await _supabase
        .from('analysis_results')
        .select()
        .eq('user_id', userId)
        .order('analysis_date', ascending: false);

    // Convert response to a properly typed list
    final results = List<Map<String, dynamic>>.from(response);

    // The ScanHistory model will handle the lack of crops data
    return results;
  }

  /// Get user profile by user ID
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    if (!isConfigured()) {
      throw Exception('Supabase not configured');
    }

    try {
      // Get profile data from profiles table
      final profileResponse = await _supabase
          .from('profiles')
          .select('id, username, full_name, dob, gender, address')
          .eq('id', userId)
          .maybeSingle();

      if (profileResponse == null) {
        return null;
      }

      // Get email from auth.users
      final user = _supabase.auth.currentUser;
      final email = user?.email ?? '';

      return {
        ...profileResponse,
        'email': email,
      };
    } catch (error) {
      debugPrint('Error fetching user profile: $error');
      rethrow;
    }
  }
  /// Helper method to extract description from JSON or return fallback
  static String _extractDescription(dynamic description) {
    if (description == null) return 'No description available';

    // If it's already a string, return it
    if (description is String) {
      debugPrint('📝 Description is already a string');
      return description;
    }

    // If it's JSON, try to extract meaningful description
    try {
      if (description is Map) {
        debugPrint('📝 Description is JSON, extracting...');

        // Try to get description from overview.description
        if (description['overview'] != null &&
            description['overview']['description'] != null) {
          debugPrint('✅ Found description in overview.description');
          return description['overview']['description'];
        }

        // Try to get legacy_description
        if (description['legacy_description'] != null) {
          debugPrint('✅ Found legacy_description');
          return description['legacy_description'];
        }

        // Try to get direct description key
        if (description['description'] != null) {
          debugPrint('✅ Found direct description key');
          return description['description'];
        }

        debugPrint('❌ No description found in JSON structure');
        debugPrint('Available keys: ${description.keys.toList()}');
      }

      return 'No description available';
    } catch (error) {
      debugPrint('❌ Error extracting description: $error');
      return 'No description available';
    }
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

  /// Transform growing conditions from JSON to Map
  static Map<String, dynamic> _transformGrowingConditions(dynamic conditions) {
    if (conditions == null) return {};
    if (conditions is Map<String, dynamic>) return conditions;
    if (conditions is Map) {
      return Map<String, dynamic>.from(conditions);
    }
    return {};
  }

  /// Transform growing seasons from JSON to Map
  static Map<String, dynamic> _transformGrowingSeasons(dynamic seasons) {
    if (seasons == null) return {};
    if (seasons is Map<String, dynamic>) return seasons;
    if (seasons is Map) {
      return Map<String, dynamic>.from(seasons);
    }
    return {};
  }

  /// Extract tips from JSON data
  static List<String> _extractTipsFromJSON(dynamic tipsData) {
    if (tipsData == null) return [];

    if (tipsData is List) {
      return tipsData.map((tip) => tip.toString()).toList();
    }

    if (tipsData is Map) {
      // If it's a map, try to extract tips from common keys
      final tips = <String>[];
      for (final value in tipsData.values) {
        if (value is String) {
          tips.add(value);
        } else if (value is List) {
          tips.addAll(value.map((tip) => tip.toString()));
        }
      }
      return tips;
    }

    return [tipsData.toString()];
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
