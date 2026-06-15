import 'dart:convert';

class PlantDiseaseLabelMapping {
  const PlantDiseaseLabelMapping({
    required this.modelLabel,
    required this.cropId,
    required this.diseaseId,
    required this.displayNameEn,
    required this.displayNameVi,
    required this.isHealthy,
    required this.shortDescription,
    required this.careNote,
  });

  final String modelLabel;
  final String cropId;
  final String diseaseId;
  final String displayNameEn;
  final String displayNameVi;
  final bool isHealthy;
  final String shortDescription;
  final String careNote;

  factory PlantDiseaseLabelMapping.fromJson(Map<String, dynamic> json) {
    return PlantDiseaseLabelMapping(
      modelLabel: _readString(json, 'modelLabel'),
      cropId: _readString(json, 'cropId'),
      diseaseId: _readString(json, 'diseaseId'),
      displayNameEn: _readString(json, 'displayNameEn'),
      displayNameVi: _readString(json, 'displayNameVi'),
      isHealthy: _readBool(json, 'isHealthy'),
      shortDescription: _readString(json, 'shortDescription'),
      careNote: _readString(json, 'careNote'),
    );
  }

  static List<PlantDiseaseLabelMapping> decodeList(String source) {
    final decoded = json.decode(source);
    if (decoded is! List) {
      throw const FormatException('Label mapping must be a JSON array.');
    }

    return decoded.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
            'Each label mapping row must be an object.');
      }
      return PlantDiseaseLabelMapping.fromJson(item);
    }).toList(growable: false);
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$key must be a non-empty string.');
    }
    return value;
  }

  static bool _readBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! bool) {
      throw FormatException('$key must be a boolean.');
    }
    return value;
  }
}
