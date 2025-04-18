import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteItem extends StatelessWidget {
  final Note note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteItem({
    Key? key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Cao';
      default:
        return 'Không xác định';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Chuyển đổi note.color thành Color (nếu có)
    Color backgroundColor = Colors.white; // Màu mặc định nếu không có màu
    if (note.color != null && note.color!.isNotEmpty) {
      try {
        backgroundColor = Color(int.parse('0xFF${note.color!.substring(1)}'));
      } catch (e) {
        print('Lỗi khi chuyển đổi màu: $e');
      }
    }

    // Tính độ sáng của màu nền để chọn màu chữ
    final textColor = backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    // Giảm độ đậm của màu nền bằng cách thêm opacity
    final adjustedBackgroundColor = backgroundColor.withOpacity(0.87);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      color: adjustedBackgroundColor, // Áp dụng màu nền đã điều chỉnh
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tiêu đề
                Text(
                  note.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Nội dung
                Text(
                  note.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Độ ưu tiên
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Độ ưu tiên: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 1,
                            offset: const Offset(0, 0.5),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        _getPriorityText(note.priority),
                        style: TextStyle(
                          color: _getPriorityColor(note.priority),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Thời gian sửa đổi
                Text(
                  'Sửa đổi: ${note.modifiedAt.toString().substring(0, 16)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.7),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
            // Nút Sửa/Xóa
            Positioned(
              bottom: 0,
              right: 0,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, size: 20, color: textColor),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 20, color: textColor),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận xóa'),
                          content: const Text('Bạn chắc chắn muốn xóa?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () {
                                onDelete();
                                Navigator.pop(context);
                              },
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}