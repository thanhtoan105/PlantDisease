class PublicDemoUploadPolicy {
  static const int maxFileSizeBytes = 5 * 1024 * 1024;
  static const Set<String> supportedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
  };
}

class PublicDemoUploadValidationResult {
  const PublicDemoUploadValidationResult._({
    required this.isValid,
    this.message,
  });

  const PublicDemoUploadValidationResult.valid()
      : this._(isValid: true);

  const PublicDemoUploadValidationResult.invalid(String message)
      : this._(isValid: false, message: message);

  final bool isValid;
  final String? message;
}

PublicDemoUploadValidationResult validatePublicDemoUpload({
  required String fileName,
  required int fileSizeBytes,
}) {
  if (fileSizeBytes <= 0) {
    return const PublicDemoUploadValidationResult.invalid(
      'The selected image is empty. Choose another file.',
    );
  }

  if (fileSizeBytes > PublicDemoUploadPolicy.maxFileSizeBytes) {
    return const PublicDemoUploadValidationResult.invalid(
      'The selected image is larger than 5 MB. Compress it or choose a smaller file.',
    );
  }

  final extension = fileName.split('.').last.toLowerCase();
  if (extension == fileName.toLowerCase() ||
      !PublicDemoUploadPolicy.supportedExtensions.contains(extension)) {
    return const PublicDemoUploadValidationResult.invalid(
      'Please choose a JPG, PNG, or WebP image.',
    );
  }

  return const PublicDemoUploadValidationResult.valid();
}
