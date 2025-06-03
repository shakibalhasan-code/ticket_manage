import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workflowx/controllers/notification_contorller.dart';
import 'package:workflowx/core/models/notification_model.dart'; // Ensure this path is correct
import 'package:workflowx/core/routes/app_pages.dart';
// Import your new NotificationController
import 'package:workflowx/features/home/widget/notification_card.dart'; // FIXME: Adjust path if needed

class NotificationScreen extends StatelessWidget {
  // You can inject the controller via Get.put() here, or preferably use Bindings
  // For this example, Get.put() is used directly.
  // For better practice, create a NotificationBinding and add it to your GetPage.
  final NotificationController controller = Get.put(NotificationController());

  NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: false,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios),
        //   onPressed: () {
        //     // Use GetX for navigation
        //     if (Get.key.currentState?.canPop() ?? false) {
        //       Get.back();
        //     } else {
        //       Get.offAllNamed(
        //         Routes.home,
        //       ); // Navigate to home if no previous route
        //     }
        //   },
        // ),
        actions: [
          // Optional: Add a refresh button that shows loading state
          Obx(() {
            if (controller.isLoading.value &&
                controller.notificationsList.isEmpty) {
              // Don't show refresh icon if already loading the initial list
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                  ),
                ),
              );
            }
            return IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87),
              onPressed:
                  controller.isLoading.value
                      ? null
                      : () => controller.getAllNotifications(),
              tooltip: 'Refresh Notifications',
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          // Use Obx to listen to changes in the controller's observables
          child: Obx(() {
            // Show main loading indicator only if the list is currently empty
            if (controller.isLoading.value &&
                controller.notificationsList.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.notificationsList.isEmpty &&
                !controller.isLoading.value) {
              // Empty state after loading has finished and list is still empty
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We\'ll let you know when there\'s something new.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      onPressed: () => controller.getAllNotifications(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Display list of notifications with Pull-to-Refresh
            return RefreshIndicator(
              onRefresh: () => controller.getAllNotifications(),
              child: ListView.builder(
                itemCount: controller.notificationsList.length,
                itemBuilder: (context, index) {
                  final NotificationModel notif =
                      controller.notificationsList[index];
                  return NotificationCard(
                    notification: notif,
                    onTap: () {
                      controller.markNotificationAsRead(notif.sId!);
                    },
                  );
                },
              ),
            );
          }),
        ),
      ),
      backgroundColor: Colors.white,
      // If you had a BottomNavigationBar:
      // bottomNavigationBar: Obx(() => BottomNavigationBar(
      //   currentIndex: controller.currentIndex.value,
      //   onTap: controller.onNavTap, // Call method on controller
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      //     // ... other items
      //     BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
      //   ],
      // )),
    );
  }
}
