import 'package:flutter/material.dart';

class DroneCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final VoidCallback onReport;

  const DroneCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Clip the entire card to the border radius
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // By letting the Column determine its own size based on its children,
          // the card becomes truly responsive and can be used in any list or grid.
          mainAxisSize:
              MainAxisSize.min, // Ensures the column doesn't expand vertically
          children: [
            // --- IMAGE ---
            // Using AspectRatio makes the image responsive. It will maintain its
            // shape (16:9) regardless of the card's width. This is better than a fixed height.
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                imageUrl,
                width:
                    double
                        .infinity, // Ensures image fills the AspectRatio width
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  // This container no longer needs a fixed height. It fills the AspectRatio.
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  // This container also fills the AspectRatio.
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey,
                      size: 40,
                    ),
                  );
                },
              ),
            ),

            // --- TITLE ---
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // --- DESCRIPTION ---
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // --- SPACER REMOVED ---
            // The Spacer was removed. A responsive card's height should be
            // determined by its content, not by trying to fill a parent's space.
            // We'll add a simple SizedBox to ensure consistent spacing before the button.
            const SizedBox(height: 8),

            // --- BUTTON ---
            Padding(
              padding: const EdgeInsets.fromLTRB(
                10,
                0,
                10,
                10,
              ), // Adjusted padding for consistency
              child: SizedBox(
                width: double.infinity,
                height: 38,
                child: ElevatedButton(
                  onPressed: onReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Report Ticket',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
