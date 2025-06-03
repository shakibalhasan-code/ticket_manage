class UserProfileDetails {
  String? sId;
  String? fullName;
  String?
  user; // This is the ID of the parent User object from within userProfile
  int? v; // For "__v"
  String? address;
  DateTime? dateOfBirth; // Store as DateTime for easier manipulation
  String? nickname;
  String? phone;
  String? image;

  UserProfileDetails({
    this.sId,
    this.fullName,
    this.user,
    this.v,
    this.address,
    this.dateOfBirth,
    this.nickname,
    this.phone,
    this.image,
  });

  UserProfileDetails.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    user = json['user'];
    v = json['__v'];
    address = json['address'];
    if (json['dateOfBirth'] != null) {
      dateOfBirth = DateTime.tryParse(json['dateOfBirth']);
    }
    nickname = json['nickname'];
    phone = json['phone'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['user'] = user;
    data['__v'] = v;
    data['address'] = address;
    data['dateOfBirth'] = dateOfBirth?.toIso8601String();
    data['nickname'] = nickname;
    data['phone'] = phone;
    data['image'] = image;
    return data;
  }
}

// OPTIONAL: If you want a model for the entire `data` object from the API response:
class UserData {
  String? id; // Corresponds to _id at the top level of "data"
  String? email;
  String? role;
  bool? isVerified;
  bool? isDeleted;
  UserProfileDetails? userProfile; // Nested UserProfileDetails

  UserData({
    this.id,
    this.email,
    this.role,
    this.isVerified,
    this.isDeleted,
    this.userProfile,
  });

  UserData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    email = json['email'];
    role = json['role'];
    isVerified = json['isVerified'];
    isDeleted = json['isDeleted'];
    if (json['userProfile'] != null &&
        json['userProfile'] is Map<String, dynamic>) {
      userProfile = UserProfileDetails.fromJson(json['userProfile']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['email'] = email;
    data['role'] = role;
    data['isVerified'] = isVerified;
    data['isDeleted'] = isDeleted;
    if (userProfile != null) {
      data['userProfile'] = userProfile!.toJson();
    }
    return data;
  }
}
