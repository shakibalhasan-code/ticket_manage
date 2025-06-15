import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/config/app_constants.dart';
import 'package:workflowx/core/helper/pref_helper.dart';
import 'package:workflowx/core/models/message_model.dart'; // Your corrected ChatMessage model
import 'package:workflowx/core/models/report_model.dart';
import 'package:workflowx/core/services/api_services.dart';

class ReportDetailsController extends GetxController {
  final ReportModel report;
  ReportDetailsController({required this.report});

  // STATE VARIABLES
  var messagesList = <ChatMessage>[].obs;
  var isLoadingMessages = true.obs;
  var isSendingMessage = false.obs;

  // CONTROLLERS
  final TextEditingController messageInputController = TextEditingController();
  final ScrollController messageScrollController = ScrollController();

  String? currentUserId;

  @override
  void onInit() async {
    super.onInit();
    // Fetch the logged-in user's ID to determine who sent which message
    currentUserId = await PrefHelper.getString(AppConstants.userId);
    if (currentUserId == null) {
      Get.snackbar('Error', 'User not identified. Please log in again.');
      isLoadingMessages.value = false;
      return;
    }

    // Fetch the initial list of messages
    fetchMessages();

    // Add a listener to automatically scroll to the bottom when new messages arrive
    messagesList.listen((_) => _scrollToBottom());
  }

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    messageInputController.dispose();
    messageScrollController.dispose();
    super.onClose();
  }

  /// Scrolls the message list to the very bottom.
  void _scrollToBottom() {
    // Wait a short moment for the UI to build before trying to scroll
    if (messageScrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        messageScrollController.animateTo(
          messageScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  /// Fetches all messages for the current ticket from the API.
  Future<void> fetchMessages() async {
    if (report.sId == null) {
      Get.snackbar('Error', 'Ticket ID is missing.');
      return;
    }

    try {
      isLoadingMessages.value = true;
      final response = await ApiServices.fetchData(
        url: ApiEndpoints.getTicketMessages(report.sId!),
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse['success'] == true &&
            decodedResponse['data'] is List) {
          final List<dynamic> messagesData = decodedResponse['data'];

          if (messagesData.isNotEmpty) {
            final parsedMessages =
                messagesData.map((item) {
                  final msg = ChatMessage.fromJson(
                    item as Map<String, dynamic>,
                  );
                  // ** KEY LOGIC: Determine if the message is from the logged-in user **
                  msg.isMyMessage = msg.senderId == currentUserId;
                  return msg;
                }).toList();

            // Sort by creation date to ensure correct order
            parsedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            messagesList.assignAll(parsedMessages);
          } else {
            messagesList
                .clear(); // Ensure the list is empty if API returns empty
          }
        } else {
          Get.snackbar(
            'API Error',
            decodedResponse['message'] ?? 'Failed to parse messages.',
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load messages. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: ${e.toString()}');
      print('Error fetching messages: $e');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  /// Sends a new message and uses an optimistic UI update.
  Future<void> sendMessage() async {
    final text = messageInputController.text.trim();
    if (text.isEmpty || isSendingMessage.value) return;

    if (report.sId == null || currentUserId == null) {
      Get.snackbar(
        'Error',
        'Cannot send message: User or Ticket ID is missing.',
      );
      return;
    }

    isSendingMessage.value = true;

    // ** OPTIMISTIC UI: Create a temporary message to show in the UI immediately. **
    final optimisticMessage = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      roomId: report.sId!,
      senderId: currentUserId!,
      messageContent: text,
      createdAt: DateTime.now(),
      isMyMessage: true, // It's always our message
    );

    messagesList.add(optimisticMessage);
    messageInputController.clear();
    _scrollToBottom();

    try {
      // This is the data payload your API expects
      final messageToSend = {
        'messages': text,
        'sender': currentUserId,
        'report': report.sId, // The ticket/room ID
      };

      final response = await ApiServices.post(
        url: ApiEndpoints.getTicketMessages(report.sId!),
        body: messageToSend,
      );

      // ** IMPORTANT: Remove the temporary message regardless of the outcome **
      messagesList.removeWhere((m) => m.id == optimisticMessage.id);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          // Add the final, confirmed message from the server
          final newMessage = ChatMessage.fromJson(responseData['data']);
          newMessage.isMyMessage = newMessage.senderId == currentUserId;
          messagesList.add(newMessage);
        } else {
          Get.snackbar(
            'Error',
            responseData['message'] ?? 'Failed to send message.',
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Server error: ${response.statusCode}. Please try again.',
        );
      }
    } catch (e) {
      // If an exception occurs, also remove the temporary message
      messagesList.removeWhere((m) => m.id == optimisticMessage.id);
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
      print('Error sending message: $e');
    } finally {
      isSendingMessage.value = false;
    }
  }
}
