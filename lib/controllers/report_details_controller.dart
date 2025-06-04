import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For parsing dates
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
  final TextEditingController messageInputController =
      TextEditingController(); // Renamed for clarity
  final ScrollController scrollController =
      ScrollController(); // For auto-scrolling

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
    messagesList.listen(
      (_) => _scrollToBottom(),
    ); // Listen to list changes to scroll
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      // Delay slightly to allow the UI to build before scrolling
      Future.delayed(const Duration(milliseconds: 100), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
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
      messagesList.clear();

      final response = await ApiServices.fetchData(
        url: ApiEndpoints.getTicketMessages(report.sId!),
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse['success'] == true &&
            decodedResponse['data'] is List) {
          final List<dynamic> messagesData = decodedResponse['data'];
          if (messagesData.isNotEmpty) {
            messagesList.value =
                messagesData.map((item) {
                  final msg = ChatMessage.fromJson(
                    item as Map<String, dynamic>,
                  );
                  msg.isSupportMessage = msg.senderId != report.user;
                  return msg;
                }).toList();
            messagesList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
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
      // Potentially log out user or show critical error
      return;
    }

    isSendingMessage.value = true;
    try {
      // Construct the payload. The backend should know the sender from the auth token.
      // If it doesn't, you'd need to include `senderId: _currentUserId` here,
      // but the ChatMessage model's toJsonForSend does not include it by default.
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

          messagesList.add(newMessage);
          await fetchMessages();
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
