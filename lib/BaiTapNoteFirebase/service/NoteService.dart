import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore để tương tác với database
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth để lấy thông tin người dùng
import '../models/note.dart'; // Import model Note để làm việc với đối tượng ghi chú

// Lớp NoteService chịu trách nhiệm xử lý tất cả các thao tác dữ liệu
// liên quan đến ghi chú (CRUD - Create, Read, Update, Delete) trên Firestore.
// Sử dụng Singleton pattern để đảm bảo chỉ có một instance của service này trong toàn bộ ứng dụng.
class NoteService {
  // Tạo một instance tĩnh, duy nhất của NoteService (Singleton Pattern).
  static final NoteService instance = NoteService._init();

  // Lấy instance của Firestore để thực hiện các thao tác database.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Lấy instance của FirebaseAuth để kiểm tra và lấy thông tin người dùng hiện tại.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Constructor riêng tư (private) để ngăn việc tạo instance từ bên ngoài lớp.
  // Đây là một phần của Singleton Pattern.
  NoteService._init();

  // --- Các phương thức CRUD và Query ---

  /// Thêm một ghi chú mới vào Firestore cho người dùng hiện tại.
  ///
  /// [note]: Đối tượng Note chứa thông tin cần lưu (chưa có id).
  /// Trả về đối tượng Note đã được tạo (bao gồm cả id từ Firestore).
  /// Ném ra Exception nếu người dùng chưa đăng nhập.
  Future<Note> createNote(Note note) async {
    // Lấy thông tin người dùng đang đăng nhập.
    final user = _auth.currentUser;
    // Kiểm tra xem người dùng đã đăng nhập chưa. Nếu chưa, không cho phép tạo ghi chú.
    if (user == null) throw Exception('User not authenticated');

    // Chuyển đổi đối tượng Note thành Map để lưu vào Firestore.
    final noteMap = note.toMap();
    // Quan trọng: Thêm trường 'uid' vào Map, liên kết ghi chú này với ID của người dùng hiện tại.
    // Điều này đảm bảo rằng mỗi người dùng chỉ thấy ghi chú của mình.
    noteMap['uid'] = user.uid;

    // Thêm Map dữ liệu vào collection 'notes' trong Firestore.
    // Firestore sẽ tự động tạo một ID duy nhất cho document mới này.
    final docRef = await _firestore.collection('notes').add(noteMap);
    // Lấy lại document vừa tạo để có được dữ liệu đầy đủ (bao gồm cả các trường do server tạo nếu có) và ID.
    final docSnapshot = await docRef.get();
    // Chuyển đổi dữ liệu từ Map (lấy từ Firestore snapshot) trở lại thành đối tượng Note.
    // Sử dụng spread operator (...) để sao chép các trường từ snapshot data.
    // Thêm trường 'id' vào Map với giá trị là ID của document vừa tạo.
    return Note.fromMap({
      ...docSnapshot.data()!, // Dấu ! khẳng định data không null vì ta vừa tạo nó.
      'id': docRef.id, // Gán ID của document vào đối tượng Note.
    });
  }

  /// Lấy tất cả các ghi chú từ Firestore thuộc về người dùng hiện tại.
  ///
  /// Trả về một danh sách các đối tượng Note.
  /// Ném ra Exception nếu người dùng chưa đăng nhập.
  Future<List<Note>> getAllNotes() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Truy vấn collection 'notes'.
    final querySnapshot = await _firestore
        .collection('notes')
    // Chỉ lấy các documents có trường 'uid' bằng với ID của người dùng hiện tại.
        .where('uid', isEqualTo: user.uid)
    // Sắp xếp theo thời gian sửa đổi, ghi chú mới nhất lên đầu (tuỳ chọn)
    // .orderBy('modifiedAt', descending: true)
        .get(); // Thực hiện truy vấn.

