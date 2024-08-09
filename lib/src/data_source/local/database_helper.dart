import 'package:icorrect_pc/src/models/homework_models/syllabusDB_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const int _version = 1;
  static const String _dbName = 'syllabus1.db';
  static const String _tableSyllabus = 'Syllabus';

  //status = 0: chưa download
  //status = 1: đã download
  static Future<Database> _getDB() async {
    final folder = await getApplicationSupportDirectory();
    String folderPath = folder.path;
    return openDatabase(join(folderPath, _dbName),
        onCreate: (db, version) async {
          await db.execute(
              '''CREATE TABLE $_tableSyllabus (
         syllabusID INTEGER NOT NULL PRIMARY KEY,
         syllabusName TEXT NOT NULL,
         totalDownloaded INTEGER,
         capacity REAL,
         statusDownload INTEGER NOT NULL,
         updateAt TEXT NOT NULL,
         downloadAt TEXT
         );'''
          );
        }, version: _version
    );
  }

  static Future<int> addSyllabus(SyllabusDBModel syllabus) async {
    final db = await _getDB();
    return db.insert(_tableSyllabus, syllabus.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> deleteSyllabus(String syllabusName) async {
    final db =await _getDB();
    return db.delete(_tableSyllabus, where: 'syllabusName = ?', whereArgs: [syllabusName]);
  }

  static Future<int> updateSyllabus(SyllabusDBModel syllabus) async {
    final db = await _getDB();
    Map<String, dynamic> data = {
      'totalDownloaded': syllabus.totalDownloaded,
      'capacity': syllabus.capacity,
      'statusDownload': syllabus.statusDownload,
      'downloadAt': syllabus.downloadAt?.toIso8601String()
    };
    return db.update(_tableSyllabus, data, where: 'syllabusName = ?', whereArgs: [syllabus.syllabusName], conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateCapacitySyllabus(double capacity, String syllabusName) async {
    final db = await _getDB();
    Map<String, dynamic> data = {
      'capacity': capacity
    };
    return db.update(_tableSyllabus, data, where: 'syllabusName = ?', whereArgs: [syllabusName], conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateDownloadAtSyllabus(String downloadAt, String syllabusName) async {
    final db = await _getDB();
    Map<String, dynamic> data = {
      'downloadAt': downloadAt
    };
    return db.update(_tableSyllabus, data, where: 'syllabusName = ?', whereArgs: [syllabusName], conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateUpdateAtSyllabus(String updateAt, String syllabusName) async {
    final db = await _getDB();
    Map<String, dynamic> data = {
      'updateAt': updateAt
    };
    return db.update(_tableSyllabus, data, where: 'syllabusName = ?', whereArgs: [syllabusName], conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateTotalDownloadedSyllabus(int totalDownloaded, String syllabusName) async {
    final db = await _getDB();
    Map<String, dynamic> data = {
      'totalDownloaded': totalDownloaded
    };
    return db.update(_tableSyllabus, data, where: 'syllabusName = ?', whereArgs: [syllabusName], conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateStatusDownloadSyllabus(int statusDownload, String syllabusName) async {
    final db = await _getDB();
    Map<String, dynamic> data = {
      'statusDownload': statusDownload
    };
    return db.update(_tableSyllabus, data, where: 'syllabusName = ?', whereArgs: [syllabusName], conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<SyllabusDBModel>?> getListSyllabus() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query(_tableSyllabus);
    if (maps.isEmpty) {
      return null;
    }
    return List.generate(maps.length, (index) => SyllabusDBModel.fromJson(maps[index]));
  }
}