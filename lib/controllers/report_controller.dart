import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/services/api_services.dart';

class ReportController extends GetxController {
  var isLoading = false.obs;

  // This controller mainly handles the submission logic.
  // Form field values are managed by FileReportScreen's local state.

  Future<bool> submitNewReport({
    required String? productId,
    required String? productModel,

    required String phoneNumber,
    required String? userType,
    required List<String> issueTypes,
    String? customIssueDetail,
    required String issueDescription,
    required List<XFile> imageFiles, // Pass XFiles
  }) async {
    isLoading.value = true;
    try {
      // --- Prepare Data for Submission ---
      // Using FormData is common for multipart requests (if sending files)
      var formData = FormData({
        'productId': productId ?? '',

        'phoneNumber': phoneNumber,
        'userType': userType ?? 'Customer', // Default if null
        // API might expect issueTypes as a comma-separated string or JSON array string
        'issueTypes': issueTypes.join(','), // Example: "Hardware,Software"
        if (customIssueDetail != null && customIssueDetail.isNotEmpty)
          'customIssueDetail': customIssueDetail,
        'issueDescription': issueDescription,
      });

      // Add files to FormData
      for (int i = 0; i < imageFiles.length; i++) {
        XFile file = imageFiles[i];
        formData.files.add(
          MapEntry(
            'images[$i]', // API might expect 'images[]' or 'images' or specific field names
            MultipartFile(
              File(file.path), // Convert XFile path to File
              filename: file.name,
              // contentType: MediaType('image', 'jpeg'), // Optional: specify content type
            ),
          ),
        );
        // Alternative if API expects single 'images' field with multiple files:
        // formData.files.add(MapEntry(
        //   'images',
        //   MultipartFile(File(file.path), filename: file.name),
        // ));
      }

      Get.log('Submitting Report FormData: ${formData.fields}');
      for (var fileEntry in formData.files) {
        Get.log(
          'File in FormData: ${fileEntry.key} - ${fileEntry.value.filename}',
        );
      }

      // --- API Call ---
      // Replace ApiEndpoints.submitReport with your actual endpoint
      final response = await ApiServices.post(
        url: ApiEndpoints.issueNewTicket, // MAKE SURE THIS ENDPOINT IS CORRECT
        body: {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        Get.log('Report submitted successfully: ${response.body}');
        Get.snackbar(
          'Success',
          'Your report has been submitted successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true; // Indicate success
      } else {
        // Handle API error
        Get.log(
          'Failed to submit report. Status: ${response.statusCode}, Body: ${response.body}',
        );
        String errorMessage = 'Failed to submit report. Please try again.';
        // try {
        //   // Attempt to parse error message from response body
        //   var responseBody = response.body;
        //   if (responseBody is String && responseBody.isNotEmpty) {
        //     var decodedBody = GetConnect().decoder(responseBody);
        //     if (decodedBody is Map && decodedBody.containsKey('message')) {
        //       errorMessage = decodedBody['message'];
        //     } else if (decodedBody is Map && decodedBody.containsKey('error')) {
        //       errorMessage = decodedBody['error'];
        //     }
        //   }
        // } catch (e) {
        //   Get.log("Error parsing error response: $e");
        // }

        Get.snackbar(
          'Submission Failed',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false; // Indicate failure
      }
    } catch (e) {
      Get.log('Exception during report submission: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false; // Indicate failure
    } finally {
      isLoading.value = false;
    }
  }
}
