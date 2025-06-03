// report_details_controller.dart (or a separate chat_message_model.dart)

import 'package:intl/intl.dart'; // For parsing dates

class ChatMessage {
  final String id;
  final String roomId; // This is your ticketId
  final String senderId; // ID of the user/admin who sent the message
  final String messageContent; // Content of the message
  final DateTime createdAt;
  final bool isDeleted;

  // Helper to determine if the message is from the support/admin side
  // This will be set in the controller after fetching current user's ID and ticket owner's ID
  bool isSupportMessage;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.messageContent,
    required this.createdAt,
    this.isDeleted = false,
    this.isSupportMessage =
        false, // Default to false, will be set by controller
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id:
          json['_id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(), // Fallback ID
      roomId: json['roomId'] as String? ?? '',
      senderId: json['sender'] as String? ?? '', // API uses 'sender'
      messageContent:
          json['messages'] as String? ?? '', // API uses 'messages' for content
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  // For sending a message, you might not need all fields
  Map<String, dynamic> toJsonForSend(String currentUserId) {
    return {
      'roomId': roomId, // or ticketId
      'sender': currentUserId, // The ID of the person sending
      'messages': messageContent,
    };
  }
}
