import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import '../models/note.dart';

class NoteDatabaseHelper {
  static NoteDatabaseHelper? _instance; // Biến instance có thể thay đổi
  static Database? _database;
  static String? _currentUserId; // Lưu UID của người dùng hiện tại

  // Constructor riêng tư
  NoteDatabaseHelper._init();

  // Factory constructor để quản lý instance dựa trên người dùng
  static NoteDatabaseHelper get instance {
    // Phải được gọi sau khi người dùng đăng nhập và initializeForUser đã được gọi
    if (_instance == null) {
      throw Exception(
        "NoteDatabaseHelper not initialized. Call initializeForUser first.",
      );
    }
    return _instance!;
  }

  // Hàm khởi tạo helper cho một người dùng cụ thể
  static Future<void> initializeForUser(String userId) async {
    if (_database != null && _currentUserId == userId) {
      return;
    }

    // Nếu đang mở database của người dùng khác, đóng nó lại
    if (_database != null && _currentUserId != userId) {
      await closeDatabase();
    }

    _currentUserId = userId;
    _instance = NoteDatabaseHelper._init(); // Tạo instance mới (nếu cần)
    // Khởi tạo database cho người dùng mới
    _database = await _instance!._initDB('notes_$_currentUserId.db');
    print("Database initialized for user: $_currentUserId");
  }

  // Hàm đóng database khi người dùng đăng xuất
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _currentUserId = null;
      _instance = null; // Xóa instance
      print("Database closed.");
    }
  }

  // Getter để truy cập database
  Future<Database> get _db async {
    if (_database == null) {
      throw Exception("Database is not initialized for the current user.");
    }
    return _database!;
  }

  // Hàm khởi tạo database với tên file cụ thể
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    print("Database path: $path"); // In đường dẫn để debug

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Hàm tạo bảng
  Future _createDB(Database db, int version) async {
    const noteTable = '''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        priority INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        modifiedAt TEXT NOT NULL,
        tags TEXT,
        color TEXT
      )
      ''';
    await db.execute(noteTable);
    print("Table 'notes' created.");
  }

  // Các hàm CRUD (insert, getAll, getById, update, delete, search, getByPriority)
  Future<int> insertNote(Note note) async {
    final dbClient = await _db; // Sử dụng getter _db
    return await dbClient.insert('notes', note.toMap());
  }

  Future<List<Note>> getAllNotes() async {
    final dbClient = await _db;
    final result = await dbClient.query(
      'notes',
      orderBy: 'modifiedAt DESC',
    ); // Sắp xếp theo ngày sửa đổi gần nhất
    return result.map((map) => Note.fromMap(map)).toList();
  }

  Future<Note?> getNoteById(int id) async {
    final dbClient = await _db;
    final result = await dbClient.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? Note.fromMap(result.first) : null;
  }

  Future<int> updateNote(Note note) async {
    final dbClient = await _db;
    return await dbClient.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final dbClient = await _db;
    return await dbClient.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Note>> getNotesByPriority(int priority) async {
    final dbClient = await _db;
    final result = await dbClient.query(
      'notes',
      where: 'priority = ?',
      whereArgs: [priority],
      orderBy: 'modifiedAt DESC',
    );
    return result.map((map) => Note.fromMap(map)).toList();
  }

  Future<List<Note>> searchNotes(String query) async {
    final dbClient = await _db;
    final result = await dbClient.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'modifiedAt DESC',
    );
    return result.map((map) => Note.fromMap(map)).toList();
  }
}
