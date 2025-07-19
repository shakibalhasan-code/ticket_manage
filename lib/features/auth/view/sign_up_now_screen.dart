import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workflowx/features/auth/controllers/auth_controller.dart';
import '../../../core/routes/app_pages.dart'; // Assuming this is correct

class SignUpNowScreen extends StatelessWidget {
  const SignUpNowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Create a new Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),

              // Name Label and TextField
              const Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller:
                    authController
                        .fullNameController, // Use controller from AuthController
                decoration: InputDecoration(
                  hintText: 'Enter your Name...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Email Label and TextField
              const Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller:
                    authController
                        .emailController, // Use controller from AuthController
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'example@gmail.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Password Label and TextField
              const Text(
                'Password',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Obx(
                () => TextField(
                  // Wrap with Obx for password visibility
                  controller:
                      authController
                          .passwordController, // Use controller from AuthController
                  obscureText: authController.isPasswordVisible.value,
                  decoration: InputDecoration(
                    hintText: 'Enter your Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        authController.isPasswordVisible.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        // Toggle password visibility
                        authController.isPasswordVisible.value =
                            !authController.isPasswordVisible.value;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Privacy policy checkbox and text
              Row(
                children: [
                  Obx(
                    () => Checkbox(
                      // Wrap with Obx for checkbox state
                      value: authController.agreeToPrivacyPolicy.value,
                      onChanged: (bool? newValue) {
                        authController.toggleAgreeToPrivacyPolicy();
                      },
                      activeColor: Colors.blue,
                    ),
                  ),
                  Expanded(
                    // Use Expanded so text doesn't overflow if long
                    child: InkWell(
                      // Make text tappable to also toggle checkbox
                      onTap: () {
                        authController.toggleAgreeToPrivacyPolicy();
                      },
                      child: const Text(
                        'I agree with privacy policy.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sign Up button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Obx(
                  () => ElevatedButton(
                    // Wrap with Obx for button state
                    onPressed:
                        authController.isLoading.value ||
                                !authController.agreeToPrivacyPolicy.value
                            ? null // Disable if loading or policy not agreed
                            : () {
                              authController.createAccount();
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.blue.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child:
                        authController.isLoading.value
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                            : const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ),
              const Spacer(),

              // Already have account? Sign In
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an Account? ',
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Sign In',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                // Optionally clear sign-up fields before navigating back
                                // authController.prepareForSignUp(); // Or specific clear methods
                                Get.back(); // Or Get.toNamed(Routes.signInNow) if you want to be explicit
                              },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
