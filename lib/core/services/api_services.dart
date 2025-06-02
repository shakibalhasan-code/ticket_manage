import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:workflowx/core/config/app_constants.dart';
import 'package:workflowx/core/helper/pref_helper.dart';
import 'package:workflowx/core/utils/glob_widget.dart';

class ApiServices {
  static Future<http.Response> getRequest({required String url}) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      // Consider moving toast logic to the caller or making it conditional
      _handleResponseMessages(response);
      if (response.statusCode == 200) {
        print('Response Body (GET $url): ${response.body}');
        return response;
      } else {
        print('Error Response Body (GET $url): ${response.body}');
        throw Exception(
          'Failed to load data from $url. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Exception in getRequest ($url): $e');
      // GlobalBase.showToast('Network error or server issue.', true); // Optional: Generic error for network issues
      rethrow;
    }
  }

  static Future<http.Response> fetchData({required String url}) async {
    try {
      final token = await PrefHelper.getString(AppConstants.token);
      if (token == null || token.isEmpty) {
        GlobalBase.showToast(
          'Authentication token is missing. Please login again.',
          true,
        ); // Changed to true for error
      }
      print('Fetching data from $url with token: $token');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': ' Bearer $token',
        },
      );
      // Consider moving toast logic to the caller or making it conditional
      _handleResponseMessages(response);
      if (response.statusCode == 200) {
        print('Response Body (GET $url): ${response.body}');
        return response;
      } else {
        print('Error Response Body (GET $url): ${response.body}');
        throw Exception(
          'Failed to load data from $url. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Exception in getRequest ($url): $e');
      // GlobalBase.showToast('Network error or server issue.', true); // Optional: Generic error for network issues
      rethrow;
    }
  }

  static Future<http.Response> postOnly({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
      _handleResponseMessages(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 201 is also common for POST success
        print('Response Body (POST_ONLY $url): ${response.body}');
        return response;
      } else {
        print('Error Response Body (POST_ONLY $url): ${response.body}');
        throw Exception(
          'Failed POST_ONLY request to $url. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Exception in postOnly ($url): $e');
      // GlobalBase.showToast('Network error or server issue.', true);
      rethrow;
    }
  }

  static Future<http.Response> post({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      final token = await PrefHelper.getString(AppConstants.token);
      if (token == null || token.isEmpty) {
        // GlobalBase.showToast('Authentication token is missing.', true); // Changed to true for error
        print('Error: Authentication token is missing for POST to $url.');
        throw Exception(
          'Authentication token is missing. Please login again.',
        ); // Critical error
      }
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      _handleResponseMessages(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Response Body (POST $url): ${response.body}');
        return response;
      } else {
        print('Error Response Body (POST $url): ${response.body}');
        throw Exception(
          'Failed POST request to $url. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Exception in post ($url): $e');
      // GlobalBase.showToast('Network error or server issue.', true);
      rethrow;
    }
  }

  static Future<http.Response> patchOnly({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      _handleResponseMessages(response);
      if (response.statusCode == 200) {
        print('Response Body (PATCH_ONLY $url): ${response.body}');
        return response;
      } else {
        print('Error Response Body (PATCH_ONLY $url): ${response.body}');
        throw Exception(
          'Failed PATCH_ONLY request to $url. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Exception in patchOnly ($url): $e');
      // GlobalBase.showToast('Network error or server issue.', true);
      rethrow;
    }
  }

  static Future<http.Response> patch({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      final token = await PrefHelper.getString(AppConstants.token);
      if (token == null || token.isEmpty) {
        // GlobalBase.showToast('Authentication token is missing.', true);
        print('Error: Authentication token is missing for PATCH to $url.');
        throw Exception('Authentication token is missing. Please login again.');
      }
      final response = await http.patch(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      _handleResponseMessages(response);
      if (response.statusCode == 200) {
        print('Response Body (PATCH $url): ${response.body}');
        return response;
      } else {
        print('Error Response Body (PATCH $url): ${response.body}');
        throw Exception(
          'Failed PATCH request to $url. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Exception in patch ($url): $e');
      // GlobalBase.showToast('Network error or server issue.', true);
      rethrow;
    }
  }

  // Helper to show messages from response if available
  static void _handleResponseMessages(http.Response response) {
    try {
      final responseBody = jsonDecode(response.body);
      if (responseBody is Map && responseBody.containsKey('message')) {
        // Show toast for errors (4xx, 5xx), optionally for success (2xx)
        bool isError = response.statusCode >= 400;
        GlobalBase.showToast(responseBody['message'], isError);
      }
    } catch (e) {
      // JSON decoding failed or 'message' key missing, do nothing or log
      print(
        'Could not parse message from response or message key missing: ${response.body}',
      );
    }
  }
}
