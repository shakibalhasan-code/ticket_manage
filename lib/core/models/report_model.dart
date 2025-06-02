class ReportModel {
  String? sId;
  String? user;
  String? phone;
  String? issue;
  String? userType;
  List<String>? images;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? isDeleted;

  ReportModel({
    this.sId,
    this.user,
    this.phone,
    this.issue,
    this.userType,
    this.images,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.isDeleted,
  });

  ReportModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'];
    phone = json['phone'];
    issue = json['issue'];
    userType = json['userType'];
    images = json['images'].cast<String>();
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    isDeleted = json['isDeleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['user'] = this.user;
    data['phone'] = this.phone;
    data['issue'] = this.issue;
    data['userType'] = this.userType;
    data['images'] = this.images;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['isDeleted'] = this.isDeleted;
    return data;
  }
}
