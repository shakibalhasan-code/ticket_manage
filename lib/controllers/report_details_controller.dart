import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/config/app_constants.dart';
import 'package:workflowx/core/helper/pref_helper.dart';
import 'package:workflowx/core/models/message_model.dart'; // Ensure your ChatMessage model is correct
import 'package:workflowx/core/models/report_model.dart';
import 'package:workflowx/core/services/api_services.dart';

class ReportDetailsController extends GetxController {
  final ReportModel report;
  ReportDetailsController({required this.report});

  // --- STATE VARIABLES ---
  var messagesList = <ChatMessage>[].obs;
  var isLoadingMessages = true.obs;
  var isSendingMessage = false.obs;

  // --- CONTROLLERS ---
  final TextEditingController messageInputController = TextEditingController();
  final ScrollController messageScrollController = ScrollController();

  // Use 'late final' for a non-nullable contract after initialization
  late final String currentUserId;

  @override
  void onInit() {
    super.onInit();
    // Use a separate async method for initialization to keep onInit synchronous
    _initializeController();
  }

  /// Handles asynchronous initialization tasks.
  Future<void> _initializeController() async {
    // Fetch the logged-in user's ID
    final userId = await PrefHelper.getString(AppConstants.userId);

    if (userId == null || userId.isEmpty) {
      Get.snackbar(
        'Authentication Error',
        'Could not identify user. Please log in again.',
      );
      isLoadingMessages.value = false; // Stop loading state
      return;
    }
    currentUserId = userId;

    // Fetch messages only if the report status allows it
    if (report.status?.toLowerCase() == 'inprogress') {
      await fetchMessages();
    } else {
      isLoadingMessages.value = false; // Not loading if chat is disabled
    }

    // Listener to auto-scroll when new messages are added. This is a great pattern.
    messagesList.listen((_) => _scrollToBottom());
  }

  @override
  void onClose() {
    messageInputController.dispose();
    messageScrollController.dispose();
    super.onClose();
  }

  /// Scrolls the message list to the very bottom.
  void _scrollToBottom() {
    // A short delay ensures the UI has rendered the new item before scrolling.
    if (messageScrollController.hasClients) {
      Timer(const Duration(milliseconds: 200), () {
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
    // Guard clause: Prevent multiple simultaneous fetches
    if (isLoadingMessages.value && messagesList.isNotEmpty) return;

    if (report.sId == null) {
      Get.snackbar('Error', 'Cannot fetch messages: Ticket ID is missing.');
      return;
    }

    isLoadingMessages.value = true;
    try {
      // Assuming getTicketMessages constructs the URL correctly.
      final response = await ApiServices.fetchData(
        url: ApiEndpoints.getTicketMessages(report.sId!),
      );

      final decodedResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        if (decodedResponse['data'] is List) {
          final List<dynamic> messagesData = decodedResponse['data'];

          // We parse the messages from JSON into ChatMessage objects.
          // The isMyMessage logic is best handled in the UI to keep models clean.
          var parsedMessages =
              messagesData
                  .map(
                    (item) =>
                        ChatMessage.fromJson(item as Map<String, dynamic>),
                  )
                  .toList();

          // **FIX:** Your sorting logic was correct. This is more reliable than assuming API order.
          parsedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          messagesList.assignAll(parsedMessages);
        }
      } else {
        Get.snackbar(
          'API Error',
          decodedResponse['message'] ?? 'Failed to parse messages.',
        );
      }
    } catch (e) {
      Get.log('Error fetching messages: $e');
      Get.snackbar('Error', 'An unexpected error occurred: ${e.toString()}');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  /// Sends a new message to the API.
  Future<void> sendMessage() async {
    final textToSend = messageInputController.text.trim();
    if (textToSend.isEmpty || isSendingMessage.value) return;

    if (report.sId == null) {
      Get.snackbar('Error', 'Cannot send message: Ticket ID is missing.');
      return;
    }

    isSendingMessage.value = true;
    messageInputController.clear(); // Clear input immediately for better UX

    try {
      // Using the exact payload structure your previous code expected.
      final messagePayload = {
        'messages': textToSend,
        'sender': currentUserId,
        'report': report.sId,
      };

      // Assuming your ApiServices.post handles JSON encoding and headers.
      // NOTE: Using POST on a "get" endpoint is unusual but respected as per your code.
      final response = await ApiServices.post(
        url: ApiEndpoints.getTicketMessages(report.sId!),
        body: messagePayload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          // **RELIABILITY FIX:** Instead of adding one message, we re-fetch the whole list.
          // This guarantees the chat is perfectly in sync with the server and avoids
          // ordering issues or missing messages from other users.
          await fetchMessages();
        } else {
          // If the API call was successful but the business logic failed.
          Get.snackbar(
            'Error',
            responseData['message'] ?? 'Failed to send message.',
          );
          messageInputController.text = textToSend; // Restore text on failure
        }
      } else {
        // Handle HTTP errors (e.g., 404, 500)
        Get.snackbar(
          'Server Error',
          'Error ${response.statusCode}. Please try again.',
        );
        messageInputController.text = textToSend; // Restore text on failure
      }
    } catch (e) {
      Get.log('Error sending message: $e');
      Get.snackbar('Connection Error', 'An error occurred: ${e.toString()}');
      messageInputController.text = textToSend; // Restore text on failure
    } finally {
      isSendingMessage.value = false;
    }
  }
}
