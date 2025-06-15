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
import 'package:workflowx/core/models/distributor_model.dart';
import 'package:workflowx/core/models/message_model.dart';
import 'package:workflowx/core/services/api_services.dart';

class ReportController extends GetxController {
  var isLoading = false.obs;

  var messagesList = <ChatMessage>[].obs;
  var isLoadingMessages = true.obs;
  var isSendingMessage = false.obs;
  final TextEditingController messageController = TextEditingController();
  final homeController = Get.find<MainHomeController>();

  // This is the correct list that will be populated.
  RxList<DistributorModel> distributors = <DistributorModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getApplicator();
  }

  Future<bool> submitNewReport({
    required String? productId,
    required String phoneNumber,
    required String? userType,
    // *** MODIFIED: Added optional distributorId ***
    String? distributorId,
    required String productSerialNumber,
    required List<String>
    issueTypes, // This will be the value for the 'issue' key
    required String
    issueDescription, // This should be the final, combined description
    required List<XFile> imageFiles,
  }) async {
    isLoading.value = true;
    try {
      // --- 1. Prepare the 'data' field (textual information as a JSON string) ---
      // Keys here MUST match what the backend expects.
      Map<String, dynamic> textDataMap = {
        'phone': phoneNumber,
        'issue': issueTypes,
        'userType': userType, // Pass userType directly
        'description': issueDescription,
        'productId': productId ?? '',
        'productSerialNumber': productSerialNumber,
      };

      // *** MODIFIED: Conditionally add the distributor ID ***
      // If the user is an 'Applicator' and an ID is provided, add it to the payload.
      if (userType == 'Applicator' &&
          distributorId != null &&
          distributorId.isNotEmpty) {
        textDataMap['distributor'] = distributorId;
      }

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

  Future<void> getApplicator() async {
    try {
      // Assuming ApiServices.fetchData is your intended method for GET requests
      final response = await ApiServices.fetchData(
        url: ApiEndpoints.getApplicator,
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Cast the 'data' to a List<dynamic> for type safety
        final List<dynamic> distributorJsonList = responseBody['data'];

        // Clear the existing list to prevent duplicates on refresh
        distributors.clear();

        // Loop through the JSON list, parse each item, and add it to the correct list
        for (var distributorJson in distributorJsonList) {
          // Create a DistributorModel instance from the JSON map
          final distributorModel = DistributorModel.fromJson(distributorJson);
          // Add the parsed model to the 'distributors' RxList
          distributors.add(distributorModel);
        }

        Get.log(
          "Successfully fetched and set ${distributors.length} distributors.",
        );
      } else {
        Get.snackbar('Error', '${responseBody['message']}');
      }
    } catch (e) {
      printError(info: 'Failed to fetch distributors: $e');
      Get.snackbar(
        'Error',
        'Could not load distributor list. Please check your connection.',
      );
    }
  }
}
