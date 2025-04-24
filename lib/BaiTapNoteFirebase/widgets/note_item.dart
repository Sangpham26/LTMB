import 'package:flutter/material.dart';
import '../models/note.dart'; // Import model Note để biết cấu trúc dữ liệu của note

// NoteItem là một StatelessWidget vì nó chỉ hiển thị dữ liệu dựa trên input
// và không quản lý trạng thái nội bộ phức tạp có thể thay đổi sau khi build.
class NoteItem extends StatelessWidget {
  // Dữ liệu của ghi chú cần hiển thị
  final Note note;
  // Callback function sẽ được gọi khi người dùng nhấn nút "Sửa"
  final VoidCallback onEdit;
  // Callback function sẽ được gọi khi người dùng xác nhận xóa ghi chú
  final VoidCallback onDelete;

  // Constructor yêu cầu các tham số bắt buộc: note, onEdit, onDelete
  const NoteItem({
    Key? key, // Key cho widget, hữu ích cho Flutter quản lý widget hiệu quả
    required this.note, // Dữ liệu ghi chú là bắt buộc
    required this.onEdit, // Hàm xử lý sự kiện sửa là bắt buộc
    required this.onDelete, // Hàm xử lý sự kiện xóa là bắt buộc
  }) : super(key: key);

  // --- Helper Functions (Hàm hỗ trợ) ---

