import 'package:flutter/material.dart';
import 'package:flutterbook/DB.dart';

import 'Appointments/Appointments.dart';
import 'Contacts/Contacts.dart';
import 'Notes/Notes.dart';
import 'Tasks/Tasks.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DB.init();

  runApp(FlutterBook());
}

class FlutterBook extends StatelessWidget {
  const FlutterBook({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: Color(0xff3b0011),
              title: Text('FlutterBook'),
              bottom: TabBar(tabs: [
                Tab(icon: Icon(Icons.date_range), text: "Appointments"),
                Tab(icon: Icon(Icons.contacts), text: "Contacts"),
                Tab(icon: Icon(Icons.note), text: "Notes"),
                Tab(icon: Icon(Icons.assignment_turned_in), text: "Tasks")
              ])),
          body: TabBarView(children: [
            Appointments(),
            Contacts(),
            Notes(),
            Tasks(),
          ]),
        ),
      ),
    );
  }
}
