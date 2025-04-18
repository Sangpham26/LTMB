// Lớp Note đại diện cho một ghi chú trong ứng dụng
class Note {
  // Các thuộc tính của ghi chú
  final int? id;               // ID (nullable vì có thể chưa có khi tạo mới)
  final String title;          // Tiêu đề ghi chú (bắt buộc)
  final String content;        // Nội dung ghi chú (bắt buộc)
  final int priority;          // Độ ưu tiên (1-3, bắt buộc)
  final DateTime createdAt;    // Thời gian tạo (bắt buộc)
  final DateTime modifiedAt;   // Thời gian chỉnh sửa (bắt buộc)
  final List<String>? tags;    // Danh sách tags (có thể null)
  final String? color;         // Mã màu (có thể null)

  // Constructor chính
  Note({
    this.id,
    required this.title,      // required đảm bảo phải cung cấp giá trị
    required this.content,
    required this.priority,
    required this.createdAt,
    required this.modifiedAt,
    this.tags,
    this.color,
  });

  // Constructor từ Map (dùng khi đọc từ database)
  Note.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        title = map['title'],
        content = map['content'],
        priority = map['priority'],
        createdAt = DateTime.parse(map['createdAt']),  // Chuyển string sang DateTime
        modifiedAt = DateTime.parse(map['modifiedAt']),
        tags = map['tags'] != null
            ? List<String>.from(map['tags'].split(',')) // Chuyển string tags thành List
            : null,
        color = map['color'];

  // Chuyển đổi thành Map (dùng khi lưu vào database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),  // Chuyển DateTime sang string
      'modifiedAt': modifiedAt.toIso8601String(),
      'tags': tags?.join(','),  // Chuyển List tags thành string ngăn cách bởi dấu phẩy
      'color': color,
    };
  }

  // Phương thức tạo bản sao với một số thuộc tính thay đổi
  Note copyWith({
    int? id,
    String? title,
    String? content,
    int? priority,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<String>? tags,
    String? color,
  }) {
    return Note(
      id: id ?? this.id,       // Sử dụng giá trị mới nếu có, ngược lại dùng giá trị hiện tại
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      tags: tags ?? this.tags,
      color: color ?? this.color,
    );
  }

  // Override phương thức toString để in thông tin ghi chú
  @override
  String toString() {
    return 'Note{id: $id, title: $title, content: $content, priority: $priority, '
        'createdAt: $createdAt, modifiedAt: $modifiedAt, tags: $tags, color: $color}';
  }
}