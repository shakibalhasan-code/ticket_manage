import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/models/notification_model.dart';
import 'package:workflowx/core/services/api_services.dart';

class CommonController extends GetxController {
  RxList<NotificationModel> notificationsList = <NotificationModel>[].obs;
  var isLoadingNotifications = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> getAllNotifications() async {
    try {
      isLoadingNotifications.value = true;
      final response = await ApiServices.fetchData(
        url: ApiEndpoints.getNotifications,
      );

      if (response.statusCode == 200) {
        final body = response.body;
        if (body != null && body.isNotEmpty) {
          // Assuming the response is a JSON array of notifications
          final notifications = jsonDecode(body);
          print(
            'Notifications fetched successfully: ${notifications.length} items',
          );
          notificationsList.value =
              (notifications as List)
                  .map((item) => NotificationModel.fromJson(item))
                  .toList();
        } else {
          print('No notifications found.');
        }
      } else {
        print('Failed to fetch notifications: ${response.statusCode}');
        throw Exception(
          'Failed to load notifications. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      rethrow;
    } finally {
      isLoadingNotifications.value = false;
    }
  }
}
