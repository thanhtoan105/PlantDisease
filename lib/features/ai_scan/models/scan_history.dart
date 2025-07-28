import 'dart:convert';

class ScanHistory {
  final int id;
  final String userId;
  final int cropId;
  final String imageUri;
  final List<dynamic> detectedDiseases;
  final double confidenceScore;
  final Map<String, dynamic>? locationData;
  final DateTime analysisDate;

  ScanHistory({
    required this.id,
    required this.userId,
    required this.cropId,
    required this.imageUri,
    required this.detectedDiseases,
    required this.confidenceScore,
    required this.locationData,
    required this.analysisDate,
  });

  factory ScanHistory.fromJson(Map<String, dynamic> json) {
    return ScanHistory(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      cropId: json['crop_id'] as int,
      imageUri: json['image_uri'] as String,
      detectedDiseases: jsonDecode(json['detected_diseases'].toString()),
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      locationData: json['location_data'] != null ? jsonDecode(json['location_data'].toString()) : null,
      analysisDate: DateTime.parse(json['analysis_date']),
    );
  }
}

