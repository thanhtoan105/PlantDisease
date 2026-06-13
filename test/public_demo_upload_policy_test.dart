import 'package:flutter_test/flutter_test.dart';
import 'package:plant_ai_disease_flutter/features/public_demo/models/public_demo_upload_policy.dart';

void main() {
  group('validatePublicDemoUpload', () {
    test('accepts supported image extensions within the size limit', () {
      for (final fileName in [
        'durian-leaf.jpg',
        'durian-leaf.jpeg',
        'durian-leaf.png',
        'durian-leaf.webp',
        'DURIAN-LEAF.PNG',
      ]) {
        final result = validatePublicDemoUpload(
          fileName: fileName,
          fileSizeBytes: 512 * 1024,
        );

        expect(result.isValid, isTrue, reason: fileName);
        expect(result.message, isNull, reason: fileName);
      }
    });

    test('rejects unsupported file extensions', () {
      final result = validatePublicDemoUpload(
        fileName: 'notes.pdf',
        fileSizeBytes: 1200,
      );

      expect(result.isValid, isFalse);
      expect(result.message, 'Please choose a JPG, PNG, or WebP image.');
    });

    test('rejects empty files', () {
      final result = validatePublicDemoUpload(
        fileName: 'empty-leaf.png',
        fileSizeBytes: 0,
      );

      expect(result.isValid, isFalse);
      expect(result.message, 'The selected image is empty. Choose another file.');
    });

    test('rejects files over 5 MB', () {
      final result = validatePublicDemoUpload(
        fileName: 'large-leaf.webp',
        fileSizeBytes: PublicDemoUploadPolicy.maxFileSizeBytes + 1,
      );

      expect(result.isValid, isFalse);
      expect(
        result.message,
        'The selected image is larger than 5 MB. Compress it or choose a smaller file.',
      );
    });
  });
}
