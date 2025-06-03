import 'package:get/get.dart';
import 'package:workflowx/features/auth/bindings/auth_binding.dart';
import 'package:workflowx/features/auth/view/create_new_password_screen.dart';
import 'package:workflowx/features/auth/view/forget_password_verify_screen.dart';
import 'package:workflowx/features/auth/view/sign_in_now_screen.dart';
import 'package:workflowx/features/auth/view/sign_in_screen.dart';
import 'package:workflowx/features/auth/view/sign_up_now_screen.dart';
import 'package:workflowx/features/auth/view/forget_password_screen.dart';
import 'package:workflowx/features/home/views/file_report_screen.dart';
import 'package:workflowx/features/home/views/privacy_policy_screen.dart';
import 'package:workflowx/features/home/views/profile_details_screen.dart';
import 'package:workflowx/features/home/views/report_preview_reply_screen.dart';
import 'package:workflowx/features/splash/screens/splash_screen.dart';

import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_view.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => SplashScreen(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.signIn,
      page: () => SignInScreen(),
      transition: Transition.rightToLeft,
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.signInNow,
      page: () => const SignInNowScreen(),
      transition: Transition.rightToLeft,
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.signUpNow,
      page: () => SignUpNowScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => ForgetPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.forgotPasswordVerify,
      transition: Transition.rightToLeft,
      page: () => OtpVerificationScreen(),
    ),
    GetPage(
      name: Routes.createNewPassword,
      transition: Transition.rightToLeft,
      page: () => const CreateNewPasswordScreen(),
    ),
    GetPage(
      name: Routes.profile,

      transition: Transition.rightToLeft,

      page: () => const ProfileDetailsScreen(),
    ),
    GetPage(
      name: Routes.privacyPolicy,
      page: () => const PrivacyPolicyScreen(),
      transition: Transition.rightToLeft,
    ),

    // GetPage(
    //   name: Routes.reportReply,
    //   page: () => ReportDetailsWithMessagesScreen(),
    //   transition: Transition.rightToLeft,
    // ),
  ];
}
