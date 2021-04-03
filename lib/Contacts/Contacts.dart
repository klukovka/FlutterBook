import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterbook/Contacts/Contact.dart';
import 'package:flutterbook/Contacts/Utility.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

import '../DB.dart';

class Contacts extends StatefulWidget {
  Contacts({Key key}) : super(key: key);

  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  List<Contact> contacts = [];

  @override
  void initState() {
    refresh();
    super.initState();
  }

  void refresh() async {
    try{
    List<Map<String, dynamic>> _results = await DB.query('Contacts');
    contacts = _results.map((item) => Contact.fromMap(item)).toList();}
    catch(_){}
    setState(() {});
  }

  Future _addContact(BuildContext mainContext, Contact contact) {
    String _name = contact.name != null ? contact.name : '';
    String _email = contact.email != null ? contact.email : '';
    String _phone = contact.phone != null ? contact.phone : '';
    DateTime _date;
    String _image;

    void _pickImageFromTheGallery() {
      setState(() {
        ImagePicker()
            .getImage(source: ImageSource.gallery)
            .then((imgFile) async {
          _image = Utility.base64String(await imgFile.readAsBytes());
        });
      });
    }

    if (contact.birthday == null) {
      _date = DateTime.now();
    } else {
      List<String> parts = contact.birthday.split('.');
      _date = new DateTime(
          int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    }
    final TextEditingController _nameEditingController =
        TextEditingController(text: _name);
    final TextEditingController _emailEditingController =
        TextEditingController(text: _email);
    final TextEditingController _phoneEditingController =
        TextEditingController(text: _phone);
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
                            contact.id == null ? 'Task saved' : 'Task updated!';
                        Color color = contact.id == null
                            ? Colors.green
                            : Colors.indigo[900];

                        // ignore: deprecated_member_use
                        Scaffold.of(mainContext).showSnackBar(SnackBar(
                            backgroundColor: color,
                            duration: Duration(seconds: 2),
                            content: Text(label)));
                        contact.name = _name;
                        contact.phone = _phone;
                        contact.email = _email;
                        contact.image = _image;
                        contact.birthday =
                            DateFormat('dd.MM.yyyy').format(_date);

                        if (contact.id == null) {
                          List<Map<String, dynamic>> _results =
                              await DB.getLast('Contacts');
                          contact.id = _results
                              .map((item) => Contact.fromMap(item))
                              .toList()[0]
                              .id;
                          await DB.insert(contact, 'Contacts');
                          refresh();
                        } else {
                          await DB.update(contact, 'Contacts');

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
                    leading: Icon(Icons.contacts_rounded),
                    title: TextFormField(
                        // initialValue: _title,
                        decoration: InputDecoration(hintText: "Name"),
                        maxLines: 2,
                        controller: _nameEditingController,
                        validator: (String inValue) {
                          if (inValue.length == 0) {
                            return "Please enter a name";
                          }
                          _name = inValue;
                          return null;
                        }),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: TextFormField(
                        // initialValue: _title,
                        decoration: InputDecoration(hintText: "Phone"),
                        controller: _phoneEditingController,
                        validator: (String inValue) {
                          if (inValue.length == 0) {
                            return "Please enter a phone";
                          } else if (inValue.length != 10 ||
                              inValue[0] != '0') {
                            return "Please enter a correct phone";
                          } else if (inValue.length == 10) {
                            for (int i = 0; i < inValue.length; i++) {
                              try {
                                int.parse(inValue[i]);
                              } catch (_) {
                                return "Please enter a correct phone";
                              }
                            }
                          }
                          _phone = inValue;
                          return null;
                        }),
                  ),
                  ListTile(
                    leading: Icon(Icons.post_add_outlined),
                    title: TextFormField(
                        // initialValue: _title,
                        decoration: InputDecoration(hintText: "Email"),
                        controller: _emailEditingController,
                        validator: (String inValue) {
                          if (inValue.length == 0) {
                            return "Please enter a email";
                          } else if (inValue.lastIndexOf('@') == -1) {
                            return "Please enter a correct email";
                          }
                          _email = inValue;
                          return null;
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _image != null
                              ? Utility.imageFromBase64String(_image)
                              : Container(
                                  child: Icon(Icons.photo),
                                ),
                        ),
                        Column(
                          children: [
                            IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () async {
                                  _pickImageFromTheGallery();
                                  setState(() {});
                                }),
                            IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  setState(() {
                                    _image = null;
                                  });
                                }),
                          ],
                        )
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.cake),
                    title: Text('Birthday'),
                  ),
                  Container(
                    height: 300,
                    child: CupertinoDatePicker(
                        initialDateTime: _date,
                        maximumDate: DateTime.now(),
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff3b0011),
          child: Icon(Icons.add),
          tooltip: 'Add new contact',
          onPressed: () async {
            await _addContact(context, new Contact());
            setState(() {});
          },
        ),
        body: Text('${contacts.length}'));
  }
}
