import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:plant_ai_disease_flutter/core/models/plant_disease_label_mapping.dart';

void main() {
  final labelsFile = File('assets/models/labels.txt');
  final mappingFile = File('assets/data/label_mapping.json');
  final sampleManifestFile = File('assets/data/sample_image_manifest.json');

  List<String> modelLabels() => labelsFile
      .readAsLinesSync()
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  group('plant disease label mapping', () {
    test('maps every model label exactly once', () {
      final labels = modelLabels();
      final mappings = PlantDiseaseLabelMapping.decodeList(
        mappingFile.readAsStringSync(),
      );

      expect(labels, hasLength(6));
      expect(mappings, hasLength(labels.length));
      expect(
        mappings.map((mapping) => mapping.modelLabel).toSet(),
        equals(labels.toSet()),
      );
      expect(
        mappings.map((mapping) => mapping.modelLabel).toSet(),
        hasLength(mappings.length),
      );
    });

    test('contains stable crop and disease ids for each class', () {
      final mappings = PlantDiseaseLabelMapping.decodeList(
        mappingFile.readAsStringSync(),
      );

      for (final mapping in mappings) {
        expect(mapping.cropId, 'durian');
        expect(mapping.diseaseId, isNotEmpty);
        expect(mapping.displayNameEn, isNotEmpty);
        expect(mapping.displayNameVi, isNotEmpty);
        expect(mapping.shortDescription, isNotEmpty);
        expect(mapping.careNote, isNotEmpty);
      }

      final healthy = mappings.singleWhere(
        (mapping) => mapping.modelLabel == 'Durian___Leaf_Healthy',
      );
      expect(healthy.isHealthy, isTrue);

      final diseases = mappings.where(
        (mapping) => mapping.modelLabel != 'Durian___Leaf_Healthy',
      );
      expect(diseases.every((mapping) => !mapping.isHealthy), isTrue);
    });
  });

  group('sample image manifest', () {
    test('contains existing sample images with expected labels', () {
      final labels = modelLabels().toSet();
      final manifest =
          (json.decode(sampleManifestFile.readAsStringSync()) as List<dynamic>)
              .cast<Map<String, dynamic>>();

      expect(manifest, hasLength(22));

      for (final sample in manifest) {
        final path = sample['path'] as String;
        final expectedLabel = sample['expectedLabel'] as String;

        expect(labels, contains(expectedLabel));
        expect(File(path).existsSync(), isTrue, reason: path);
      }

      for (final label in labels) {
        expect(
          manifest.where((sample) => sample['expectedLabel'] == label),
          isNotEmpty,
          reason: 'Missing sample images for $label',
        );
      }
    });
  });
}
