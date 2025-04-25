class GetVegetableModel {
  List<Data>? data;

  GetVegetableModel({this.data});

  GetVegetableModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? price;
  Null? offerDetails;
  int? quantity;
  Null? imagePath;
  String? description;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
      this.name,
      this.price,
      this.offerDetails,
      this.quantity,
      this.imagePath,
      this.description,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    offerDetails = json['offer_details'];
    quantity = json['quantity'];
    imagePath = json['image_path'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    data['offer_details'] = this.offerDetails;
    data['quantity'] = this.quantity;
    data['image_path'] = this.imagePath;
    data['description'] = this.description;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
