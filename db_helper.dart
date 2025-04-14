import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('grades.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE grades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_name TEXT,
        father_name TEXT,
        department_name TEXT,
        shift TEXT,
        rollno TEXT,
        course_code TEXT,
        course_title TEXT,
        credit_hours TEXT,
        obtained_marks TEXT,
        semester TEXT,
        consider_status TEXT
      )
    ''');
  }

  Future<int> insertData(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('grades', data);
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    final db = await instance.database;
    return await db.query('grades');
  }

  Future<int> deleteRow(int id) async {
    final db = await instance.database;
    return await db.delete('grades', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> resetDatabase() async {
    final db = await instance.database;
    await db.execute('DROP TABLE IF EXISTS grades');
    await _createDB(db, 1);
    return 0;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}