import 'dart:convert';
import 'package:flutter/foundation.dart';

class ScanHistory {
  final int id;
  final String userId;
  final int? cropId; // Make nullable since it may not exist
  final String imageUrl;
  final List<dynamic> detectedDiseases;
  final double confidenceScore;
  final Map<String, dynamic>? locationData;
  final DateTime analysisDate;
  final String plantName; // We'll derive this from cropId or detected diseases
  final String plantImage; // We'll use imageUrl as a fallback

  ScanHistory({
    required this.id,
    required this.userId,
    this.cropId,
    required this.imageUrl,
    required this.detectedDiseases,
    required this.confidenceScore,
    required this.locationData,
    required this.analysisDate,
    required this.plantName,
    required this.plantImage,
  });

  // Getter for the confidence score of the first detected disease
  double get firstConfidence {
    if (detectedDiseases.isNotEmpty &&
        detectedDiseases[0] is Map &&
        detectedDiseases[0]['confidence'] != null) {
      return (detectedDiseases[0]['confidence'] as num).toDouble();
    }
    return 0.0;
  }

  // Getter for the label of the first detected disease
  String get firstLabel {
    if (detectedDiseases.isNotEmpty &&
        detectedDiseases[0] is Map &&
        detectedDiseases[0]['label'] != null) {
      return detectedDiseases[0]['label'].toString();
    }
    return '';
  }

  factory ScanHistory.fromJson(Map<String, dynamic> json) {
    // Extract detected diseases with safer parsing
    List<dynamic> detectedDiseases = [];
    try {
      if (json['detected_diseases'] != null) {
        final raw = json['detected_diseases'];
        if (raw is List) {
          detectedDiseases = raw;
        } else if (raw is String) {
          // Try to decode the string as a list
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            detectedDiseases = decoded;
          } else {
            detectedDiseases = [decoded];
          }
        } else {
          detectedDiseases = [raw];
        }
      }
    } catch (e) {
      debugPrint('Error parsing detected_diseases: $e');
      if (json['detected_diseases'] != null) {
        detectedDiseases = [json['detected_diseases'].toString()];
      }
    }

    // Try to determine plant name from detected diseases
    String plantName = 'Unknown';
    if (detectedDiseases.isNotEmpty) {
      var firstDisease = detectedDiseases.first;
      if (firstDisease is Map && firstDisease['plant'] != null) {
        plantName = firstDisease['plant'];
      } else if (firstDisease is String && firstDisease.toLowerCase().contains('apple')) {
        plantName = 'Apple Tree';
      } else if (firstDisease is String && firstDisease.toLowerCase().contains('tomato')) {
        plantName = 'Tomato';
      }
    }

    // Parse location data with better error handling
    Map<String, dynamic>? locationData;
    try {
      if (json['location_data'] != null) {
        final rawLocationData = json['location_data'];

        // If it's already a Map, use it directly
        if (rawLocationData is Map<String, dynamic>) {
          locationData = rawLocationData;
        } else if (rawLocationData is Map) {
          locationData = Map<String, dynamic>.from(rawLocationData);
        } else if (rawLocationData is String) {
          // Only parse from string if it's actually a string
          locationData = jsonDecode(rawLocationData) as Map<String, dynamic>;
        }
      }
    } catch (e) {
      debugPrint('Error parsing location_data: $e');
      debugPrint('Raw location_data: ${json['location_data']}');
      locationData = null;
    }

    return ScanHistory(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      cropId: json['crop_id'] as int?,
      imageUrl: json['image_url'] as String,
      detectedDiseases: detectedDiseases,
      confidenceScore: (json['confidence_score'] != null) ? (json['confidence_score'] as num).toDouble() : 0.0,
      locationData: locationData,
      analysisDate: DateTime.parse(json['analysis_date']),
      plantName: plantName,
      plantImage: json['image_url'] as String,
    );
  }
}
