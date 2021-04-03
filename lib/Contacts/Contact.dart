import 'package:flutterbook/Model.dart';

class Contact implements Model {
  @override
  int id;
  String name;
  String email;
  String phone;
  String birthday;
  String image;
  Contact(
      {this.id, this.name, this.email, this.phone, this.birthday, this.image});
  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birthday': birthday,
      'image': image
    };
    return map;
  }

  static Contact fromMap(Map<String, dynamic> map) => new Contact(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      birthday: map['birthday'],
      image: map['image']);
}
