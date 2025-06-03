// notification_card.dart
import 'package:flutter/material.dart';
import 'package:workflowx/core/models/notification_model.dart';
// For NotificationModel

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  }); // Added super.key

  @override
  Widget build(BuildContext context) {
    // Determine background color based on read status
    // Default to true (read) if isRead is null, to avoid unread appearance for missing data
    final bool isRead = notification.isRead ?? true;
    final Color backgroundColor =
        isRead ? Colors.white : Colors.red.shade50; // Light red for unread

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
          color: backgroundColor, // Apply dynamic background color
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Image.asset(
              'assets/logo/logo.png', // Make sure this asset exists in your project
              width: 48,
              height: 48,
              fit: BoxFit.contain,
              // Optional: Add errorBuilder for the image
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 48,
                  height: 48,
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey.shade400,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title ?? 'No Title',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.description ?? 'No description available.',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 8,
            ), // Added some spacing before the time/status
            // Time or Read Status
            // The original card showed 'Readed'/'Unread'.
            // If you want to show actual time (e.g., notification.createdAt), you'd format it here.
            // For now, keeping the read status text as per the card's structure.
            Text(
              isRead ? 'Read' : 'Unread', // Corrected "Readed" to "Read"
              style: TextStyle(
                fontSize: 12,
                color: isRead ? Colors.grey[600] : Colors.red.shade700,
                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
