import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:workflowx/core/config/api_endpoints.dart';
import 'package:workflowx/core/config/app_constants.dart';
import 'package:workflowx/core/helper/pref_helper.dart';
import 'package:workflowx/core/routes/app_pages.dart'; // Make sure these routes exist
import 'package:workflowx/core/services/api_services.dart';

class AuthController extends GetxController {
  /// Controllers for authentication
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpPinController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPassContoller = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var agreeToPrivacyPolicy = false.obs;

  // --- State for Change Password Screen ---
  var isOldPasswordObscured = true.obs;
  var isNewPasswordObscured = true.obs;
  var isConfirmPasswordObscured = true.obs;

  /// Stores email for password reset flow
  var emailForPasswordReset = ''.obs;

  /// OTP resend countdown timer
  var otpResendSeconds = 60.obs;
  Timer? _otpResendTimer;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    newPasswordController.dispose();
    confirmPassContoller.dispose();
    fullNameController.dispose();

    super.onClose();
  }

  Future<void> createAccount() async {
    try {
      isLoading.value = true;
      final body = {
        "email": emailController.text.trim(),
        "fullName": fullNameController.text.trim(),
        "password": passwordController.text.trim(),
      };

      final response = await ApiServices.postOnly(
        url: ApiEndpoints.register,
        body: body,
      );

      if (response.statusCode == 200) {
        // After registration, navigate to OTP verification screen
        Get.offAllNamed(Routes.forgotPasswordVerify);
      } else {
        final responseData = jsonDecode(response.body);
      }
    } catch (e) {
      printError(info: 'Error during account creation: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginAccount() async {
    try {
      isLoading.value = true;
      final body = {
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      };
      final response = await ApiServices.postOnly(
        url: ApiEndpoints.login,
        body: body,
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['data']['accessToken'] ?? '';
        final userId = responseData['data']['userData']['_id'] ?? '';
        if (userId.isEmpty) {
          isLoading.value = false;
          Get.snackbar(
            'Error',
            'User ID is empty. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        await PrefHelper.setString(AppConstants.userId, userId);

        if (token.isEmpty) {
          isLoading.value = false;
          return;
        }
        await PrefHelper.setString(AppConstants.token, token);
        Get.offAllNamed(Routes.home);
      } else {
        final responseData = jsonDecode(response.body);
      }
    } catch (e) {
      printError(info: 'Error during login: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    try {
      isLoading.value = true;

      final otpValue = otpPinController.text.trim();
      if (otpValue.length != 4) {
        isLoading.value = false;
        return;
      }

      // Pick email for OTP verification
      final emailToVerify =
          emailForPasswordReset.value.isNotEmpty
              ? emailForPasswordReset.value
              : emailController.text.trim();

      if (emailToVerify.isEmpty) {
        isLoading.value = false;
        return;
      }

      final body = {'email': emailToVerify, 'otp': otpValue};

      final response = await ApiServices.patchOnly(
        url: ApiEndpoints.verifyUser,
        body: body,
      );

      if (response.statusCode == 200) {
        otpPinController.clear();

        if (emailForPasswordReset.value.isNotEmpty) {
          Get.offAllNamed(Routes.createNewPassword);
        } else {
          Get.offAllNamed(Routes.signInNow);
        }
      } else {
        final responseData = jsonDecode(response.body);
      }
    } catch (e) {
      printError(info: 'Error during OTP verification: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (otpResendSeconds.value != 0 || isLoading.value) return;

    try {
      isLoading.value = true;

      final emailToResend =
          emailForPasswordReset.value.isNotEmpty
              ? emailForPasswordReset.value
              : emailController.text.trim();

      if (emailToResend.isEmpty) {
        isLoading.value = false;
        return;
      }

      final body = {'email': emailToResend};

      final response = await ApiServices.patchOnly(
        url: ApiEndpoints.forgotPass,
        body: body,
      );

      if (response.statusCode == 200) {
        otpResendSeconds.value = 60;
        _startOtpResendTimer();
      } else {
        final responseData = jsonDecode(response.body);
      }
    } catch (e) {
      printError(info: 'Error during OTP resend: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPass() async {
    try {
      isLoading.value = true;
      if (newPasswordController.text.trim() !=
          confirmPassContoller.text.trim()) {
        isLoading.value = false;
        return;
      }
      if (emailForPasswordReset.value.isEmpty) {
        isLoading.value = false;
        Get.offAllNamed(Routes.signIn);
        return;
      }

      final body = {
        'new_password': newPasswordController.text.trim(),
        'confirm_password': confirmPassContoller.text.trim(),
      };

      final response = await ApiServices.patch(
        url: ApiEndpoints.resetPass,
        body: body,
      );
      if (response.statusCode == 200) {
        Get.offAllNamed(Routes.signIn);
      } else {
        final responseData = jsonDecode(response.body);
      }
    } catch (e) {
      printError(info: 'Error during password reset: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgot() async {
    try {
      isLoading.value = true;
      final email = emailController.text.trim();
      if (email.isEmpty) {
        isLoading.value = false;
        return;
      }
      final body = {'email': email};
      final response = await ApiServices.patchOnly(
        url: ApiEndpoints.forgotPass,
        body: body,
      );
      if (response.statusCode == 200) {
        emailForPasswordReset.value = email;
        Get.toNamed(Routes.forgotPasswordVerify);
        onOtpScreenInit();
      } else {
        final responseData = jsonDecode(response.body);
      }
    } catch (e) {
      printError(info: 'Error during forgot password: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _startOtpResendTimer() {
    _otpResendTimer?.cancel();
    _otpResendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpResendSeconds.value == 0) {
        timer.cancel();
      } else {
        otpResendSeconds.value--;
      }
    });
  }

  void onOtpScreenInit() {
    otpPinController.clear();
    otpResendSeconds.value = 60;
    _startOtpResendTimer();
  }

  void toggleAgreeToPrivacyPolicy() {
    agreeToPrivacyPolicy.value = !agreeToPrivacyPolicy.value;
  }

  /// Handles the logic for the "Update Password" button press on the profile/settings page.
  Future<void> updatePassword(GlobalKey<FormState> formKey) async {
    // 1. Validate the form
    if (!formKey.currentState!.validate()) {
      return; // If form is not valid, do nothing.
    }

    try {
      isLoading.value = true;

      // 2. Prepare the request body from the controllers
      final body = {
        "old_password": oldPasswordController.text,
        "new_password": newPasswordController.text,
        "confirm_password": confirmPassController.text,
      };

      // 3. Make the API call
      // Using a mock service here, replace with your actual ApiServices.post
      await ApiServices.patch(url: ApiEndpoints.updatePassword, body: body);

      // 4. Handle success
      Get.snackbar(
        'Success',
        'Your password has been changed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      // 5. Clear fields and reset form state
      formKey.currentState?.reset();
      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPassController.clear();
    } catch (e) {
      // 6. Handle errors
      Get.snackbar(
        'Error',
        'Failed to change password. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      printError(info: 'Error during password change: $e');
    } finally {
      // 7. Ensure loading indicator is turned off
      isLoading.value = false;
    }
  }
}
