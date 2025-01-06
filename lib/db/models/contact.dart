class Contact {
  late int? id;
  late String? name;
  late int? userId;
  late String? phone;
  late String? email;
  late String? address;
  late int? groupId;

  Contact({
    this.id,
    required this.name,
    required this.userId,
    required this.phone,
    required this.email,
    this.address,
    required this.groupId,
  });

  Contact.withId({
    required this.id,
    required this.name,
    required this.userId,
    required this.phone,
    required this.email,
    this.address,
    required this.groupId,
  });

  Contact.jsonData({required this.userId, required this.groupId});

  Map<String, dynamic> toJson3() {
    return {
      "name": name,
      "phone": phone,
      "email": email,
      "address": address,
      "groupId": groupId,
      "userId": userId,
    };
  }

  Map<String, dynamic> toJson2() {
    return {
      "id": id,
      "name": name,
      "phone": phone,
      "email": email,
      "address": address,
      "groupId": groupId,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "groupId": groupId,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact.withId(
      id: int.tryParse(json['contact_id'].toString()),
      name: json['contact_name'],
      userId: int.tryParse(json['contact_userId'].toString()),
      phone: json['contact_phone'],
      email: json['contact_email'],
      address: json['contact_address'],
      groupId: int.tryParse(json['contact_group'].toString()),
    );
  }
}
