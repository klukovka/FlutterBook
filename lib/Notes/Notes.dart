import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterbook/Notes/Note.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:flutterbook/DB.dart';

class Notes extends StatefulWidget {
  Notes({Key key}) : super(key: key);

  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  List<Note> notes = [];
  Future _addNote(BuildContext mainContext, Note note) async {
    String _title = note.title != null ? note.title : '';
    String _content = note.content != null ? note.content : '';
    String _color = note.color != null ? note.color : 'white';
    final TextEditingController _titleEditingController =
        TextEditingController(text: _title);
    final TextEditingController _contentEditingController =
        TextEditingController(text: _content);
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
                            note.id == null ? 'Note saved' : 'Note updated!';
                        Color color =
                            note.id == null ? Colors.green : Colors.indigo[900];

                        // ignore: deprecated_member_use
                        Scaffold.of(mainContext).showSnackBar(SnackBar(
                            backgroundColor: color,
                            duration: Duration(seconds: 2),
                            content: Text(label)));

                        if (note.id == null) {
                          note.title = _title;
                          note.content = _content;
                          note.color = _color;
                          List<Map<String, dynamic>> _results =
                              await DB.getLast('Notes');
                          note.id = _results
                              .map((item) => Note.fromMap(item))
                              .toList()[0]
                              .id;
                          DB.insert(note, 'Notes');
                          refresh();
                        } else {
                          note.title = _title;
                          note.content = _content;
                          note.color = _color;
                          await DB.update(note, 'Notes');
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
                        decoration: InputDecoration(hintText: "Title"),
                        controller: _titleEditingController,
                        validator: (String inValue) {
                          if (inValue.length == 0) {
                            return "Please enter a title";
                          }
                          _title = inValue;
                          return null;
                        }),
                  ),
                  ListTile(
                    leading: Icon(Icons.content_paste),
                    title: TextFormField(
                        // initialValue: 'kkkk',
                        keyboardType: TextInputType.multiline,
                        maxLines: 8,
                        decoration: InputDecoration(hintText: "Content"),
                        controller: _contentEditingController,
                        validator: (String inValue) {
                          if (inValue.length == 0) {
                            return "Please enter content";
                          }
                          _content = inValue;
                          return null;
                        }),
                  ),
                  ListTile(
                    leading: Icon(Icons.color_lens),
                    title: Row(
                      children: [
                        GestureDetector(
                          child: Container(
                              decoration: ShapeDecoration(
                                  shape:
                                      Border.all(width: 18, color: Colors.red) +
                                          Border.all(
                                              width: 6,
                                              color: _color == "red"
                                                  ? Colors.red
                                                  : Theme.of(context)
                                                      .canvasColor))),
                          onTap: () {
                            setState(() {
                              _color = 'red';
                            });
                          },
                        ),
                        Spacer(),
                        GestureDetector(
                          child: Container(
                              decoration: ShapeDecoration(
                                  shape: Border.all(
                                          width: 18, color: Colors.green) +
                                      Border.all(
                                          width: 6,
                                          color: _color == "green"
                                              ? Colors.green
                                              : Theme.of(context)
                                                  .canvasColor))),
                          onTap: () {
                            setState(() {
                              _color = 'green';
                            });
                          },
                        ),
                        Spacer(),
                        GestureDetector(
                          child: Container(
                              decoration: ShapeDecoration(
                                  shape: Border.all(
                                          width: 18, color: Colors.blue) +
                                      Border.all(
                                          width: 6,
                                          color: _color == "blue"
                                              ? Colors.blue
                                              : Theme.of(context)
                                                  .canvasColor))),
                          onTap: () {
                            setState(() {
                              _color = 'blue';
                            });
                          },
                        ),
                        Spacer(),
                        GestureDetector(
                          child: Container(
                              decoration: ShapeDecoration(
                                  shape: Border.all(
                                          width: 18, color: Colors.yellow) +
                                      Border.all(
                                          width: 6,
                                          color: _color == "yellow"
                                              ? Colors.yellow
                                              : Theme.of(context)
                                                  .canvasColor),),),
                          onTap: () {
                            setState(() {
                              _color = 'yellow';
                            });
                          },
                        ),
                        Spacer(),
                        GestureDetector(
                          child: Container(
                              decoration: ShapeDecoration(
                                  shape: Border.all(
                                          width: 18, color: Colors.grey) +
                                      Border.all(
                                          width: 6,
                                          color: _color == "grey"
                                              ? Colors.grey
                                              : Theme.of(context)
                                                  .canvasColor))),
                          onTap: () {
                            setState(() {
                              _color = 'grey';
                            });
                          },
                        ),
                        Spacer(),
                        GestureDetector(
                          child: Container(
                              decoration: ShapeDecoration(
                                  shape: Border.all(
                                          width: 18, color: Colors.purple) +
                                      Border.all(
                                          width: 6,
                                          color: _color == "purple"
                                              ? Colors.purple
                                              : Theme.of(context)
                                                  .canvasColor))),
                          onTap: () {
                            setState(() {
                              _color = 'purple';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future _deleteNote(BuildContext contextMain, Note note) async {
    return showDialog(
        context: contextMain,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Delete note'),
            content: Text('Are you sure you want to delete ${note.title}'),
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
                  await DB.delete(note, 'Notes');
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

  @override
  void initState() {
    refresh();
    super.initState();
  }

  void refresh() async {
    List<Map<String, dynamic>> _results = await DB.query('Notes');
    notes = _results.map((item) => Note.fromMap(item)).toList();
    try{
    setState(() {});
    } catch(_){}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (BuildContext context, int index) {
          Note note = notes[index];
          Color color = Colors.white;
          switch (note.color) {
            case "red":
              color = Colors.red[400];
              break;
            case "green":
              color = Colors.green[400];
              break;
            case "blue":
              color = Colors.blue[400];
              break;
            case "yellow":
              color = Colors.yellow[400];
              break;
            case "grey":
              color = Colors.grey[400];
              break;
            case "purple":
              color = Colors.purple[400];
              break;
          }
          return Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: CupertinoContextMenu(
                child: Card(
                  elevation: 8,
                  color: color,
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Text(note.content),
                  ),
                ),
                actions: <Widget>[
                  CupertinoContextMenuAction(
                    child: const Text('Edit'),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _addNote(context, note);
                      setState(() {});
                    },
                  ),
                  CupertinoContextMenuAction(
                    child: Text('Delete',
                        style: TextStyle(
                          color: Colors.red,
                        )),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _deleteNote(context, note);
                      setState(() {});
                    },
                  ),
                ]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff3b0011),
        child: Icon(Icons.add),
        tooltip: 'Add new note',
        onPressed: () async {
          await _addNote(context, new Note());
          setState(() {});
        },
      ),
    );
  }
}
