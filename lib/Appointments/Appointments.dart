import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutterbook/Appointments/Appointment.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../DB.dart';

class Appointments extends StatefulWidget {
  Appointments({Key key}) : super(key: key);

  @override
  _AppointmentsState createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  List<Appointment> appointments = [];
  // ignore: missing_required_param
  EventList<Event> _markedDateMap;
  DateTime _currentDate = DateTime.now();
  TimeOfDay _currentTime = TimeOfDay.now();
  String _currTime() =>
      _currentTime.hour.toString() +
      ":" +
      _currentTime.minute.toString() +
      ':00';

  @override
  void initState() {
    refresh();
    super.initState();
  }

  Future<void> refresh() async {
    List<Map<String, dynamic>> _results = await DB.query('Appointments');
    appointments = _results.map((item) => Appointment.fromMap(item)).toList();
    _getEvents();

    setState(() {});
  }

  Future addApp(BuildContext mainContext, Appointment appt) async {
    String _title = appt.title != null ? appt.title : '';
    String _description = appt.description != null ? appt.description : '';
    if (appt.apptDate != null) {
      List<String> date = appt.apptDate.split('.');
      List<String> time = appt.apptTime.split(':');
      _currentDate = new DateTime(
          int.parse(date[2]),
          int.parse(date[1]),
          int.parse(date[0]),
          int.parse(time[0]),
          int.parse(time[1]),
          int.parse(time[2]));
    }

    DateTime _date = _currentDate;

    final TextEditingController _titleEditingController =
        TextEditingController(text: _title);
    final TextEditingController _descriptionEditingController =
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
                        String label = appt.id == null
                            ? 'Appointment saved'
                            : 'Appointment updated!';
                        Color color =
                            appt.id == null ? Colors.green : Colors.indigo[900];

                        // ignore: deprecated_member_use
                        Scaffold.of(mainContext).showSnackBar(SnackBar(
                            backgroundColor: color,
                            duration: Duration(seconds: 2),
                            content: Text(label)));

                        _currentDate =
                            new DateTime(_date.year, _date.month, _date.day);

                        appt.title = _title;
                        appt.description = _description;
                        appt.apptDate =
                            DateFormat('dd.MM.yyyy').format(_currentDate);
                        appt.apptTime = _currTime();
                        if (appt.id == null) {
                          List<Map<String, dynamic>> _results =
                              await DB.getLast('Appointments');
                          appt.id = _results
                              .map((item) => Appointment.fromMap(item))
                              .toList()[0]
                              .id;
                          DB.insert(appt, 'Appointments');
                          refresh();
                        } else {
                          await DB.update(appt, 'Appointments');
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
                        maxLines: 6,
                        decoration: InputDecoration(hintText: "Description"),
                        controller: _descriptionEditingController,
                        validator: (String inValue) {
                          if (inValue.length == 0) {
                            return "Please enter a description";
                          }
                          _description = inValue;
                          return null;
                        }),
                  ),
                  ListTile(
                    leading: Icon(Icons.timelapse),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(child: Text(_currTime())),
                        InkWell(
                          child: Center(child: Icon(Icons.edit)),
                          onTap: () async {
                            await _selectTime(context);
                          },
                        ),
                      ],
                    ),
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
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: _currentTime);
    if (picked != null) {
      setState(() {
        _currentTime = picked;
      });
    }
  }

  Future deleteApp(BuildContext contextMain, Appointment appt) async {
    return showDialog(
        context: contextMain,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Delete task'),
            content: Text('Are you sure you want to delete ${appt.title}'),
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
                  await DB.delete(appt, 'Appointments');

                  Navigator.of(context).pop();

                  // ignore: deprecated_member_use
                  Scaffold.of(contextMain).showSnackBar(SnackBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                      content: Text("Appointment deleted")));
                  refresh();
                },
              ),
            ],
          );
        });
  }

  static Widget _eventIcon = new Container(
    decoration: new BoxDecoration(
        color: Color(0xffded1d2),
        borderRadius: BorderRadius.all(Radius.circular(1000)),
        border: Border.all(color: Color(0xff3b0011), width: 2.0)),
    child: new Icon(
      Icons.person,
      color: Color(0xff3b0011),
    ),
  );

  Future<void> _showEvents(BuildContext mainContext) async {
    List<Appointment> appOnDate = [];
    for (int i = 0; i < appointments.length; i++) {
      if (appointments[i].apptDate ==
          DateFormat('dd.MM.yyyy').format(_currentDate)) {
        appOnDate.add(appointments[i]);
      }
    }
    if (appOnDate.length == 0) {
      return showDialog<void>(
        context: mainContext,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title:
                Text('Date: ${DateFormat('dd.MM.yyyy').format(_currentDate)}'),
            content: SingleChildScrollView(
                child: Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text("You haven't any appointments today"),
            )),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    return showCupertinoModalBottomSheet(
        context: mainContext,
        builder: (BuildContext context) {
          return _marketList(appOnDate);
        });
  }

  void _getEvents() {
    Map<DateTime, List<Event>> map = new Map<DateTime, List<Event>>();
    for (int i = 0; i < appointments.length; i++) {
      List<String> p = appointments[i].apptDate.split('.');
      DateTime apptDay =
          new DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
      Event event = new Event(
          date: apptDay, title: appointments[i].title, icon: _eventIcon);
      if (map.containsKey(apptDay)) {
        map[apptDay].add(event);
      } else {
        List<Event> e = [event];
        Map<DateTime, List<Event>> m = {apptDay: e};
        map.addAll(m);
      }
    }
    _markedDateMap = new EventList(events: map);
  }

  Widget _caledarCalousel() {
    var calendarCarousel;
    if (appointments.length != 0) {
      calendarCarousel = CalendarCarousel<Event>(
        iconColor: Color(0xff3b0011),
        onDayLongPressed: (DateTime date) {
          this.setState(() => _currentDate = date);
          refresh();
          _showEvents(context);
        },
        onDayPressed: (DateTime date, List<Event> e) {
          this.setState(() => _currentDate = date);
          refresh();
        },
        weekendTextStyle: TextStyle(
          color: Colors.red,
        ),
        thisMonthDayBorderColor: Colors.grey,
        weekFormat: false,
        height: 450.0,
        selectedDateTime: _currentDate,
        markedDatesMap: _markedDateMap, //ADDED!
      );
    } else {
      calendarCarousel = CalendarCarousel<Event>(
        iconColor: Color(0xff3b0011),
        onDayLongPressed: (DateTime date) {
          this.setState(() => _currentDate = date);
          _showEvents(context);
          refresh();
        },
        onDayPressed: (DateTime date, List<Event> e) {
          this.setState(() => _currentDate = date);
          refresh();
        },
        weekendTextStyle: TextStyle(
          color: Colors.red,
        ),
        thisMonthDayBorderColor: Colors.grey,
        weekFormat: false,
        height: 450.0,
        selectedDateTime: _currentDate,
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: calendarCarousel,
    );
  }

  Widget _marketList(List<Appointment> appOnDate) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Date: ${DateFormat('dd.MM.yyyy').format(_currentDate)}'),
        backgroundColor: Color(0xff3b0011),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: ListView.builder(
          itemCount: appOnDate.length,
          itemBuilder: (BuildContext context, int index) {
            Appointment appt = appOnDate[index];
            return CupertinoContextMenu(
              child: Card(
                elevation: 8,
                color: Color(0xffded1d2),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Wrap(
                            children: [
                              Text('Title: ${appt.title}'),
                              Text('Description: ${appt.description}'),
                              Text('Time: ${appt.apptTime}'),
                            ],
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.edit, color: Color(0xff3b0011))
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
                    await addApp(context, appt);
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
                    await deleteApp(context, appt);
                    setState(() {});
                    refresh();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          child: _caledarCalousel(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff3b0011),
          child: Icon(Icons.add),
          tooltip: 'Add new appointment',
          onPressed: () async {
            await addApp(context, new Appointment());
            refresh();
          },
        ),);
  }
}
