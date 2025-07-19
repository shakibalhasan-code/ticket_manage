import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:workflowx/core/routes/app_pages.dart';
import 'package:workflowx/features/auth/controllers/auth_controller.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Obx(() {
                  // Show emailForPasswordReset if set, else fallback to emailController.text
                  final displayEmail =
                      authController.emailForPasswordReset.value.isNotEmpty
                          ? authController.emailForPasswordReset.value
                          : authController.emailController.text;

                  return RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'Code has been sent to\n'),
                        TextSpan(
                          text: displayEmail,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 4,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 60,
                      fieldWidth: 60,
                      activeFillColor: Colors.white,
                      inactiveFillColor: Colors.grey.shade200,
                      selectedFillColor: Colors.white,
                      activeColor: Colors.blue,
                      inactiveColor: Colors.grey.shade400,
                      selectedColor: Colors.blueAccent,
                      borderWidth: 1.5,
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    controller: authController.otpPinController,
                    keyboardType: TextInputType.number,
                    boxShadows: const [
                      BoxShadow(
                        offset: Offset(0, 1),
                        color: Colors.black12,
                        blurRadius: 10,
                      ),
                    ],
                    onCompleted: (v) {
                      // No need to store OTP separately; controller text is enough
                      print("Completed OTP: $v");
                      // Optionally, auto-submit on completion:
                      // authController.verifyOtp();
                    },
                    onChanged: (value) {
                      print("Current OTP part: $value");
                    },
                    beforeTextPaste: (text) {
                      print("Allowing to paste $text");
                      return true;
                    },
                  ),
                ),

                const SizedBox(height: 32),

                Obx(
                  () => GestureDetector(
                    onTap:
                        authController.otpResendSeconds.value == 0 &&
                                !authController.isLoading.value
                            ? () {
                              authController.resendOtp();
                            }
                            : null,
                    child: Text(
                      authController.otpResendSeconds.value > 0
                          ? 'Resend Code in ${authController.otpResendSeconds.value}s'
                          : 'Didn\'t receive the code? Resend',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            authController.otpResendSeconds.value > 0
                                ? Colors.grey.shade600
                                : (authController.isLoading.value
                                    ? Colors.grey.shade600
                                    : Colors.blue),
                        fontWeight:
                            authController.otpResendSeconds.value == 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.15),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed:
                          authController.isLoading.value
                              ? null
                              : () {
                                authController.verifyOtp();
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        disabledBackgroundColor: Colors.blue.withOpacity(0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          authController.isLoading.value
                              ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                              : const Text(
                                'Verify',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
