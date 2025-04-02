import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'dart:io';
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();

  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    // Get the database path
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, "dedida.db");
    // If database needs to be changed, include this command to delete local copy
    //await deleteDatabase(dbPath);

    // Check if the database exists
    bool exists = await databaseExists(dbPath);

    if (!exists) {
      // Copy from assets
      ByteData data = await rootBundle.load("assets/dedida.db");
      List<int> bytes = data.buffer.asUint8List();
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    // Open the database
    _database = await openDatabase(dbPath);
    return _database!;
  }
}
