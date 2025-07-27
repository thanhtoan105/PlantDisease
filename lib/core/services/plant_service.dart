import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

/// Plant Service - Provides a clean interface for plant-related data operations
/// This service acts as a bridge between the UI components and the database
class PlantService {
  /// Get all crops for display in lists (HomeTab, CropLibrary)
  static Future<Map<String, dynamic>> getAllCrops() async {
    final crops = await SupabaseService.getAllCrops();
    return {
      'success': true,
      'data': crops,
    };
  }

  /// Get detailed crop information including diseases and growing conditions
  static Future<Map<String, dynamic>> getCropDetails(String cropId) async {
    final cropDetails = await SupabaseService.getCropById(cropId);

    return {
      'success': true,
      'data': cropDetails,
    };
  }

  /// Search crops by term
  static Future<Map<String, dynamic>> searchCrops(String searchTerm) async {
    final crops = await SupabaseService.searchCrops(searchTerm);
    return {
      'success': true,
      'data': crops,
    };
  }

  /// Search diseases by term
  static Future<Map<String, dynamic>> searchDiseases(String searchTerm) async {
    final diseases = await SupabaseService.searchDiseases(searchTerm);
    return {
      'success': true,
      'data': diseases,
    };
  }

  /// Search all content (crops and diseases)
  static Future<Map<String, dynamic>> searchAll(String searchTerm) async {
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
