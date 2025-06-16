class ReportModel {
  String? sId;
  String? user;
  String? phone;
  List<String>? issue;
  String? description;
  String? userType;
  String? distributor;
  List<String>? images;
  String? status;
  bool? isDeleted;
  ProductModel? productId; // Changed from String? to ProductModel?
  String? productSerialNumber;
  String? rejectedReason; // Added new field
  String? createdAt;
  String? updatedAt;
  int? iV;

  ReportModel({
    this.sId,
    this.user,
    this.phone,
    this.issue,
    this.description,
    this.userType,
    this.distributor,
    this.images,
    this.status,
    this.isDeleted,
    this.productId,
    this.productSerialNumber,
    this.rejectedReason, // Added to constructor
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      sId: json['_id'],
      user: json['user'],
      phone: json['phone'],
      issue: json['issue'] != null ? List<String>.from(json['issue']) : [],
      description: json['description'],
      userType: json['userType'],
      distributor: json['distributor'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      status: json['status'],
      isDeleted: json['isDeleted'],
      // Correctly parse the nested Product object
      productId:
          json['productId'] != null
              ? ProductModel.fromJson(json['productId'])
              : null,
      productSerialNumber: json['productSerialNumber'],
      // Map the new rejectedReason field
      rejectedReason: json['rejectedReason'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      iV: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['user'] = user;
    data['phone'] = phone;
    data['issue'] = issue;
    data['description'] = description;
    data['userType'] = userType;
    data['distributor'] = distributor;
    data['images'] = images;
    data['status'] = status;
    data['isDeleted'] = isDeleted;
    // Correctly convert the ProductModel object back to a map
    if (productId != null) {
      data['productId'] = productId!.toJson();
    }
    data['productSerialNumber'] = productSerialNumber;
    data['rejectedReason'] = rejectedReason;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class ProductModel {
  String? sId;
  String? model;
  String? image;
  String? description;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  int? iV;

  ProductModel({
    this.sId,
    this.model,
    this.image,
    this.description,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    sId: json["_id"],
    model: json["model"],
    image: json["image"],
    description: json["description"],
    isDeleted: json["isDeleted"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    iV: json["__v"],
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['model'] = model;
    data['image'] = image;
    data['description'] = description;
    data['isDeleted'] = isDeleted;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
