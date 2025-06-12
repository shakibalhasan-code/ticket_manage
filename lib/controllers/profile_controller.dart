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
  var isUpdating = false.obs;
  var hasError = false.obs;

  final Rx<UserData> userData = UserData().obs;
  final Rx<File?> selectedImageFile = Rx<File?>(null);

  static const String _kImageFieldName = 'image';

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

  // --- IMAGE HANDLING (SIMPLIFIED) ---

  /// Picks an image from gallery or camera and updates the local state.
  /// The compression step has been removed.
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await showModalBottomSheet<XFile?>(
        context: Get.context!,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Photo Library'),
                  onTap: () async {
                    Navigator.pop(
                      context,
                      await picker.pickImage(source: ImageSource.gallery),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () async {
                    Navigator.pop(
                      context,
                      await picker.pickImage(source: ImageSource.camera),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );

      if (image != null) {
        // Directly assign the picked file without compression
        selectedImageFile.value = File(image.path);
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

  // --- _compressImage method has been completely REMOVED ---

  // --- UNIFIED PROFILE UPDATE METHOD (Unchanged) ---
  Future<void> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    isUpdating.value = true;
    try {
      late final http.Response response;
      final Map<String, String> textFields = {
        'fullName': fullName,
        'phone': phone,
      };

      if (selectedImageFile.value != null) {
        response = await ApiServices.patchWithFile(
          url: ApiEndpoints.updateProfile,
          body: textFields,
          file: selectedImageFile.value!,
          fileField: _kImageFieldName,
        );
      } else {
        response = await ApiServices.patch(
          url: ApiEndpoints.updateProfile,
          body: textFields,
        );
      }

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        selectedImageFile.value = null;
        await fetchProfileData();

        Get.back();
        Get.snackbar(
          'Success',
          'Profile updated successfully!',
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
      printError(info: 'Error updating profile: $e');
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

  void clearUserData() {
    userData.value = UserData();
    selectedImageFile.value = null;
  }
}
