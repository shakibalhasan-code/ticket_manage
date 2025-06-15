class ReportModel {
  String? sId;
  String? user; // This could be a user ID
  String? phone;
  List<String>? issue;
  String? description;
  String? note; // Added missing field from JSON
  String? userType;
  String? distributor; // Added missing field from JSON
  String? productSerialNumber;
  List<String>? images;
  String? status;
  bool? isDeleted;
  String? productId; // This could be a product ID
  String? createdAt;
  String? updatedAt;
  int? iV;

  ReportModel({
    this.sId,
    this.user,
    this.phone,
    this.issue,
    this.description,
    this.note, // Added to constructor
    this.userType,
    this.distributor, // Added to constructor
    this.images,
    this.status,
    this.isDeleted,
    this.productId,
    this.productSerialNumber,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  // This fromJson constructor is now fixed and more robust
  ReportModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];

    // --- FIX 1: Handle populated 'user' field ---
    // Check if 'user' is a Map (populated object) or a simple String ID
    if (json['user'] is Map<String, dynamic>) {
      user = json['user']['_id']; // Extract the ID from the map
    } else {
      user = json['user']; // It's already a String
    }

    phone = json['phone'];
    // Use List.from for safer casting
    issue = json['issue'] != null ? List<String>.from(json['issue']) : [];
    description = json['description'];
    note = json['note']; // Mapped the 'note' field
    userType = json['userType'];
    distributor = json['distributor']; // Mapped the 'distributor' field
    images = json['images'] != null ? List<String>.from(json['images']) : [];
    status = json['status'];

    // --- FIX 2: Correctly map 'productSerialNumber' ---
    // The original code was incorrectly assigning this to 'status' again.
    productSerialNumber = json['productSerialNumber'];

    isDeleted = json['isDeleted'];

    // --- FIX 3: Handle populated 'productId' field ---
    // Do the same check for productId
    if (json['productId'] is Map<String, dynamic>) {
      productId = json['productId']['_id'];
    } else {
      productId = json['productId'];
    }

    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  // No changes needed for toJson, but good practice to include all fields
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['user'] = this.user;
    data['phone'] = this.phone;
    data['issue'] = this.issue;
    data['description'] = this.description;
    data['note'] = this.note;
    data['userType'] = this.userType;
    data['distributor'] = this.distributor;
    data['images'] = this.images;
    data['status'] = this.status;
    data['productSerialNumber'] = this.productSerialNumber;
    data['isDeleted'] = this.isDeleted;
    data['productId'] = this.productId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
