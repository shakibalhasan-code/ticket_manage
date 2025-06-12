import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:workflowx/controllers/profile_controller.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  // Find the already-existing ProfileController instance
  final ProfileController controller = Get.find<ProfileController>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  String _phoneNumber = '';
  String _initialPhoneNumber = '';

  @override
  void initState() {
    super.initState();

    // Initialize controllers with data from the ProfileController
    final user = controller.userData.value;
    final profile = user.userProfile;

    _fullNameController = TextEditingController(text: profile?.fullName ?? '');
    _emailController = TextEditingController(text: user.email ?? '');

    // Set initial values for the phone field from the controller
    _initialPhoneNumber = profile?.phone ?? '';
    _phoneNumber = _initialPhoneNumber;
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is removed
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    final fullName = _fullNameController.text.trim();

    // Call the controller method to perform the API call
    controller.updateProfileData(fullName: fullName, phone: _phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    // Get the latest data from the controller using Obx for reactivity
    return Obx(() {
      final user = controller.userData.value;
      final profile = user.userProfile;
      final profileImageUrl = profile?.image;
      final String initials =
          (profile?.fullName?.isNotEmpty ?? false)
              ? profile!.fullName![0].toUpperCase()
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
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Obx(() {
                      return CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            profileImageUrl != null &&
                                    profileImageUrl.isNotEmpty
                                ? NetworkImage(profileImageUrl)
                                : controller.selectedImageFile.value != null
                                ? FileImage(controller.selectedImageFile.value!)
                                : null,
                        backgroundColor: Colors.blue.shade100,
                        // child:
                        //     profileImageUrl == null || profileImageUrl.isEmpty
                        //         ? Text(
                        //           initials,
                        //           style: const TextStyle(
                        //             fontSize: 48,
                        //             fontWeight: FontWeight.bold,
                        //             color: Colors.blue,
                        //           ),
                        //         )
                        //         : null,
                      );
                    }),
                    Positioned(
                      bottom: -5,
                      right: -5,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Implement image picker logic here
                          Get.snackbar(
                            'Info',
                            'Image picker not yet implemented.',
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: InkWell(
                            onTap:
                                () => controller.pickImage(ImageSource.gallery),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  profile?.fullName ?? 'User Name',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user.email ?? 'user@email.com',
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                ),
                const SizedBox(height: 30),

                // Full Name TextField
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
                ),
                const SizedBox(height: 16),

                // Email TextField (readonly)
                TextField(
                  controller: _emailController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Email (cannot be changed)',
                    fillColor: Colors.grey.shade200,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Phone number with intl_phone_field
                IntlPhoneField(
                  initialValue: _initialPhoneNumber,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (phone) {
                    _phoneNumber = phone.completeNumber;
                  },
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed:
                          controller.isUpdating.value ? null : _handleUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.blue.withOpacity(0.5),
                      ),
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
                                'Update',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
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
