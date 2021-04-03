import 'package:flutterbook/Model.dart';

class Appointment implements Model {
  @override
  int id;
  String title;
  String description;
  String apptDate;
  String apptTime;

  Appointment(
      {this.id, this.title, this.description, this.apptDate, this.apptTime});

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'title': title,
      'description': description,
      'apptDate': apptDate,
      'apptTime': apptTime
    };
    return map;
  }

  static Appointment fromMap(Map<String, dynamic> map) => new Appointment(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      apptDate: map['apptDate'],
      apptTime: map['apptTime']);
}