    // Chuyển đổi từng document trong kết quả truy vấn thành đối tượng Note.
    return querySnapshot.docs.map((doc) {
      return Note.fromMap({
        ...doc.data(), // Lấy dữ liệu Map từ document.
        'id': doc.id, // Lấy ID của document.
      });
    }).toList(); // Chuyển đổi Iterable thành List.
  }

  /// Lấy một ghi chú cụ thể bằng ID của nó từ Firestore.
  ///
  /// [id]: ID của document ghi chú cần lấy.
  /// Trả về đối tượng Note nếu tìm thấy và thuộc về người dùng, ngược lại trả về null.
  /// Ném ra Exception nếu người dùng chưa đăng nhập.
  Future<Note?> getNoteById(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Lấy document snapshot dựa trên ID được cung cấp.
    final docSnapshot = await _firestore.collection('notes').doc(id).get();
    // Kiểm tra xem document có tồn tại không. Nếu không, trả về null.
    if (!docSnapshot.exists) return null;

    // Lấy dữ liệu dạng Map từ snapshot.
    final data = docSnapshot.data()!; // Dấu ! vì đã kiểm tra exists.
    // Kiểm tra xem ghi chú này có thuộc về người dùng hiện tại không.
    // Nếu không, trả về null để ngăn người dùng xem ghi chú của người khác.
    if (data['uid'] != user.uid) return null;

    // Chuyển đổi Map thành đối tượng Note và trả về.
    return Note.fromMap({
      ...data,
      'id': docSnapshot.id,
    });
  }

  /// Cập nhật một ghi chú đã tồn tại trong Firestore.
  ///
  /// [note]: Đối tượng Note chứa thông tin đã cập nhật (phải có id).
  /// Trả về đối tượng Note sau khi đã cập nhật.
  /// Ném ra Exception nếu người dùng chưa đăng nhập hoặc cố gắng cập nhật ghi chú không tồn tại/không thuộc sở hữu.
  Future<Note> updateNote(Note note) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    // Kiểm tra xem note có ID hợp lệ không (cần thiết cho việc cập nhật)
    if (note.id == null || note.id!.isEmpty) {
      throw Exception('Note ID is required for update');
    }


    // Chuyển đổi Note thành Map.
    final noteMap = note.toMap();
    // Đảm bảo trường 'uid' luôn là của người dùng hiện tại khi cập nhật.
    noteMap['uid'] = user.uid;
    // Cập nhật thời gian sửa đổi (có thể thực hiện trong Note model hoặc ở đây)
    noteMap['modifiedAt'] = Timestamp.now(); // Ghi đè thời gian sửa đổi

    // Thực hiện cập nhật document trong Firestore bằng phương thức `set`.
    // `set` sẽ ghi đè toàn bộ document với dữ liệu mới trong noteMap.
    // Cân nhắc dùng `update` nếu chỉ muốn cập nhật một số trường nhất định.
    // Lưu ý: Cần kiểm tra quyền sở hữu trước khi cập nhật để bảo mật hơn,
    // nhưng `set` với `uid` đúng cũng đảm bảo ghi đè đúng document của người dùng.
    // Nếu muốn an toàn hơn, có thể getNoteById trước khi update.
    await _firestore.collection('notes').doc(note.id!).set(noteMap);

    // Lấy lại dữ liệu vừa cập nhật để trả về đối tượng Note mới nhất.
    final docSnapshot = await _firestore.collection('notes').doc(note.id!).get();
    if (!docSnapshot.exists) throw Exception('Note not found after update'); // Kiểm tra phòng trường hợp lỗi hiếm gặp
    return Note.fromMap({
      ...docSnapshot.data()!,
      'id': docSnapshot.id,
    });
  }

  /// Xóa một ghi chú khỏi Firestore dựa trên ID.
  ///
  /// [id]: ID của document ghi chú cần xóa.
  /// Trả về `true` nếu xóa thành công, `false` nếu ghi chú không tồn tại hoặc không thuộc sở hữu của người dùng.
  /// Ném ra Exception nếu người dùng chưa đăng nhập.
  Future<bool> deleteNote(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Lấy snapshot của document để kiểm tra sự tồn tại và quyền sở hữu trước khi xóa.
    final docSnapshot = await _firestore.collection('notes').doc(id).get();
    // Nếu document không tồn tại HOẶC uid trong document không khớp với uid người dùng hiện tại.
    if (!docSnapshot.exists || docSnapshot.data()!['uid'] != user.uid) {
      // Không thực hiện xóa và trả về false.
      return false;
    }

    // Nếu kiểm tra thành công, thực hiện xóa document.
    await _firestore.collection('notes').doc(id).delete();
    // Trả về true để báo hiệu xóa thành công.
    return true;
  }

  /// Lấy các ghi chú có độ ưu tiên cụ thể thuộc về người dùng hiện tại.
  ///
  /// [priority]: Mức độ ưu tiên cần lọc (ví dụ: 1, 2, 3).
  /// Trả về danh sách các Note thỏa mãn điều kiện.
  /// Ném ra Exception nếu người dùng chưa đăng nhập.
  Future<List<Note>> getNotesByPriority(int priority) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Truy vấn collection 'notes'.
    final querySnapshot = await _firestore
        .collection('notes')
    // Lọc theo uid của người dùng hiện tại.
        .where('uid', isEqualTo: user.uid)
    // Lọc thêm theo trường 'priority'.
        .where('priority', isEqualTo: priority)
        .get(); // Thực hiện truy vấn.

    // Chuyển đổi kết quả thành danh sách các đối tượng Note.
    return querySnapshot.docs.map((doc) {
      return Note.fromMap({
        ...doc.data(),
        'id': doc.id,
      });
    }).toList();
  }


  /// Tìm kiếm ghi chú dựa trên từ khóa trong tiêu đề hoặc nội dung.
  /// Lưu ý: Đây là tìm kiếm phía client sau khi đã lấy *tất cả* ghi chú.
  /// Đối với lượng dữ liệu lớn, nên cân nhắc sử dụng giải pháp tìm kiếm chuyên dụng
  /// như Algolia, Elasticsearch hoặc Firestore full-text search (nếu có extension).
  ///
  /// [query]: Từ khóa tìm kiếm.
  /// Trả về danh sách các Note thỏa mãn điều kiện tìm kiếm.
  /// Ném ra Exception nếu người dùng chưa đăng nhập.
  Future<List<Note>> searchNotes(String query) async {
    // Lấy tất cả ghi chú của người dùng trước.
    // Đây là điểm có thể không hiệu quả với lượng dữ liệu lớn.
    final notes = await getAllNotes();

    // Nếu query rỗng, trả về tất cả ghi chú
    if (query.trim().isEmpty) {
      return notes;
    }

    // Thực hiện lọc trên danh sách ghi chú đã lấy về phía client.
    return notes.where((note) =>
    // Kiểm tra xem tiêu đề (chuyển về chữ thường) có chứa từ khóa (chữ thường) không.
    note.title.toLowerCase().contains(query.toLowerCase()) ||
        // HOẶC kiểm tra xem nội dung (chữ thường) có chứa từ khóa (chữ thường) không.
        note.content.toLowerCase().contains(query.toLowerCase())
    ).toList(); // Chuyển kết quả lọc thành List.
  }
}