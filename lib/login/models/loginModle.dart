class LoginModel {
  String? message;
  User? user;
  List<Locations>? locations;
  String? token;

  LoginModel({this.message, this.user, this.locations, this.token});

  LoginModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    if (json['locations'] != null) {
      locations = <Locations>[];
      json['locations'].forEach((v) {
        locations!.add(new Locations.fromJson(v));
      });
    }
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.locations != null) {
      data['locations'] = this.locations!.map((v) => v.toJson()).toList();
    }
    data['token'] = this.token;
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? username;
  String? phone;
  String? userType;
  String? email;
  String? profilePhotoPath;

  User(
      {this.id,
      this.name,
      this.username,
      this.phone,
      this.userType,
      this.email,
      this.profilePhotoPath});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
    phone = json['phone'];
    userType = json['user_type'];
    email = json['email'];
    profilePhotoPath = json['profile_photo_path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['username'] = this.username;
    data['phone'] = this.phone;
    data['user_type'] = this.userType;
    data['email'] = this.email;
    data['profile_photo_path'] = this.profilePhotoPath;
    return data;
  }
}

class Locations {
  int? id;
  String? name;
  String? isActive;
  String? createdAt;
  String? updatedAt;

  Locations(
      {this.id, this.name, this.isActive, this.createdAt, this.updatedAt});

  Locations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    isActive = json['isActive'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['isActive'] = this.isActive;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