  // Hàm trả về màu sắc dựa trên mức độ ưu tiên (priority)
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1: // Ưu tiên thấp
        return Colors.green;
      case 2: // Ưu tiên trung bình
        return Colors.orange;
      case 3: // Ưu tiên cao
        return Colors.red;
      default: // Mặc định hoặc không xác định
        return Colors.grey;
    }
  }

  // Hàm trả về chuỗi văn bản mô tả mức độ ưu tiên
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

  // --- Build Method (Phương thức xây dựng giao diện) ---
  @override
  Widget build(BuildContext context) {
    // --- Xử lý màu nền và màu chữ ---

    // Màu nền mặc định là trắng nếu note không có màu được chỉ định
    Color backgroundColor = Colors.white;
    // Kiểm tra xem note có thuộc tính 'color' và nó không rỗng không
    if (note.color != null && note.color!.isNotEmpty) {
      try {
        // Cố gắng chuyển đổi chuỗi hex color (ví dụ: "#RRGGBB") thành đối tượng Color của Flutter.
        // '0xFF' được thêm vào đầu để biểu thị alpha channel (độ trong suốt) là hoàn toàn không trong suốt.
        // substring(1) để loại bỏ dấu '#' ở đầu chuỗi hex.
        backgroundColor = Color(int.parse('0xFF${note.color!.substring(1)}'));
      } catch (e) {
        // In ra lỗi nếu chuỗi màu không hợp lệ
        print('Lỗi khi chuyển đổi màu: $e');
        // Giữ màu nền mặc định là trắng nếu có lỗi
      }
    }

    // Tính toán độ sáng (luminance) của màu nền.
    // Nếu màu nền sáng (> 0.5), dùng màu chữ đen (Colors.black).
    // Nếu màu nền tối (<= 0.5), dùng màu chữ trắng (Colors.white) để đảm bảo độ tương phản tốt.
    final textColor = backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    // Giảm nhẹ độ đậm của màu nền bằng cách thêm một chút độ trong suốt (opacity).
    // Điều này có thể giúp giao diện trông nhẹ nhàng hơn.
    final adjustedBackgroundColor = backgroundColor.withOpacity(0.87);

    // --- Cấu trúc UI ---

    // Sử dụng Card để tạo hiệu ứng nổi và bo góc cho mỗi item ghi chú.
    return Card(
      elevation: 2, // Độ nổi (shadow) của Card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25), // Bo tròn các góc của Card
      ),
      color: adjustedBackgroundColor, // Đặt màu nền đã được điều chỉnh cho Card
      // Padding bên trong Card để nội dung không bị sát viền.
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        // Sử dụng Stack để cho phép đặt các nút Sửa/Xóa chồng lên trên phần nội dung.
        child: Stack(
          children: [
            // Column chứa các thông tin chính của ghi chú (tiêu đề, nội dung, ưu tiên, thời gian).
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Căn chỉnh các phần tử con sang trái.
              mainAxisSize: MainAxisSize.min, // Làm cho Column chỉ chiếm không gian dọc cần thiết.
              children: [
                // --- Hiển thị Tiêu đề ---
                Text(
                  note.title, // Lấy tiêu đề từ đối tượng note
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // In đậm
                    fontSize: 16, // Cỡ chữ
                    color: textColor, // Sử dụng màu chữ đã tính toán để đảm bảo tương phản
                    // Thêm bóng đổ nhẹ cho chữ để dễ đọc hơn trên các nền khác nhau
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  maxLines: 2, // Giới hạn hiển thị tối đa 2 dòng
                  overflow: TextOverflow.ellipsis, // Hiển thị dấu "..." nếu text dài hơn
                ),
                const SizedBox(height: 6), // Khoảng trống nhỏ giữa tiêu đề và nội dung

                // --- Hiển thị Nội dung ---
                Text(
                  note.content, // Lấy nội dung từ đối tượng note
                  maxLines: 3, // Giới hạn hiển thị tối đa 3 dòng
                  overflow: TextOverflow.ellipsis, // Hiển thị dấu "..." nếu text dài hơn
                  style: TextStyle(
                    fontSize: 14, // Cỡ chữ nhỏ hơn tiêu đề
                    color: textColor, // Sử dụng màu chữ tương phản
                    shadows: [ // Thêm bóng đổ
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6), // Khoảng trống

                // --- Hiển thị Độ ưu tiên ---
                Row( // Sắp xếp label "Độ ưu tiên" và giá trị ưu tiên theo hàng ngang
                  crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa các item theo chiều dọc
                  children: [
                    // Label "Độ ưu tiên"
                    Text(
                      'Độ ưu tiên: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                        fontWeight: FontWeight.bold, // In đậm label
                        shadows: [ // Bóng đổ nhẹ
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 1,
                            offset: const Offset(0, 0.5),
                          ),
                        ],
                      ),
                    ),
                    // Container chứa text hiển thị mức độ ưu tiên (Thấp, Trung bình, Cao)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Padding bên trong container
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9), // Nền trắng hơi mờ để nổi bật
                        borderRadius: BorderRadius.circular(5), // Bo góc nhẹ
                        boxShadow: [ // Thêm bóng đổ nhẹ cho container
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      // Text hiển thị mức độ ưu tiên
                      child: Text(
                        _getPriorityText(note.priority), // Lấy text từ hàm helper
                        style: TextStyle(
                          color: _getPriorityColor(note.priority), // Lấy màu từ hàm helper
                          fontSize: 12, // Cỡ chữ nhỏ
                          fontWeight: FontWeight.bold, // In đậm
                          shadows: [ // Thêm bóng đổ
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
                const SizedBox(height: 6), // Khoảng trống

                // --- Hiển thị Thời gian sửa đổi ---
                Text(
                  // Định dạng lại chuỗi thời gian chỉ hiển thị ngày và giờ (YYYY-MM-DD HH:MM)
                  'Sửa đổi: ${note.modifiedAt.toString().substring(0, 16)}',
                  style: TextStyle(
                    fontSize: 12, // Cỡ chữ nhỏ
                    // Làm mờ màu chữ một chút để ít nổi bật hơn
                    color: textColor.withOpacity(0.7),
                    shadows: [ // Thêm bóng đổ
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6), // Khoảng trống cuối cùng trước các nút (nếu cần)
              ],
            ), // Kết thúc Column chứa nội dung

            // --- Nút Sửa và Xóa ---
            // Positioned được dùng trong Stack để đặt widget con tại vị trí cụ thể.
            // Ở đây, đặt các nút ở góc dưới cùng bên phải của Card.
            Positioned(
              bottom: 0, // Cách đáy 0
              right: 0, // Cách phải 0
              child: Row( // Sắp xếp 2 nút Sửa và Xóa theo hàng ngang
                children: [
                  // Nút Sửa
                  IconButton(
                    icon: Icon(Icons.edit, size: 20, color: textColor), // Icon sửa, cỡ 20, màu chữ tương phản
                    onPressed: onEdit, // Gọi callback onEdit khi nhấn
                    padding: EdgeInsets.zero, // Bỏ padding mặc định để nút nhỏ gọn hơn
                  ),
                  // Nút Xóa
                  IconButton(
                    icon: Icon(Icons.delete, size: 20, color: textColor), // Icon xóa
                    // Khi nhấn nút xóa:
                    onPressed: () {
                      // Hiển thị hộp thoại xác nhận trước khi thực sự xóa.
                      showDialog(
                        context: context, // Context hiện tại
                        builder: (context) => AlertDialog( // Tạo hộp thoại cảnh báo
                          title: const Text('Xác nhận xóa'),
                          content: const Text('Bạn chắc chắn muốn xóa?'),
                          actions: [ // Các nút hành động trong hộp thoại
                            // Nút Hủy
                            TextButton(
                              onPressed: () => Navigator.pop(context), // Chỉ đóng hộp thoại
                              child: const Text('Hủy'),
                            ),
                            // Nút Xóa (trong hộp thoại)
                            TextButton(
                              onPressed: () {
                                onDelete(); // Gọi callback onDelete (được truyền từ widget cha) để thực hiện xóa
                                Navigator.pop(context); // Đóng hộp thoại sau khi xóa
                              },
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );
                    },
                    padding: EdgeInsets.zero, // Bỏ padding mặc định
                  ),
                ],
              ),
            ), // Kết thúc Positioned chứa các nút
          ],
        ), // Kết thúc Stack
      ), // Kết thúc Padding
    ); // Kết thúc Card
  }
}