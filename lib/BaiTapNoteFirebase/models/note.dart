// Lớp Note đại diện cho một ghi chú trong ứng dụng.
class Note {
  // ID duy nhất của ghi chú. Giá trị này khớp với ID của document trong Firestore.
  // Đặt kiểu dữ liệu là String để tương thích với ID của document Firestore.
  final String? id;
  // Tiêu đề của ghi chú.
  final String title;
  // Nội dung của ghi chú.
  final String content;
  // Mức độ ưu tiên của ghi chú (1: Thấp, 2: Trung bình, 3: Cao).
  final int priority;
  // Thời gian tạo ghi chú.
  final DateTime createdAt;
  // Thời gian sửa đổi cuối cùng của ghi chú.
  final DateTime modifiedAt;
  // Danh sách các tags (nhãn) liên quan đến ghi chú.
  final List<String>? tags;
  // Mã màu nền của ghi chú (dạng hex string, ví dụ: #FFFFFF).
  final String? color;

  // Constructor chính để tạo một đối tượng Note.
  Note({
    this.id, // ID có thể null khi tạo một ghi chú mới (Firestore sẽ tự tạo ID).
    required this.title, // Tiêu đề là bắt buộc.
    required this.content, // Nội dung là bắt buộc.
    required this.priority, // Mức độ ưu tiên là bắt buộc.
    required this.createdAt, // Thời gian tạo là bắt buộc.
    required this.modifiedAt, // Thời gian sửa đổi là bắt buộc.
    this.tags, // Tags là tùy chọn (có thể null).
    this.color, // Màu sắc là tùy chọn (có thể null).
  });

  // Constructor để tạo một đối tượng Note từ một Map (thường là dữ liệu lấy từ Firestore).
  Note.fromMap(Map<String, dynamic> map)
      : id = map['id'], // Lấy ID.
        title = map['title'], // Lấy tiêu đề.
        content = map['content'], // Lấy nội dung.
        priority = map['priority'], // Lấy độ ưu tiên.
  // Chuyển đổi chuỗi ISO 8601 thành DateTime.
        createdAt = DateTime.parse(map['createdAt']),
        modifiedAt = DateTime.parse(map['modifiedAt']),
  // Lấy danh sách tags. Nếu map['tags'] không null, chuyển đổi nó thành List<String>.
  // Nếu null, gán giá trị null cho tags.
        tags = map['tags'] != null
            ? List<String>.from(map['tags'])
            : null,
        color = map['color']; // Lấy màu sắc.

  // Chuyển đổi một đối tượng Note thành một Map (thường dùng để lưu vào Firestore).
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Gán ID (không lưu trữ ID trong Firestore, để Firestore tự quản lý ID)
      'title': title, // Gán tiêu đề.
      'content': content, // Gán nội dung.
      'priority': priority, // Gán độ ưu tiên.
      // Chuyển đổi DateTime thành chuỗi ISO 8601 để lưu.
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'tags': tags, // Gán danh sách tags.
      'color': color, // Gán màu sắc.
    };
  }

  // Phương thức copyWith cho phép tạo một bản sao của đối tượng Note,
  // với một số trường được thay đổi. Điều này hữu ích khi cập nhật một đối tượng.
  Note copyWith({
    String? id, // ID (có thể thay đổi)
    String? title, // Tiêu đề (có thể thay đổi)
    String? content, // Nội dung (có thể thay đổi)
    int? priority, // Độ ưu tiên (có thể thay đổi)
    DateTime? createdAt, // Thời gian tạo (có thể thay đổi)
    DateTime? modifiedAt, // Thời gian sửa đổi (có thể thay đổi)
    List<String>? tags, // Tags (có thể thay đổi)
    String? color, // Màu sắc (có thể thay đổi)
  }) {
    return Note(
      id: id ?? this.id, // Nếu id được cung cấp, dùng giá trị đó, nếu không, dùng giá trị hiện tại.
      title: title ?? this.title, // Tương tự cho các trường khác.
      content: content ?? this.content,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      tags: tags ?? this.tags,
      color: color ?? this.color,
    );
  }

  // Phương thức toString() để in thông tin của đối tượng Note ra console (cho mục đích debug).
  @override
  String toString() {
    return 'Note{id: $id, title: $title, content: $content, priority: $priority, '
        'createdAt: $createdAt, modifiedAt: $modifiedAt, tags: $tags, color: $color}';
  }
}