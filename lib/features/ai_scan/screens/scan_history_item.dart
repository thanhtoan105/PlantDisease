import 'dart:convert';
import 'package:flutter/material.dart';
import 'scan_history_detail_screen.dart';

class ScanHistoryItem extends StatelessWidget {
  final int scanId;
  final String imageUrl;
  final String plantName;
  final String location;
  final String timeAgo;
  final String detectedDiseasesJson;

  const ScanHistoryItem({
    super.key,
    required this.scanId,
    required this.imageUrl,
    required this.plantName,
    required this.location,
    required this.timeAgo,
    required this.detectedDiseasesJson,
  });

  @override
  Widget build(BuildContext context) {
    // Parse detectedDiseasesJson
    List<dynamic> detectedDiseases = [];
    String diseaseResult = '';
    double confidenceScore = 0.0;
    try {
      detectedDiseases = jsonDecode(detectedDiseasesJson);
      if (detectedDiseases.isNotEmpty) {
        diseaseResult = detectedDiseases[0]['disease']?.toString().trim() ?? '';
        confidenceScore = (detectedDiseases[0]['confidence'] as num?)?.toDouble() ?? 0.0;
      }
    } catch (e) {
      // fallback if parsing fails
      diseaseResult = '';
      confidenceScore = 0.0;
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ScanHistoryDetailScreen(
                scanId: scanId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'scan_image_$scanId',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 48,
                          height: 48,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plantName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                location,
                                style: const TextStyle(color: Colors.black54, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('•', style: TextStyle(color: Colors.black26)),
                            const SizedBox(width: 8),
                            Text(
                              timeAgo,
                              style: const TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Arrow button to indicate clickability and view details
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.black54,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                diseaseResult,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.verified_user, size: 18, color: Colors.teal),
                  const SizedBox(width: 4),
                  Text(
                    '${(confidenceScore * 100).toStringAsFixed(1)}% (confidence)',
                    style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
