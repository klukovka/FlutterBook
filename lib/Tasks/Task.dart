import 'package:flutterbook/Model.dart';

class Task implements Model {
  int id;
  String description;
  String dueDate;
  String completed = 'false';

  Task({
    this.id,
    this.completed,
    this.description,
    this.dueDate,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'description': description,
      'dueDate': dueDate,
      'completed': completed
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  static Task fromMap(Map<String, dynamic> map) => Task(
      completed: map['completed'],
      id: map['id'],
      description: map['description'],
      dueDate: map['dueDate']);
}
