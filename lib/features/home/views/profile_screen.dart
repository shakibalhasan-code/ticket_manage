// lib/features/home/views/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:workflowx/controllers/profile_controller.dart';
import 'package:workflowx/core/constants/app_assets.dart';
import 'package:workflowx/core/routes/app_pages.dart';
import 'package:workflowx/core/utils/svg_icon.dart';
import 'package:workflowx/features/home/views/profile_details_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  // It's often better to use Get.find() if the controller is initialized elsewhere,
  // but Get.put() is fine if this is the first time it's used.
  final profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Obx(() {
            // Handle Loading State
            if (profileController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            // Handle Error State
            if (profileController.hasError.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Failed to load profile. Please try again.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => profileController.fetchProfileData(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // --- Main Content when data is loaded successfully ---
            final user = profileController.userData.value;
            final profile = user.userProfile;

            // Get the first letter of the full name for the avatar
            final String initials =
                (profile?.fullName?.isNotEmpty ?? false)
                    ? profile!.fullName![0].toUpperCase()
                    : 'U';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        // Positioned(
                        //   right: 0,
                        //   bottom: 0,
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       shape: BoxShape.circle,
                        //       color: Colors.grey.shade200,
                        //       border: Border.all(color: Colors.white, width: 2),
                        //     ),
                        //     padding: const EdgeInsets.all(6),
                        //     child: const Icon(
                        //       Icons.camera_alt_outlined,
                        //       size: 18,
                        //       color: Colors.black54,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // Use data from the model with a fallback
                          profile?.fullName ?? 'User Name',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          // FIX: Displaying the email, since 'address' doesn't exist.
                          user.email ?? 'No email provided',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const SvgIcon(assetName: AppAssets.iconUser),
                  title: const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    Get.to(() => ProfileDetailsScreen());
                  },
                ),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const SvgIcon(assetName: AppAssets.iconPolicy),
                  title: const Text(
                    'Privacy Policy',
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    Get.toNamed(Routes.privacyPolicy);
                  },
                ),

                // NOTE: This should probably navigate to a change password screen,
                // not trigger a logout.
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SvgIcon(
                    assetName: AppAssets.lock,
                    height: 14.sp,
                    width: 14.sp,
                  ),
                  title: const Text(
                    'Change Password',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  onTap: () {
                    // Get.toNamed(Routes.changePassword);
                    print("Navigate to change password");
                  },
                ),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const SvgIcon(assetName: AppAssets.iconLogout),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  onTap: () {
                    showLogoutBottomSheet(context, () {
                      profileController.clearUserData(); // Clear user data
                      Get.offAllNamed(Routes.signIn); // Navigate to sign-in
                    });
                  },
                ),
              ],
            );
          }),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

// (Your showLogoutBottomSheet function remains the same)
void showLogoutBottomSheet(
  BuildContext context,
  VoidCallback onLogoutConfirmed,
) {
  // ... (no changes needed here)
}
