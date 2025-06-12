import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/models/user_model.dart';
import 'package:workflowx/core/services/api_services.dart';

class ProfileController extends GetxController {
  var isLoading = true.obs;
  var isUpdating = false.obs; // New state for the update button loader
  var hasError = false.obs;

  final Rx<UserData> userData = UserData().obs;
  final Rx<File?> selectedImageFile = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  // This method remains the same
  Future<void> fetchProfileData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      final response = await ApiServices.fetchData(url: ApiEndpoints.getMe);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          userData.value = UserData.fromJson(body['data']);
          hasError.value = false;
        } else {
          hasError.value = true;
        }
      } else {
        hasError.value = true;
      }
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        selectedImageFile.value = File(pickedFile.path);
      } else {
        Get.snackbar('Cancelled', 'No image was selected.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  // Future<void>updateProfileImage()async{
  //   try{
  //     final response = await ApiServices.updateProfileWithImage(url: ApiEndpoints.baseImageUrl, fields: {
  //       'image': selectedImageFile.value
  //     })
  //   }catch(e){
  //     printError(info: '$e');
  //   }
  // }

  // --- NEW METHOD TO UPDATE PROFILE ---
  Future<void> updateProfileData({
    required String fullName,
    required String phone,
    // You can also pass an image file here later
  }) async {
    isUpdating.value = true;
    try {
      final body = {'fullName': fullName, 'phone': phone};

      // Use a PUT or PATCH request to send the updated data
      final response = await ApiServices.patch(
        url: ApiEndpoints.updateProfile,
        body: body,
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        // Refresh data to show the latest info
        await fetchProfileData();
        Get.back(); // Go back to the previous screen
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
      );
    } finally {
      isUpdating.value = false;
    }
  }

  void clearUserData() {
    userData.value = UserData();
  }
}
