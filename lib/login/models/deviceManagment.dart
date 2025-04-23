class DeviceManagmentModel {
  String? message;
  List<Devices>? devices;

  DeviceManagmentModel({this.message, this.devices});

  DeviceManagmentModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['devices'] != null) {
      devices = <Devices>[];
      json['devices'].forEach((v) {
        devices!.add(new Devices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.devices != null) {
      data['devices'] = this.devices!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Devices {
  int? id;
  String? name;
  String? lastUsedAt;
  String? createdAt;

  Devices({this.id, this.name, this.lastUsedAt, this.createdAt});

  Devices.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    lastUsedAt = json['last_used_at'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['last_used_at'] = this.lastUsedAt;
    data['created_at'] = this.createdAt;
    return data;
  }
}
