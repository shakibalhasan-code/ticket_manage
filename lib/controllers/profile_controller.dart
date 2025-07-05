import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/models/user_model.dart';
import 'package:workflowx/core/services/api_services.dart';

class ProfileController extends GetxController {
  // --- STATE MANAGEMENT VARIABLES ---
  var isLoading = true.obs;
  var isUpdating = false.obs;
  var isUploadingImage = false.obs;
  var hasError = false.obs;

  final Rx<UserData> userData = UserData().obs;
  final Rx<File?> selectedImageFile = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();

    // --- FIX: Use a reactive worker to trigger the upload ---
    // This 'ever' worker listens to changes in 'selectedImageFile'.
    // When a new file is selected (not null), it automatically calls updateProfileImage.
    ever(selectedImageFile, (File? file) {
      if (file != null) {
        // Add a print statement here for debugging confirmation
        print("--- 'ever' worker detected a new file. Triggering upload. ---");
        updateProfileImage();
      }
    });
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
  /// The 'ever' worker in onInit() will handle triggering the upload.
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await _showImageSourceSheet(picker);

      if (image != null) {
        print("Image picked successfully: ${image.path}");
        // Just update the state. The 'ever' worker will do the rest.
        selectedImageFile.value = File(image.path);
      } else {
        print("Image picking was cancelled.");
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

  Future<void> deleteAccount(BuildContext context) async {
    // This method is not changed, but you can add error handling if needed.
    try {
      final response = await ApiServices.delete(
        url: ApiEndpoints.deleteAccount,
      );
      final responseBody = jsonDecode(response.body);
      final message = responseBody['message'] ?? 'Unknown error';

      if (response.statusCode == 200 && responseBody['success'] == true) {
        clearUserData();
        Get.offAllNamed('/login');
        Get.snackbar(
          'Success',
          'Account deleted successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          responseBody['message'] ?? 'Could not delete account.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      printError(info: 'Error deleting account: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred while deleting the account.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// **Update Profile Image Only**
  /// This is now called automatically by the 'ever' worker.
  Future<void> updateProfileImage() async {
    if (selectedImageFile.value == null) {
      print(
        "updateProfileImage called but selectedImageFile is null. Aborting.",
      );
      return;
    }

    print(
      "--- Starting image upload for file: ${selectedImageFile.value!.path} ---",
    );
    isUploadingImage.value = true;
    try {
      final response = await ApiServices.patchWithFile(
        url: ApiEndpoints.updateProfileImage,
        file: selectedImageFile.value!,
        fileField:
            'image', // Ensure this matches your backend ('image', 'profileImage', etc.)
      );

      final responseBody = jsonDecode(response.body);
      print("Upload response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 && responseBody['success'] == true) {
        // The UI will reactively update from the new data.
        await fetchProfileData();
        // Clear the selected file to prevent re-uploading on next state change.
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

  // Renamed pickAndUploadImage to just pickImage in your UI code.
  // The 'updateProfileDetails' function remains unchanged as it works correctly.

  /// **Update Profile Details Only**
  Future<void> updateProfileDetails({
    required String fullName,
    required String phone,
  }) async {
    isUpdating.value = true;
    try {
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
        await fetchProfileData();
        Get.back();
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

  // --- HELPER & CLEANUP METHODS (Unchanged) ---
  Future<XFile?> _showImageSourceSheet(ImagePicker picker) {
    // ... no changes needed here
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
    // ... no changes needed here
    userData.value = UserData();
    selectedImageFile.value = null;
  }
}
