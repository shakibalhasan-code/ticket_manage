import 'dart:convert';
import 'package:get/get.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/models/user_model.dart'; // Ensure UserData and UserProfileDetails are defined here
import 'package:workflowx/core/services/api_services.dart';

class ProfileController extends GetxController {
  var isLoading = true.obs;
  var hasError = false.obs;

  final Rx<UserData> userData = UserData().obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      // Reset userData to a fresh instance in case of retry, to clear old state
      userData.value = UserData();

      final response = await ApiServices.fetchData(url: ApiEndpoints.getMe);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        printInfo(info: 'Profile data: ${body.toString()}');

        if (body['success'] == true && body['data'] != null) {
          // Parse the entire 'data' object from API into our UserData model
          userData.value = UserData.fromJson(body['data']);
          if (userData.value.userProfile == null) {
            // This case means 'data' was present but 'userProfile' nested object might be missing
            printError(
              info:
                  "User data fetched, but 'userProfile' object is null or missing in the response.",
            );
            // You might want to set hasError to true here if userProfile is critical
            // hasError.value = true; // Uncomment if this is an error state
          }
          hasError.value =
              false; // Set to false if UserData.fromJson was successful
        } else {
          printError(
            info:
                'API indicated failure or missing data: ${body['message'] ?? 'Unknown API error'}',
          );
          hasError.value = true;
        }
      } else {
        printError(
          info:
              'HTTP error ${response.statusCode} fetching profile data. Body: ${response.body}',
        );
        hasError.value = true;
      }
    } catch (e, stackTrace) {
      printError(
        info: 'Error fetching profile data: $e\nStackTrace: $stackTrace',
      );
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  // Method to clear user data on logout
  void clearUserData() {
    userData.value = UserData(); // Reset to a default/empty UserData object
    // You might also want to clear any other persisted user information (e.g., tokens)
  }
}
