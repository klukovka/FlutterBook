import 'package:flutterbook/Model.dart';

class Note implements Model {
  int id;
  String title;
  String content;
  String color = 'white';

  Note({this.id, this.title, this.content, this.color});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'title': title,
      'content': content,
      'color': color
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  static Note fromMap(Map<String, dynamic> map) => Note(
      color: map['color'],
      title: map['title'],
      content: map['content'],
      id: map['id']);
}
