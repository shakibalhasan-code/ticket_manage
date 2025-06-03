import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/models/notification_model.dart';
import 'package:workflowx/core/models/report_model.dart'; // Import ReportModel
import 'package:workflowx/core/services/api_services.dart';
import 'package:workflowx/features/home/views/report_preview_reply_screen.dart'
    show ReportDetailsWithMessagesScreen; // Your actual path to the screen

class NotificationController extends GetxController {
  var notificationsList = <NotificationModel>[].obs;
  var isLoading = true.obs; // For general loading of notifications list
  var isProcessingNotification = false.obs; // Specific for mark as read action

  @override
  void onInit() {
    super.onInit();
    getAllNotifications();
  }

  Future<void> getAllNotifications() async {
    // ... (your existing getAllNotifications method is largely fine)
    // Keep it as is, just ensure it uses isLoading.value
    try {
      isLoading.value = true;
      final response = await ApiServices.fetchData(
        url: ApiEndpoints.getNotifications,
      );

      if (response.statusCode == 200) {
        final body = response.body;
        if (body.isNotEmpty) {
          final Map<String, dynamic> decodedResponse = jsonDecode(body);
          if (decodedResponse.containsKey('data') &&
              decodedResponse['data'] is List) {
            final List<dynamic> jsonData =
                decodedResponse['data'] as List<dynamic>;
            if (jsonData.isNotEmpty) {
              notificationsList.value =
                  jsonData
                      .map(
                        (item) => NotificationModel.fromJson(
                          item as Map<String, dynamic>,
                        ),
                      )
                      .toList();
            } else {
              notificationsList.clear();
            }
          } else {
            notificationsList.clear();
            Get.snackbar(
              'API Error',
              'Unexpected response format from server.',
            );
          }
        } else {
          notificationsList.clear();
        }
      } else {
        notificationsList.clear();
        String errorMessage =
            'Failed to load notifications. Status: ${response.statusCode}';
        // ... (your error message parsing)
        Get.snackbar('Error', errorMessage);
      }
    } catch (e) {
      notificationsList.clear();
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markNotificationAsReadAndNavigate(
    NotificationModel notification,
  ) async {
    if (notification.sId == null) {
      Get.snackbar('Error', 'Notification ID is missing.');
      return;
    }
    // Prevent multiple rapid clicks
    if (isProcessingNotification.value) return;

    isProcessingNotification.value = true;
    try {
      // 1. Mark notification as read
      //    The PATCH request might not need a body, or it might be like {'isRead': true}
      //    Adjust the body parameter for ApiServices.patch as needed.
      //    If your ApiServices.patch doesn't take an empty body, you might need to pass an empty map {}.
      final markReadResponse = await ApiServices.patch(
        url: ApiEndpoints.notificationMarkAsRead(notification.sId!),
        body:
            {}, // Send empty body or specific body like {'isRead': true} if backend expects it
        // ApiServices.patch should handle the auth token
      );

      print(
        'Marking notification ${notification.sId} as read: ${markReadResponse.statusCode} - ${markReadResponse.body}',
      );

      if (markReadResponse.statusCode == 200) {
        // Update the local notification list item to reflect read status
        int index = notificationsList.indexWhere(
          (n) => n.sId == notification.sId,
        );
        if (index != -1) {
          notificationsList[index].isRead = true;
          notificationsList.refresh(); // Trigger UI update for the list
        }
        // getAllNotifications(); // Optionally refresh the whole list from server

        // 2. If notification has a ticketId, fetch the ticket and navigate
        if (notification.ticketId != null &&
            notification.ticketId!.isNotEmpty) {
          final ticketDetailsResponse = await ApiServices.fetchData(
            url: ApiEndpoints.getSingleTicket(notification.ticketId!),
          );

          print(
            'Fetching ticket ${notification.ticketId}: ${ticketDetailsResponse.statusCode} - ${ticketDetailsResponse.body}',
          );

          if (ticketDetailsResponse.statusCode == 200) {
            final ticketBody = jsonDecode(ticketDetailsResponse.body);
            if (ticketBody['success'] == true && ticketBody['data'] != null) {
              final ReportModel reportModel = ReportModel.fromJson(
                ticketBody['data'] as Map<String, dynamic>,
              );
              Get.to(
                () => ReportDetailsWithMessagesScreen(report: reportModel),
              );
            } else {
              Get.snackbar(
                'Error',
                ticketBody['message'] ?? 'Failed to parse ticket details.',
              );
            }
          } else {
            Get.snackbar(
              'Error',
              'Failed to fetch ticket details. Status: ${ticketDetailsResponse.statusCode}',
            );
          }
        } else {
          print('Notification does not have a ticketId or it is empty.');
          // If no ticketId, maybe just refresh notifications or show a success message for marking as read.
          Get.snackbar('Success', 'Notification marked as read.');
        }
      } else {
        String errorMessage = 'Failed to mark notification as read.';
        try {
          final errorBody = jsonDecode(markReadResponse.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage = errorBody['message'];
          }
        } catch (_) {}
        Get.snackbar('Error', errorMessage);
      }
    } catch (e) {
      print('Error processing notification: $e');
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
    } finally {
      isProcessingNotification.value = false;
    }
  }
}
