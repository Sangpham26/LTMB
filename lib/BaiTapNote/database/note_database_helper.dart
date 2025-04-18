import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

// Lớp helper để quản lý tương tác với database SQLite
class NoteDatabaseHelper {
  // Singleton pattern - chỉ cho phép 1 instance duy nhất
  static final NoteDatabaseHelper instance = NoteDatabaseHelper._init();
  static Database? _database; // Biến lưu trữ database instance

  // Constructor riêng tư để đảm bảo singleton
  NoteDatabaseHelper._init();

  // Getter để truy cập database (khởi tạo nếu chưa có)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db'); // Tạo database nếu chưa tồn tại
    return _database!;
  }

  // Hàm khởi tạo database
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath(); // Lấy đường dẫn thư mục database
    final path = join(dbPath, fileName); // Tạo full path đến file database

    // Mở hoặc tạo database
    return await openDatabase(
      path,
      version: 1, // Phiên bản database
      onCreate: _createDB, // Hàm callback khi tạo database mới
    );
  }

  // Hàm tạo bảng notes khi database được tạo lần đầu
  Future _createDB(Database db, int version) async {
    const noteTable = '''
    CREATE TABLE notes (
      id INTEGER PRIMARY KEY AUTOINCREMENT, // Khóa chính tự tăng
      title TEXT NOT NULL,                 // Tiêu đề ghi chú (bắt buộc)
      content TEXT NOT NULL,               // Nội dung ghi chú (bắt buộc)
      priority INTEGER NOT NULL,           // Độ ưu tiên (1-3)
      createdAt TEXT NOT NULL,             // Ngày tạo (dạng string)
      modifiedAt TEXT NOT NULL,            // Ngày sửa (dạng string)
      tags TEXT,                          // Danh sách tags (JSON string)
      color TEXT                           // Mã màu (hex string)
    )
    ''';
    await db.execute(noteTable); // Thực thi câu lệnh SQL
  }

  // Thêm một note mới vào database
  Future<int> insertNote(Note note) async {
    final db = await instance.database;
    // Chuyển đổi note thành map và insert vào bảng notes
    return await db.insert('notes', note.toMap());
  }

  // Lấy tất cả notes từ database
  Future<List<Note>> getAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes'); // Query tất cả bản ghi
    // Chuyển đổi từ map sang đối tượng Note
    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Lấy note theo ID
  Future<Note?> getNoteById(int id) async {
    final db = await instance.database;
    // Query với điều kiện WHERE id = ?
    final result = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id], // Thay thế ? bằng giá trị id
    );
    // Trả về null nếu không tìm thấy
    return result.isNotEmpty ? Note.fromMap(result.first) : null;
  }

  // Cập nhật note
  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    // Cập nhật bản ghi có id trùng với note.id
    return await db.update(
      'notes',
      note.toMap(), // Dữ liệu mới
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Xóa note
  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    // Xóa bản ghi có id trùng với id truyền vào
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Lấy danh sách note theo độ ưu tiên
  Future<List<Note>> getNotesByPriority(int priority) async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'priority = ?',
      whereArgs: [priority],
    );
    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Tìm kiếm note theo từ khóa trong tiêu đề hoặc nội dung
  Future<List<Note>> searchNotes(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?', // Tìm kiếm trong cả tiêu đề và nội dung
      whereArgs: ['%$query%', '%$query%'], // Sử dụng % để tìm kiếm phần chứa
    );
    return result.map((map) => Note.fromMap(map)).toList();
  }
}