class ReportModel {
  String? sId;
  String? user;
  String? phone;
  List<String>? issue;
  String? description;
  String? userType;
  List<String>? images;
  String? status;
  bool? isDeleted;
  String? productId;
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
    this.images,
    this.status,
    this.isDeleted,
    this.productId,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  ReportModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'];
    phone = json['phone'];
    issue = json['issue'].cast<String>();
    description = json['description'];
    userType = json['userType'];
    images = json['images'].cast<String>();
    status = json['status'];
    isDeleted = json['isDeleted'];
    productId = json['productId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['user'] = this.user;
    data['phone'] = this.phone;
    data['issue'] = this.issue;
    data['description'] = this.description;
    data['userType'] = this.userType;
    data['images'] = this.images;
    data['status'] = this.status;
    data['isDeleted'] = this.isDeleted;
    data['productId'] = this.productId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
