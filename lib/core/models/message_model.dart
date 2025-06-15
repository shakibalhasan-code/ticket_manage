// core/models/message_model.dart

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String? senderName; // Added to store the sender's name if available
  final String messageContent;
  final DateTime createdAt;
  final bool isDeleted;

  // This is a transient field set by the controller
  // True if the message is from the currently logged-in user
  bool isMyMessage;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    this.senderName, // Now part of the constructor
    required this.messageContent,
    required this.createdAt,
    this.isDeleted = false,
    this.isMyMessage = false,
  });

  // --- FIX: This factory is now robust and will not crash ---
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    String parsedSenderId;
    String? parsedSenderName;

    // Check if 'sender' is a populated object or a simple String ID
    if (json['sender'] is Map<String, dynamic>) {
      // It's a populated object, extract the ID and name
      parsedSenderId = json['sender']['_id'] ?? '';
      parsedSenderName =
          json['sender']['name']; // Or 'fullName', 'username', etc.
    } else {
      // It's just a String ID
      parsedSenderId = json['sender'] ?? '';
      parsedSenderName = null; // No name available
    }

    return ChatMessage(
      id: json['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      roomId:
          json['report'] ??
          json['roomId'] ??
          '', // Handles both 'report' and 'roomId' keys
      senderId: parsedSenderId,
      senderName: parsedSenderName,
      messageContent: json['messages'] ?? '', // API uses 'messages'
      createdAt: _parseDateTime(json['createdAt']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  // Helper function to safely parse DateTime from JSON
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) {
      return DateTime.now(); // Fallback to current time
    }
    if (dateValue is String) {
      return DateTime.tryParse(dateValue) ?? DateTime.now();
    }
    // You could add more checks here if needed (e.g., for integer timestamps)
    return DateTime.now();
  }
}
