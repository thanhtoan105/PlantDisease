import 'dart:convert';
import 'package:flutter/foundation.dart';

class ScanHistory {
  final int id;
  final String userId;
  final int? top1DiseaseId;  // Foreign key to diseases table
  final double? top1Confidence;  // Confidence score of top prediction (0-100)
  final String imageUrl;
  final List<dynamic>? relevantDiseases;  // 2nd and 3rd highest predictions only
  final String? locationData;
  final DateTime analysisDate;

  // For backward compatibility and UI display
  final String plantName;
  final String plantImage;

  // Store joined disease data
  final Map<String, dynamic>? diseaseInfo;

  ScanHistory({
    required this.id,
    required this.userId,
    this.top1DiseaseId,
    this.top1Confidence,
    required this.imageUrl,
    this.relevantDiseases,
    required this.locationData,
    required this.analysisDate,
    required this.plantName,
    required this.plantImage,
    this.diseaseInfo,
  });

  // Getter for the top confidence score
  double get topConfidence => top1Confidence ?? 0.0;

  // Getter for relevant diseases count
  int get relevantDiseasesCount => relevantDiseases?.length ?? 0;

  // Getter for disease display name
  String get diseaseDisplayName {
    if (diseaseInfo != null && diseaseInfo!['display_name'] != null) {
      return diseaseInfo!['display_name'].toString();
    }
    return plantName; // Fallback to plant name
  }

  factory ScanHistory.fromJson(Map<String, dynamic> json) {
    // Parse relevant_diseases (only 2nd and 3rd highest predictions)
    List<dynamic>? relevantDiseases;
    try {
      if (json['relevant_diseases'] != null) {
        final raw = json['relevant_diseases'];
        if (raw is List) {
          relevantDiseases = raw;
        } else if (raw is String) {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            relevantDiseases = decoded;
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing relevant_diseases: $e');
      relevantDiseases = null;
    }

    // Extract plant name from joined disease/crop data
    String plantName = 'Unknown';
    try {
      // Check if we have joined disease data
      if (json['diseases'] != null && json['diseases'] is Map) {
        final diseaseData = json['diseases'] as Map<String, dynamic>;

        // Try to get crop name from nested crops data
        if (diseaseData['crops'] != null && diseaseData['crops'] is Map) {
          final cropData = diseaseData['crops'] as Map<String, dynamic>;
          plantName = cropData['name']?.toString() ?? 'Unknown';
        } else {
          // Fallback: extract from class_name
          final className = diseaseData['class_name']?.toString() ?? '';
          if (className.contains('___')) {
            plantName = className.split('___')[0].replaceAll('_', ' ');
          }
        }
      } else if (relevantDiseases != null && relevantDiseases.isNotEmpty) {
        // Fallback to relevant diseases for plant name
        var firstDisease = relevantDiseases.first;
        if (firstDisease is Map && firstDisease['label'] != null) {
          String label = firstDisease['label'].toString();
          if (label.contains('___')) {
            plantName = label.split('___')[0].replaceAll('_', ' ');
          }
        }
      }
    } catch (e) {
      debugPrint('Error extracting plant name: $e');
    }

    // Parse location data
    String? locationData;
    try {
      if (json['location_data'] != null) {
        locationData = json['location_data'].toString();
      }
    } catch (e) {
      debugPrint('Error parsing location_data: $e');
      locationData = null;
    }

    return ScanHistory(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      top1DiseaseId: json['top1_disease_id'] as int?,
      top1Confidence: json['top1_confidence'] != null
          ? (json['top1_confidence'] as num).toDouble()
          : null,
      imageUrl: json['image_url'] as String,
      relevantDiseases: relevantDiseases,
      locationData: locationData,
      analysisDate: DateTime.parse(json['analysis_date']),
      plantName: plantName,
      plantImage: json['image_url'] as String,
      diseaseInfo: json['diseases'] != null && json['diseases'] is Map
          ? Map<String, dynamic>.from(json['diseases'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'top1_disease_id': top1DiseaseId,
      'top1_confidence': top1Confidence,
      'image_url': imageUrl,
      'relevant_diseases': relevantDiseases,
      'location_data': locationData,
      'analysis_date': analysisDate.toIso8601String(),
      'diseases': diseaseInfo,
    };
  }
}
