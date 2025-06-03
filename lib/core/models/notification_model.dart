class NotificationModel {
  String? sId;
  String? title;
  String? description;
  String? user;
  String? ticketId;
  bool? isRead;
  String? createdAt;
  String? updatedAt;
  int? iV;

  NotificationModel({
    this.sId,
    this.title,
    this.description,
    this.user,
    this.ticketId,
    this.isRead,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    description = json['description'];
    user = json['user'];
    ticketId = json['ticketId'];
    isRead = json['isRead'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['user'] = this.user;
    data['ticketId'] = this.ticketId;
    data['isRead'] = this.isRead;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
