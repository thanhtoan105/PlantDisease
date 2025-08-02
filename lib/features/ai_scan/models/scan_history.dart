import 'dart:convert';

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
      print('Error parsing detected_diseases: $e');
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
        var rawLocationData = json['location_data'].toString();
        // Check if it starts with '{' - if not, try to format it
        if (!rawLocationData.trim().startsWith('{')) {
          // Try to make it a proper JSON - if it's a key-value format
          if (rawLocationData.contains(':')) {
            rawLocationData = '{' + rawLocationData + '}';
          }
        }
        locationData = jsonDecode(rawLocationData);
      }
    } catch (e) {
      print('Error parsing location_data: $e');
      // Create a basic location object from the error message if possible
      if (json['location_data'] != null) {
        String locText = json['location_data'].toString();
        locationData = {'raw_data': locText};

        // Try to extract latitude and longitude using regex
        RegExp latRegex = RegExp(r'latitude: ([\d\.]+)');
        RegExp lonRegex = RegExp(r'longitude: ([\d\.]+)');

        var latMatch = latRegex.firstMatch(locText);
        var lonMatch = lonRegex.firstMatch(locText);

        if (latMatch != null && lonMatch != null) {
          locationData['latitude'] = double.tryParse(latMatch.group(1) ?? '0') ?? 0;
          locationData['longitude'] = double.tryParse(lonMatch.group(1) ?? '0') ?? 0;
          locationData['address'] = 'Location data available';
        }
      }
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
