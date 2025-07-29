import 'package:flutter/material.dart';

class ScanHistoryItem extends StatelessWidget {
  final String imageUrl;
  final String plantName;
  final String location;
  final String timeAgo;
  final String diseaseResult;
  final double confidenceScore;

  const ScanHistoryItem({
    Key? key,
    required this.imageUrl,
    required this.plantName,
    required this.location,
    required this.timeAgo,
    required this.diseaseResult,
    required this.confidenceScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
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
                  '${(confidenceScore * 100).toStringAsFixed(1)}% (chẩn đoán)',
                  style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
