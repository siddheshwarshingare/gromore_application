class UserModel {
  int? id;
  String? name;
  String? username;
  String? email;
  String? phone;
  String? address;
  String? isActive;
  String? twoFactorConfirmedAt;
  String? profilePhotoPath;
  int? userType;
  String? isBlocked;
  String? createdAt;
  String? updatedAt;
  String? profilePhotoUrl;

  UserModel(
      {this.id,
      this.name,
      this.username,
      this.email,
      this.phone,
      this.address,
      this.isActive,
      this.twoFactorConfirmedAt,
      this.profilePhotoPath,
      this.userType,
      this.isBlocked,
      this.createdAt,
      this.updatedAt,
      this.profilePhotoUrl});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    isActive = json['isActive'];
    twoFactorConfirmedAt = json['two_factor_confirmed_at'];
    profilePhotoPath = json['profile_photo_path'];
    userType = json['user_type'];
    isBlocked = json['isBlocked'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    profilePhotoUrl = json['profile_photo_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['username'] = this.username;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['isActive'] = this.isActive;
    data['two_factor_confirmed_at'] = this.twoFactorConfirmedAt;
    data['profile_photo_path'] = this.profilePhotoPath;
    data['user_type'] = this.userType;
    data['isBlocked'] = this.isBlocked;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['profile_photo_url'] = this.profilePhotoUrl;
    return data;
  }
}
