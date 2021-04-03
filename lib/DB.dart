import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutterbook/Model.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';

abstract class DB {
  static Database _db;

  static Future<void> init() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "notebook.db");

// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "notebook.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    }
// open the database
    _db = await openDatabase(path);
  }

  static Future<int> insert(Model model, String name) async =>
      _db.insert(name, model.toMap());

  static Future<int> update(Model model, String name) async =>
      _db.update(name, model.toMap(), where: 'id=?', whereArgs: [model.id]);

  static Future<int> delete(Model model, String name) async =>
      _db.delete(name, where: 'id=?', whereArgs: [model.id]);

  static Future<List<Map<String, dynamic>>> query(String name) async =>
      _db.query(name);

  static Future<List<Map<String, dynamic>>> getLast(String name) async =>
      _db.rawQuery('SELECT MAX(id)+1 FROM $name');
}
