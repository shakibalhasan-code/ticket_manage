// ReportController.dart
import 'dart:convert'; // Import for jsonEncode
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workflowx/controllers/home_controller.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/models/message_model.dart';
import 'package:workflowx/core/services/api_services.dart';

class ReportController extends GetxController {
  var isLoading = false.obs;

  var messagesList = <ChatMessage>[].obs;
  var isLoadingMessages = true.obs;
  var isSendingMessage = false.obs;
  final TextEditingController messageController = TextEditingController();
  final homeController = Get.find<MainHomeController>();

  Future<bool> submitNewReport({
    required String? productId,
    // productModel is not in the Postman 'data' field, so it's optional here
    // unless used for something else before sending.
    // required String? productModel,
    required String phoneNumber,
    required String? userType,
    required List<String>
    issueTypes, // This will be the value for the 'issue' key
    // String? customIssueDetail, // REMOVED - This should be part of issueDescription
    required String
    issueDescription, // This should be the final, combined description
    required List<XFile> imageFiles,
  }) async {
    isLoading.value = true;
    try {
      // --- 1. Prepare the 'data' field (textual information as a JSON string) ---
      // Keys here MUST match what the backend expects (from your Postman example)
      Map<String, dynamic> textDataMap = {
        'phone': phoneNumber, // Changed from 'phoneNumber'
        'issue': issueTypes, // Changed from 'issueTypes'. Value is List<String>
        'userType': userType ?? 'Customer',
        'description':
            issueDescription, // Changed from 'issueDescription'. This is the final combined one.
        'productId': productId ?? '',
      };

      String jsonDataPayload = jsonEncode(textDataMap);

      // This will be the 'fields' map for the multipart request
      Map<String, String> fields = {'data': jsonDataPayload};

      // --- 2. Prepare the 'image' field (files) ---
      List<http.MultipartFile> filesToUpload = [];
      for (int i = 0; i < imageFiles.length; i++) {
        XFile file = imageFiles[i];
        String extension = file.name.split('.').last.toLowerCase();
        MediaType? contentType;
        if (extension == 'jpg' || extension == 'jpeg') {
          contentType = MediaType('image', 'jpeg');
        } else if (extension == 'png') {
          contentType = MediaType('image', 'png');
        } // Add more types if needed

        filesToUpload.add(
          await http.MultipartFile.fromPath(
            'image', // Field name for files is 'image' (singular)
            file.path,
            filename: file.name,
            contentType: contentType,
          ),
        );
      }

      Get.log('Submitting Multipart Report:');
      Get.log('Field "data": $jsonDataPayload');
      Get.log(
        'Files under "image" key: ${filesToUpload.map((f) => f.filename).join(', ')}',
      );

      // --- API Call using postMultipart ---
      final response = await ApiServices.postMultipart(
        url: ApiEndpoints.issueNewTicket,
        fields: fields, // Contains the 'data' field with JSON string
        files: filesToUpload, // Contains files under the 'image' key
        requiresAuth: true,
      );

      Get.log(
        'Report submitted successfully. Status: ${response.statusCode}, Body: ${response.body}',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        Get.snackbar(
          'Success',
          'Your report has been submitted successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        await homeController.getMyTickets(); // Refresh tickets list
        return true;
      } else {
        // Attempt to parse error message from backend
        String errorMessage = 'Failed to submit report. Please try again.';
        try {
          final responseBody = jsonDecode(response.body);
          if (responseBody is Map && responseBody.containsKey('message')) {
            errorMessage = responseBody['message'];
          } else {
            errorMessage =
                'Error ${response.statusCode}: ${response.reasonPhrase}';
          }
        } catch (_) {
          // If body is not JSON or doesn't have 'message'
          errorMessage =
              'Error ${response.statusCode}: ${response.reasonPhrase ?? "Unknown error"}';
        }
        Get.log('Report submission failed: $errorMessage');
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.log('Exception during report submission in Controller: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
