// lib/screens/change_pass_screen.dart (Your screen file path)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workflowx/features/auth/controllers/auth_controller.dart';

// Import your AuthController

class ChangePassScreen extends StatelessWidget {
  const ChangePassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Get.put to initialize your controller.
    // If the controller is already initialized elsewhere (e.g., in a binding),
    // you can use Get.find<AuthController>() instead.
    final authController = Get.put(AuthController());
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // A light, clean background
      appBar: AppBar(
        title: const Text('Change Password'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black, // Use black for title and back arrow
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Text
                const Text(
                  'Create a New Password',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your new password must be different from previous ones.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 40),

                // Old Password Field
                _buildPasswordField(
                  controller: authController.oldPasswordController,
                  labelText: 'Old Password',
                  isObscured: authController.isOldPasswordObscured,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your old password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // New Password Field
                _buildPasswordField(
                  controller: authController.newPasswordController,
                  labelText: 'New Password',
                  isObscured: authController.isNewPasswordObscured,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Confirm New Password Field
                _buildPasswordField(
                  controller: authController.confirmPassController,
                  labelText: 'Confirm New Password',
                  isObscured: authController.isConfirmPasswordObscured,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != authController.newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Update Password Button
                Obx(
                  () => ElevatedButton(
                    onPressed:
                        authController.isLoading.value
                            ? null // Disable button while loading
                            : () => authController.updatePassword(formKey),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6200EE),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: const Color(0xFF6200EE).withOpacity(0.4),
                    ),
                    child:
                        authController.isLoading.value
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                            : const Text(
                              'Update Password',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A helper method to build a styled password text form field.
  /// It's wrapped in Obx to rebuild when the visibility toggles.
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required RxBool isObscured, // Use RxBool for reactivity
    required FormFieldValidator<String> validator,
  }) {
    return Obx(
      () => TextFormField(
        controller: controller,
        obscureText: isObscured.value,
        validator: validator,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey[700]),
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6200EE)),
          suffixIcon: IconButton(
            icon: Icon(
              isObscured.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey[600],
            ),
            onPressed: () => isObscured.toggle(), // Simple toggle
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6200EE), width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
        ),
      ),
    );
  }
}
