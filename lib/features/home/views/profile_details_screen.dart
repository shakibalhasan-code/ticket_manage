import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workflowx/controllers/profile_controller.dart';
import 'package:workflowx/core/config/api_endpoints.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  // Get an instance of the controller from GetX
  final ProfileController controller = Get.find<ProfileController>();

  // Text editing controllers for the form fields
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with data from the ProfileController
    final user = controller.userData.value;
    final profile = user.userProfile;

    _fullNameController = TextEditingController(text: profile?.fullName ?? '');
    _emailController = TextEditingController(text: user.email ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Handles the "Update Profile" button press.
  /// This now calls the method responsible for updating only the text details.
  void _handleUpdate() {
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    controller.updateProfileDetails(fullName: fullName, phone: phone);
  }

  @override
  Widget build(BuildContext context) {
    // Obx wraps the UI to automatically rebuild when observable variables change
    return Obx(() {
      final user = controller.userData.value;
      final profile = user.userProfile;
      final pickedFile = controller.selectedImageFile.value;

      // Calculate user initials as a fallback for the avatar
      final String initials =
          (profile?.fullName?.isNotEmpty ?? false)
              ? profile!.fullName!
                  .split(' ')
                  .map((e) => e[0])
                  .take(2)
                  .join()
                  .toUpperCase()
              : (user.email?.isNotEmpty ?? false)
              ? user.email![0].toUpperCase()
              : 'U';

      return Scaffold(
        appBar: AppBar(
          title: const Text('My Information'),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black87,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- Profile Image Section ---
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // The main CircleAvatar for the profile image
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue.shade100,
                      // Logic: 1. Show picked file, 2. Show network image, 3. Fallback to null
                      backgroundImage:
                          pickedFile != null
                              ? FileImage(pickedFile) as ImageProvider
                              : (profile?.image != null &&
                                  profile!.image!.isNotEmpty)
                              ? NetworkImage(
                                '${ApiEndpoints.baseImageUrl}/${profile.image}',
                              )
                              : null,
                      // Child: Show initials only if there is no background image
                      child:
                          (pickedFile == null &&
                                  (profile?.image == null ||
                                      profile!.image!.isEmpty))
                              ? Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.blue,
                                ),
                              )
                              : null,
                    ),

                    // NEW: Loading indicator overlay for image uploads
                    Obx(() {
                      if (controller.isUploadingImage.value) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink(); // Return an empty box when not loading
                    }),

                    // The edit button
                    Positioned(
                      bottom: -5,
                      right: -5,
                      child: GestureDetector(
                        // Calls the new method to pick and immediately upload the image
                        // Disabled while an upload is in progress
                        onTap:
                            controller.isUploadingImage.value
                                ? null
                                : () => controller.pickAndUploadImage(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // User's name, updates in real-time as they type in the TextField
                Text(
                  _fullNameController.text.isNotEmpty
                      ? _fullNameController.text
                      : 'User Name',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  user.email ?? 'user@email.com',
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                ),
                const SizedBox(height: 30),

                // --- Form Fields Section ---
                TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                  // setState updates the name display above as the user types
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _emailController,
                  readOnly: true, // Email should not be editable
                  decoration: InputDecoration(
                    labelText: 'Email (cannot be changed)',
                    fillColor: Colors.grey.shade200,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- Update Button ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    // Disabled while the details are being updated
                    onPressed:
                        controller.isUpdating.value ? null : _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.blue.withOpacity(0.5),
                    ),
                    // Show a loading indicator or text based on the updating state
                    child:
                        controller.isUpdating.value
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                            : const Text(
                              'Update Profile',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white,
      );
    });
  }
}
