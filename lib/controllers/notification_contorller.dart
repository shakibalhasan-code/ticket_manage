import 'dart:convert';
import 'package:flutter/material.dart'; // For Get.snackbar theme colors
import 'package:get/get.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/config/app_constants.dart';
import 'package:workflowx/core/helper/pref_helper.dart';
import 'package:workflowx/core/models/notification_model.dart'; // Ensure this path is correct
import 'package:workflowx/core/services/api_services.dart'; // Ensure this path is correct
import 'package:http/http.dart' as http; // For HTTP requests

class NotificationController extends GetxController {
  var notificationsList = <NotificationModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    getAllNotifications();
  }

  Future<void> getAllNotifications() async {
    try {
      isLoading.value = true;
      final response = await ApiServices.fetchData(
        url: ApiEndpoints.getNotifications,
      );

      if (response.statusCode == 200) {
        final body = response.body;
        if (body != null && body.isNotEmpty) {
          // 1. Decode the entire response body as a Map
          final Map<String, dynamic> decodedResponse = jsonDecode(body);

          // 2. Check if the 'data' key exists and is a List
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
              print(
                'Notifications fetched successfully: ${notificationsList.length} items',
              );
            } else {
              notificationsList.clear();
              print('No notifications found (empty "data" list from API).');
            }
          } else {
            notificationsList.clear();
            print(
              'No notifications found ("data" key missing or not a list in API response).',
            );
            // Optionally, show a snackbar if the structure is unexpected
            Get.snackbar(
              'API Error',
              'Unexpected response format from server.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Get.theme.colorScheme.error,
              colorText: Get.theme.colorScheme.onError,
            );
          }
        } else {
          notificationsList.clear();
          print('No notifications found (null or empty body from API).');
        }
      } else {
        notificationsList.clear();
        print('Failed to fetch notifications: ${response.statusCode}');
        String errorMessage =
            'Failed to load notifications. Status: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage = errorBody['message'];
          }
        } catch (_) {
          // Ignore if error body is not JSON or doesn't have message
        }
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      notificationsList.clear();
      print('Error fetching notifications: $e');
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      isLoading.value = true;
      final token = await PrefHelper.getString(AppConstants.token);
      print('$notificationId');
      print('token: $token');
      final response = await http.patch(
        Uri.parse(ApiEndpoints.notificationMarkAsRead(notificationId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(
        'Marking notification as read: ${response.statusCode} - ${response.body}',
      );
      if (response.statusCode == 200) {
        print('Notification marked as read successfully.');
        // Optionally, you can refresh the notifications list after marking as read
        getAllNotifications();
      } else {
        print('Failed to mark notification as read: ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Failed to mark notification as read.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      Get.snackbar(
        'Error',
        'An error occurred while marking notification as read.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
