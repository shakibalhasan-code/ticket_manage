import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/models/user_model.dart';
import 'package:workflowx/core/services/api_services.dart';

class ProfileController extends GetxController {
  // --- STATE MANAGEMENT VARIABLES ---
  var isLoading = true.obs;
  var isUpdating = false.obs; // For updating text details
  var isUploadingImage = false.obs; // NEW: Specific state for image upload
  var hasError = false.obs;

  final Rx<UserData> userData = UserData().obs;
  final Rx<File?> selectedImageFile = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  // --- DATA FETCHING (Unchanged) ---
  Future<void> fetchProfileData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      final response = await ApiServices.fetchData(url: ApiEndpoints.getMe);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          userData.value = UserData.fromJson(body['data']);
        } else {
          hasError.value = true;
        }
      } else {
        hasError.value = true;
      }
    } catch (e) {
      hasError.value = true;
      printError(info: 'Error fetching profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // --- IMAGE HANDLING & UPLOADING ---

  /// 1. Picks an image from the gallery or camera.
  /// 2. If an image is picked, it immediately calls `updateProfileImage()` to upload it.
  Future<void> pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await _showImageSourceSheet(picker);

      if (image != null) {
        selectedImageFile.value = File(image.path);
        // Immediately trigger the upload after picking the file
        await updateProfileImage();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// **NEW FUNCTION 1: Update Profile Image Only**

  Future<void> updateProfileImage() async {
    if (selectedImageFile.value == null) return;

    isUploadingImage.value = true;
    try {
      // This call is now correct because patchWithFile no longer needs a 'body'.
      final response = await ApiServices.patchWithFile(
        url:
            ApiEndpoints
                .updateProfileImage, // Make sure this endpoint is correct
        file: selectedImageFile.value!,
        fileField: 'image',
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        await fetchProfileData();
        selectedImageFile.value = null;

        Get.snackbar(
          'Success',
          'Profile image updated!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Upload Failed',
          responseBody['message'] ?? 'Could not update image.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      printError(info: 'Error updating profile image: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred during upload.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  /// **NEW FUNCTION 2: Update Profile Details Only**
  /// This function is called by the 'Update Profile' button and only sends text data.
  Future<void> updateProfileDetails({
    required String fullName,
    required String phone,
  }) async {
    isUpdating.value = true;
    try {
      // Construct the full body that the API expects.
      final profile = userData.value.userProfile;
      final Map<String, String> textFields = {
        'fullName': fullName,
        'phone': phone,
      };

      final response = await ApiServices.patch(
        url: ApiEndpoints.updateProfile,
        body: textFields,
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        await fetchProfileData(); // Refresh data
        Get.back(); // Go back to the previous screen
        Get.snackbar(
          'Success',
          'Profile details updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Update Failed',
          responseBody['message'] ?? 'Could not update profile.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      printError(info: 'Error updating profile details: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // --- HELPER & CLEANUP METHODS ---

  /// Helper to show the image source selection sheet.
  Future<XFile?> _showImageSourceSheet(ImagePicker picker) {
    return showModalBottomSheet<XFile?>(
      context: Get.context!,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap:
                    () async => Navigator.pop(
                      context,
                      await picker.pickImage(source: ImageSource.gallery),
                    ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap:
                    () async => Navigator.pop(
                      context,
                      await picker.pickImage(source: ImageSource.camera),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  void clearUserData() {
    userData.value = UserData();
    selectedImageFile.value = null;
  }
}
