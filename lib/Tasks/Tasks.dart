import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterbook/DB.dart';
import 'package:flutterbook/Tasks/Task.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class Tasks extends StatefulWidget {
  Tasks({Key key}) : super(key: key);

  @override
  _TasksState createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  List<Task> tasks = [];

  @override
  void initState() {
    refresh();
    super.initState();
  }

  void refresh() async {
    List<Map<String, dynamic>> _results = await DB.query('Tasks');
    tasks = _results.map((item) => Task.fromMap(item)).toList();
    setState(() {});
  }

  Future _deleteTaskCont(BuildContext contextMain, Task task) async {
    return showDialog(
        context: contextMain,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Delete task'),
            content:
                Text('Are you sure you want to delete ${task.description}'),
            actions: [
              CupertinoDialogAction(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  await DB.delete(task, 'Tasks');
                  refresh();

                  Navigator.of(context).pop();
                  // ignore: deprecated_member_use
                  Scaffold.of(contextMain).showSnackBar(SnackBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                      content: Text("Note deleted")));
                },
              ),
            ],
          );
        });
  }

  Future _deleteTask(Task task) async {
    await DB.delete(task, 'Tasks');
    refresh();
  }

  Future _toggle(Task task) async {
    task.completed = task.completed == 'true' ? 'false' : 'true';
    await DB.update(task, 'Tasks');
    refresh();
  }

  Future _addTask(BuildContext mainContext, Task task) async {
    String _description = task.description != null ? task.description : '';
    DateTime _date;

    if (task.dueDate == null) {
      _date = DateTime.now();
    } else {
      List<String> parts = task.dueDate.split('.');
      _date = new DateTime(
          int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    }

    final TextEditingController _titleEditingController =
        TextEditingController(text: _description);
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return showCupertinoModalBottomSheet(
        context: mainContext,
        builder: (BuildContext context) {
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: [
                  CupertinoButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                  Spacer(),
                  CupertinoButton(
                      child: Text('Save'),
                      color: Colors.green,
                      onPressed: () async {
                        if (!_formKey.currentState.validate()) return;

                        Navigator.of(context).pop();
                        String label =
                            task.id == null ? 'Task saved' : 'Task updated!';
                        Color color =
                            task.id == null ? Colors.green : Colors.indigo[900];

                        // ignore: deprecated_member_use
                        Scaffold.of(mainContext).showSnackBar(SnackBar(
                            backgroundColor: color,
                            duration: Duration(seconds: 2),
                            content: Text(label)));

                        if (task.id == null) {
                          task.description = _description;
                          task.dueDate = DateFormat('dd.MM.yyyy').format(_date);
                          task.completed = 'false';
                          List<Map<String, dynamic>> _results =
                              await DB.getLast('Tasks');
                          task.id = _results
                              .map((item) => Task.fromMap(item))
                              .toList()[0]
                              .id;
                          DB.insert(task, 'Tasks');
                          refresh();
                        } else {
                          task.description = _description;
                          task.dueDate = DateFormat('dd.MM.yyyy').format(_date);
                          await DB.update(task, 'Tasks');

                          refresh();
                        }
                      }),
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.title),
                    title: TextFormField(
                        // initialValue: _title,
                        decoration: InputDecoration(hintText: "Description"),
                        controller: _titleEditingController,
                        validator: (String inValue) {
                          if (inValue.length == 0) {
                            return "Please enter a description";
                          }
                          _description = inValue;
                          return null;
                        }),
                  ),
                  Container(
                    height: 300,
                    child: CupertinoDatePicker(
                        initialDateTime: _date,
                        mode: CupertinoDatePickerMode.date,
                        onDateTimeChanged: (dateTime) {
                          setState(() {
                            _date = dateTime;
                          });
                        }),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (BuildContext context, int index) {
          Task task = tasks[index];
          return Container(
              padding: EdgeInsets.all(10),
              child: Dismissible(
                key: Key(task.id.toString()),
                onDismissed: (DismissDirection direction) => _deleteTask(task),
                child: CupertinoContextMenu(
                  // ignore: missing_required_param
                  // ignore: deprecated_member_use
                  child: FlatButton(
                    onPressed: () => _toggle(task),
                    child: Card(
                      elevation: 8,
                      color: Color(0xffded1d2),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                               // crossAxisAlignment: CrossAxisAlignment.start,
                               alignment: WrapAlignment.start,
                                children: [
                                  Text('${task.description}'),
                                  Text('${task.dueDate}'),
                                ],
                              ),
                            Spacer(),
                            Icon(
                                task.completed == 'true'
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: Color(0xff3b0011))
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    CupertinoContextMenuAction(
                      child: const Text('Edit'),
                      onPressed: () async {
                        Navigator.pop(context);
                        await _addTask(context, task);
                        setState(() {});
                        refresh();
                      },
                    ),
                    CupertinoContextMenuAction(
                      child: Text('Delete',
                          style: TextStyle(
                            color: Colors.red,
                          )),
                      onPressed: () async {
                        Navigator.pop(context);
                        await _deleteTaskCont(context, task);
                        setState(() {});
                        refresh();
                      },
                    ),
                  ],
                ),
              ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff3b0011),
        child: Icon(Icons.add),
        tooltip: 'Add new task',
        onPressed: () async {
          await _addTask(context, new Task());
          setState(() {});
          refresh();
        },
      ),
    );
  }
}
