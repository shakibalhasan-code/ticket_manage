import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/config/app_constants.dart';
import 'package:workflowx/core/helper/pref_helper.dart';
import 'package:workflowx/core/models/message_model.dart';
import 'package:workflowx/core/models/report_model.dart'; // Your ReportModel
import 'package:workflowx/core/services/api_services.dart';

class ReportDetailsController extends GetxController {
  final ReportModel report;
  ReportDetailsController({required this.report});

  var messagesList = <ChatMessage>[].obs;
  var isLoadingMessages = true.obs;
  var isSendingMessage = false.obs;
  final TextEditingController messageInputController = TextEditingController();
  // Renamed for clarity to match the UI comment
  final ScrollController messageScrollController = ScrollController();

  String? currentUserId;

  @override
  void onInit() async {
    super.onInit();
    currentUserId = await PrefHelper.getString(AppConstants.userId);
    if (currentUserId == null ||
        currentUserId == "PLACEHOLDER_LOGGED_IN_USER_ID") {
      Get.snackbar(
        'Error',
        'User not identified. Please log in again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    fetchMessages();
    // Listen to list changes to scroll to the bottom
    messagesList.listen((_) => _scrollToBottom());
  }

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    messageInputController.dispose();
    messageScrollController.dispose();
    super.onClose();
  }

  void _scrollToBottom() {
    if (messageScrollController.hasClients) {
      // Delay slightly to allow the UI to build before scrolling
      Future.delayed(const Duration(milliseconds: 100), () {
        messageScrollController.animateTo(
          messageScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> fetchMessages() async {
    if (report.sId == null) {
      Get.snackbar(
        'Error',
        'Ticket ID is missing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      isLoadingMessages.value = false;
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

          // Clear the list before adding new data
          messagesList.clear();

          if (messagesData.isNotEmpty) {
            final parsedMessages =
                messagesData.map((item) {
                  final msg = ChatMessage.fromJson(
                    item as Map<String, dynamic>,
                  );
                  // A message is from "support" if the sender is NOT the user who created the report
                  msg.isSupportMessage = msg.senderId != report.user;
                  return msg;
                }).toList();

            // Sort by creation date to ensure correct order
            parsedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            messagesList.assignAll(parsedMessages);
          } else {
            print('No messages found for this ticket.');
          }
        } else {
          Get.snackbar(
            'API Error',
            decodedResponse['message'] ?? 'Failed to parse messages.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load messages. Status: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load messages: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error fetching messages: $e');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = messageInputController.text.trim();
    if (text.isEmpty) return;
    if (report.sId == null) {
      Get.snackbar(
        'Error',
        'Cannot send message: Ticket ID is missing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (currentUserId == null ||
        currentUserId == "PLACEHOLDER_LOGGED_IN_USER_ID") {
      Get.snackbar(
        'Error',
        'Cannot send message: User not identified.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSendingMessage.value = true;
    try {
      final messageToSend = {'messages': text};

      final response = await ApiServices.post(
        url: ApiEndpoints.getTicketMessages(report.sId!),
        body: messageToSend,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final newMessageData = responseData['data'] as Map<String, dynamic>;
          final newMessage = ChatMessage.fromJson(newMessageData);
          newMessage.isSupportMessage = newMessage.senderId != report.user;

          // *** FIX: Optimistic UI update. Add the message directly. ***
          messagesList.add(newMessage);

          // *** FIX: DO NOT refetch the list. It causes a race condition. ***
          // await fetchMessages(); // <-- REMOVED THIS LINE

          messageInputController.clear();
        } else {
          Get.snackbar(
            'Error',
            responseData['message'] ?? 'Failed to send message.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        String errorMessage = 'Failed to send message. Please try again.';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage =
              (errorBody is Map && errorBody.containsKey('message'))
                  ? errorBody['message']
                  : 'Error ${response.statusCode}: ${response.reasonPhrase}';
        } catch (_) {
          errorMessage = 'Error ${response.statusCode}: Server error.';
        }
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error sending message: $e');
    } finally {
      isSendingMessage.value = false;
    }
  }
}
