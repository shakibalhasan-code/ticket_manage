class DistributorModel {
  String? sId;
  String? shopAddress;
  String? shopName;

  DistributorModel({this.sId, this.shopAddress, this.shopName});

  DistributorModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    shopAddress = json['shopAddress'];
    shopName = json['shopName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['shopAddress'] = this.shopAddress;
    data['shopName'] = this.shopName;
    return data;
  }
}
