class Product {
  String? sId;
  String? model;
  String? image;
  String? description;
  String? createdAt;
  String? updatedAt;
  String? brand;
  String? brandName;
  String? brandImage;

  Product({
    this.sId,
    this.model,
    this.image,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.brand,
    this.brandName,
    this.brandImage,
  });

  Product.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    model = json['model'];
    image = json['image'];
    description = json['description'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    brand = json['brand'];
    brandName = json['brandName'];
    brandImage = json['brandImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['model'] = this.model;
    data['image'] = this.image;
    data['description'] = this.description;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['brand'] = this.brand;
    data['brandName'] = this.brandName;
    data['brandImage'] = this.brandImage;
    return data;
  }
}
