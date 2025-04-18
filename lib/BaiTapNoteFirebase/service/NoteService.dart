import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note.dart';

class NoteService {
  static final NoteService instance = NoteService._init();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  NoteService._init();

  // Thêm ghi chú mới
  Future<Note> createNote(Note note) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final noteMap = note.toMap();
    noteMap['uid'] = user.uid; // Liên kết ghi chú với người dùng

    final docRef = await _firestore.collection('notes').add(noteMap);
    final docSnapshot = await docRef.get();
    return Note.fromMap({
      ...docSnapshot.data()!,
      'id': docRef.id,
    });
  }

  // Lấy tất cả ghi chú của người dùng
  Future<List<Note>> getAllNotes() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final querySnapshot = await _firestore
        .collection('notes')
        .where('uid', isEqualTo: user.uid)
        .get();

    return querySnapshot.docs.map((doc) {
      return Note.fromMap({
        ...doc.data(),
        'id': doc.id,
      });
    }).toList();
  }

  // Lấy ghi chú theo ID
  Future<Note?> getNoteById(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final docSnapshot = await _firestore.collection('notes').doc(id).get();
    if (!docSnapshot.exists) return null;

    final data = docSnapshot.data()!;
    if (data['uid'] != user.uid) return null; // Chỉ trả về ghi chú của người dùng

    return Note.fromMap({
      ...data,
      'id': docSnapshot.id,
    });
  }

  // Cập nhật ghi chú
  Future<Note> updateNote(Note note) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final noteMap = note.toMap();
    noteMap['uid'] = user.uid;

    await _firestore.collection('notes').doc(note.id).set(noteMap);
    final docSnapshot = await _firestore.collection('notes').doc(note.id).get();
    return Note.fromMap({
      ...docSnapshot.data()!,
      'id': docSnapshot.id,
    });
  }

  // Xóa ghi chú
  Future<bool> deleteNote(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final docSnapshot = await _firestore.collection('notes').doc(id).get();
    if (!docSnapshot.exists || docSnapshot.data()!['uid'] != user.uid) {
      return false;
    }

    await _firestore.collection('notes').doc(id).delete();
    return true;
  }

  // Tìm ghi chú theo độ ưu tiên
  Future<List<Note>> getNotesByPriority(int priority) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final querySnapshot = await _firestore
        .collection('notes')
        .where('uid', isEqualTo: user.uid)
        .where('priority', isEqualTo: priority)
        .get();

    return querySnapshot.docs.map((doc) {
      return Note.fromMap({
        ...doc.data(),
        'id': doc.id,
      });
    }).toList();
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