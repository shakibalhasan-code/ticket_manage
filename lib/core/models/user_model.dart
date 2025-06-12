import 'dart:convert';

// Helper function to convert a JSON string to a UserData object
UserData userDataFromJson(String str) => UserData.fromJson(json.decode(str));

// Main class representing the 'data' object in your API response
class UserData {
  final String? id;
  final String? email;
  final String? role;
  final UserProfileDetails? userProfile;

  UserData({this.id, this.email, this.role, this.userProfile});

  // Factory constructor to create a UserData instance from a JSON map
  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json["_id"],
    email: json["email"],
    role: json["role"],
    userProfile:
        json["userProfile"] == null
            ? null
            : UserProfileDetails.fromJson(json["userProfile"]),
  );
}

// Class for the nested 'userProfile' object
class UserProfileDetails {
  final String? id;
  final String? fullName;
  final String? user;
  final String? phone; // Field for phone number
  final String? image; // Field for profile image URL

  UserProfileDetails({
    this.id,
    this.fullName,
    this.user,
    this.phone,
    this.image,
  });

  // Factory constructor to create a UserProfileDetails instance from a JSON map
  factory UserProfileDetails.fromJson(Map<String, dynamic> json) =>
      UserProfileDetails(
        id: json["_id"],
        fullName: json["fullName"],
        user: json["user"],
        phone: json["phone"], // Parse phone from JSON
        image: json["image"], // Parse image from JSON
      );
}
