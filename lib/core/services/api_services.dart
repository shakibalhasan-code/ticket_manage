import 'dart:convert';
import 'dart:io'; // Required for File related operations if you construct MultipartFile here
import 'package:http/http.dart' as http;
import 'package:workflowx/core/config/app_constants.dart';
import 'package:workflowx/core/helper/pref_helper.dart';
import 'package:workflowx/core/utils/glob_widget.dart'; // Still used for one specific toast

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
      // _handleResponseMessages(response); // REMOVED
      if (response.statusCode == 200) {
        print('Response Body (GET $url): ${response.body}');
        return response;
      } else {
        print('Error Response Body (GET $url): ${response.body}');
        // Let the calling code interpret the body for specific error messages
        throw Exception(
          'Failed to load data from $url. Status code: ${response.statusCode}. Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Exception in getRequest ($url): $e');
      rethrow;
    }
  }

  static Future<http.Response> fetchData({required String url}) async {
    try {
      final token = await PrefHelper.getString(AppConstants.token);
      if (token == null || token.isEmpty) {
        // This specific toast for a client-side check might still be desired.
        // If you want to remove ALL toasts from ApiServices, remove this too
        // and handle the exception in the calling code.
        GlobalBase.showToast(
          'Authentication token is missing. Please login again.',
          true,
        );
        throw Exception('Authentication token is missing. Please login again.');
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
      // _handleResponseMessages(response); // REMOVED
      if (response.statusCode == 200) {
        print('Response Body (GET $url): ${response.body}');
        return response;
      } else {
        print('Error Response Body (GET $url): ${response.body}');
        // Let the calling code interpret the body for specific error messages
        throw Exception(
          'Failed to load data from $url. Status code: ${response.statusCode}. Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Exception in fetchData ($url): $e');
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
      // _handleResponseMessages(response); // REMOVED
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Response Body (POST_ONLY $url): ${response.body}');
        return response;
      } else {
        print('Error Response Body (POST_ONLY $url): ${response.body}');
        // Let the calling code interpret the body for specific error messages
        throw Exception(
          'Failed POST_ONLY request to $url. Status code: ${response.statusCode}. Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Exception in postOnly ($url): $e');
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
        print('Error: Authentication token is missing for POST to $url.');
        // This specific toast for a client-side check might still be desired.
        GlobalBase.showToast(
          'Authentication token is missing. Please login again.',
          true,
        );
        throw Exception('Authentication token is missing. Please login again.');
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
      // _handleResponseMessages(response); // REMOVED
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Response Body (POST $url): ${response.body}');
        return response;
      } else {
        print('Error Response Body (POST $url): ${response.body}');
        // Let the calling code interpret the body for specific error messages
        throw Exception(
          'Failed POST request to $url. Status code: ${response.statusCode}. Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Exception in post ($url): $e');
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
      // _handleResponseMessages(response); // REMOVED
      if (response.statusCode == 200) {
        print('Response Body (PATCH_ONLY $url): ${response.body}');
        return response;
      } else {
        print('Error Response Body (PATCH_ONLY $url): ${response.body}');
        // Let the calling code interpret the body for specific error messages
        throw Exception(
          'Failed PATCH_ONLY request to $url. Status code: ${response.statusCode}. Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Exception in patchOnly ($url): $e');
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
        print('Error: Authentication token is missing for PATCH to $url.');
        // This specific toast for a client-side check might still be desired.
        GlobalBase.showToast(
          'Authentication token is missing. Please login again.',
          true,
        );
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
      // _handleResponseMessages(response); // REMOVED
      if (response.statusCode == 200) {
        print('Response Body (PATCH $url): ${response.body}');
        return response;
      } else {
        print('Error Response Body (PATCH $url): ${response.body}');
        // Let the calling code interpret the body for specific error messages
        throw Exception(
          'Failed PATCH request to $url. Status code: ${response.statusCode}. Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Exception in patch ($url): $e');
      rethrow;
    }
  }

  static Future<http.Response> postMultipart({
    required String url,
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
    bool requiresAuth = true,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers['Accept'] = 'application/json';
      // Note: 'Content-Type': 'multipart/form-data' is set automatically by http.MultipartRequest

      if (requiresAuth) {
        final token = await PrefHelper.getString(AppConstants.token);
        if (token == null || token.isEmpty) {
          print(
            'Error: Authentication token is missing for Multipart POST to $url.',
          );
          // This specific toast for a client-side check might still be desired.
          GlobalBase.showToast(
            'Authentication token is missing. Please login again.',
            true,
          );
          throw Exception(
            'Authentication token is missing. Please login again.',
          );
        }
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields.addAll(fields);
      request.files.addAll(files);

      print('Sending Multipart POST request to $url');
      print('Headers: ${request.headers}');
      print('Fields: $fields');
      print(
        'Files: ${files.map((f) => '${f.field}: ${f.filename} (${f.length} bytes)').join(', ')}',
      );

      final http.StreamedResponse streamedResponse = await request.send();
      final http.Response response = await http.Response.fromStream(
        streamedResponse,
      );

      // _handleResponseMessages(response); // REMOVED

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Response Body (Multipart POST $url): ${response.body}');
        return response;
      } else {
        print('Error Response Body (Multipart POST $url): ${response.body}');
        // Let the calling code interpret the body for specific error messages
        throw Exception(
          'Failed Multipart POST request to $url. Status code: ${response.statusCode}. Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Exception in postMultipart ($url): $e');
      rethrow;
    }
  }

  // REMOVED _handleResponseMessages function
  // static void _handleResponseMessages(http.Response response) {
  //   try {
  //     final responseBody = jsonDecode(response.body);
  //     if (responseBody is Map && responseBody.containsKey('message')) {
  //       bool isError = response.statusCode >= 400;
  //       GlobalBase.showToast(responseBody['message'], isError);
  //     }
  //   } catch (e) {
  //     print(
  //       'Could not parse message from response or message key missing: ${response.body}',
  //     );
  //   }
  // }
}
