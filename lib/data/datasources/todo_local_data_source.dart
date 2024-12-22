import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TodoLocalDataSource {
  static final TodoLocalDataSource instance = TodoLocalDataSource._init();
  static Database? _database;

  TodoLocalDataSource._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    const todoTable = '''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL
      )
    ''';

    await db.execute(todoTable);
  }

  Future<List<Map<String, dynamic>>> getTodos() async {
    final db = await instance.database;
    return db.query('todos');
  }

  Future<int> insertTodo(Map<String, dynamic> todo) async {
    final db = await instance.database;
    return db.insert('todos', todo);
  }

  Future<int> updateTodo(Map<String, dynamic> todo, int id) async {
    final db = await instance.database;
    return db.update('todos', todo, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTodo(int id) async {
    final db = await instance.database;
    return db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}
