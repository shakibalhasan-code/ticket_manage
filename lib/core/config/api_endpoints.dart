class ApiEndpoints {
  // Base URL for images
  static const String baseImageUrl = 'http://192.168.10.18:5001';
  static const String baseUrl = 'http://192.168.10.18:5001/api';

  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/create-user';
  static const String verifyUser = '$baseUrl/auth/verify-user';

  static const String resendCode = '$baseUrl/auth/resend-code';

  static const String forgotPass = '$baseUrl/auth/forgot-password-request';
  static const String resetPass = '$baseUrl/auth/reset-password';

  static const String updatePassword = '$baseUrl/auth/update-password';

  static const String getAccessToken = '$baseUrl/auth/get-access-token';

  static const String getMe = '$baseUrl/user/me';

  static const String updateProfile = '$baseUrl/user/update-profile-data';

  static const String updateProfileImage = '$baseUrl/user/update-profile-image';
  static const String issueNewTicket = '$baseUrl/ticket/new-ticket';

  static const String getMyTicket = '$baseUrl/ticket/my-ticket?isRecent=false';

  static const String getNotifications =
      '$baseUrl/notification/get-notification-from-admin';

  static const String getTicketById = '$baseUrl/ticket';

  static const String getProducts = '$baseUrl/product';
  static const String getBrands = '$baseUrl/brand';

  static String getTicketMessages(String ticketId) => '$baseUrl/chat/$ticketId';

  static String notificationMarkAsRead(String notificationId) =>
      '$baseUrl/notification/mark-as-read/$notificationId';

  static String getSingleTicket(String ticketId) => '$baseUrl/ticket/$ticketId';

  static String updateUserProfile = '$baseUrl/user/update-profile-data';

  static String updateUserProfileImage = '$baseUrl/user/update-profile-image';

  static String getApplicator = '$baseUrl/distributor';

  static String deleteAccount = '$baseUrl/user/delete-me';
}
