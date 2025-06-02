class Brand {
  String? sId;
  String? name;
  String? image;
  String? description;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Brand({
    this.sId,
    this.name,
    this.image,
    this.description,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Brand.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    image = json['image'];
    description = json['description'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['image'] = this.image;
    data['description'] = this.description;
    data['isDeleted'] = this.isDeleted;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
