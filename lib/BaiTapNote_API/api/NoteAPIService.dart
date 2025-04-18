import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';

class NoteAPIService {
  static final NoteAPIService instance = NoteAPIService._init();
  final String baseUrl = 'https://my-json-server.typicode.com/Sangpham26/testflutter/'; // thay bằng URL thật

  NoteAPIService._init();

  // Thêm ghi chú mới
  Future<Note> createNote(Note note) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(note.toMap()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Note.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create note: ${response.statusCode}');
    }
  }

  // Lấy tất cả ghi chú
  Future<List<Note>> getAllNotes() async {
    final response = await http.get(Uri.parse('$baseUrl/notes'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Note.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load notes: ${response.statusCode}');
    }
  }

  // Lấy ghi chú theo ID
  Future<Note?> getNoteById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/notes/$id'));

    if (response.statusCode == 200) {
      return Note.fromMap(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to get note: ${response.statusCode}');
    }
  }

  // Cập nhật toàn bộ ghi chú
  Future<Note> updateNote(Note note) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notes/${note.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(note.toMap()),
    );

    if (response.statusCode == 200) {
      return Note.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update note: ${response.statusCode}');
    }
  }

  // Xoá ghi chú
  Future<bool> deleteNote(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/notes/$id'));

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Failed to delete note: ${response.statusCode}');
    }
  }

  // Tìm ghi chú theo độ ưu tiên
  Future<List<Note>> getNotesByPriority(int priority) async {
    final notes = await getAllNotes();
    return notes.where((note) => note.priority == priority).toList();
  }

  // Tìm kiếm ghi chú theo từ khóa
  Future<List<Note>> searchNotes(String query) async {
    final notes = await getAllNotes();
    return notes.where((note) =>
    note.title.toLowerCase().contains(query.toLowerCase()) ||
        note.content.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
