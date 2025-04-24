import 'package:flutter/material.dart';
import '../models/note.dart'; // Import model Note
import 'note_form_screen.dart'; // Import màn hình sửa ghi chú

// Màn hình hiển thị chi tiết một ghi chú.
// Đây là StatelessWidget vì nó chỉ hiển thị dữ liệu của note được truyền vào
// và không thay đổi trạng thái nội bộ.
class NoteDetailScreen extends StatelessWidget {
  // Đối tượng Note chứa dữ liệu chi tiết cần hiển thị.
  // Được truyền từ màn hình danh sách khi người dùng nhấn vào một item.
  final Note note;

  // Constructor yêu cầu một đối tượng Note.
  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  // --- Helper Function ---
  /// Hàm trợ giúp để chuyển đổi giá trị số của độ ưu tiên thành chuỗi văn bản.
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

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    // --- Định nghĩa các hằng số style để tái sử dụng ---
    const double cardElevation = 2.0; // Độ nổi của Card
    const double borderRadius = 12.0; // Bán kính bo góc Card
    const double sectionSpacing = 16.0; // Khoảng cách dọc giữa các Card
    const double innerPadding = 12.0; // Padding bên trong Card
    const Color borderColor = Colors.black12; // Màu viền Card
    const Color cardBackground = Colors.white; // Màu nền Card
    const Color primaryColor = Color(0xFF3A3A3A); // Màu chính (AppBar, tags)

    // Scaffold cung cấp cấu trúc cơ bản cho màn hình.
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chi tiết Ghi chú', // Tiêu đề màn hình
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor, // Màu nền AppBar
        iconTheme: const IconThemeData(color: Colors.white), // Màu cho nút back
        // Các nút hành động trên AppBar.
        actions: [
          // Nút chỉnh sửa ghi chú.
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white), // Icon bút chì
            tooltip: 'Chỉnh sửa ghi chú',
            onPressed: () {
              // Điều hướng đến màn hình NoteFormScreen ở chế độ chỉnh sửa.
              // Truyền đối tượng 'note' hiện tại vào NoteFormScreen.
              // pushReplacement thay thế màn hình hiện tại, khi lưu xong sẽ quay lại list.
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteFormScreen(note: note),
                ),
              );
              // Nếu muốn quay lại màn hình detail sau khi sửa, dùng Navigator.push()
              /*
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteFormScreen(note: note),
                ),
              ).then((didSaveChanges) {
                 // Nếu NoteFormScreen trả về true (đã lưu), có thể cần cập nhật lại UI ở đây
                 // (ví dụ: nếu NoteDetailScreen là StatefulWidget và cần load lại note mới)
                 if (didSaveChanges == true && mounted) { // Cần mounted nếu là StatefulWidget
                    // Load lại note hoặc cập nhật state
                 }
              });
              */
            },
          ),
        ],
      ),
      // Body của Scaffold, cho phép cuộn nếu nội dung dài.
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(sectionSpacing), // Padding xung quanh nội dung
          child: Column(
            // Căn chỉnh các phần tử con sang trái.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Phần Hiển thị Tiêu đề ---
              Card(
                elevation: cardElevation,
                color: cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  side: const BorderSide(color: borderColor),
                ),
                child: Container(
                  width: double.infinity, // Đảm bảo Card chiếm hết chiều rộng
                  padding: const EdgeInsets.all(innerPadding + 4), // Padding lớn hơn cho tiêu đề
                  // Text hiển thị tiêu đề của ghi chú.
                  child: Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 24, // Cỡ chữ lớn hơn
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center, // Căn giữa tiêu đề (tùy chọn)
                  ),
                ),
              ),
              const SizedBox(height: sectionSpacing), // Khoảng cách

              // --- Phần Hiển thị Metadata (Thông tin phụ) ---
              Card(
                elevation: cardElevation,
                color: cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  side: const BorderSide(color: borderColor),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(innerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hiển thị Độ ưu tiên sử dụng hàm helper _buildMetadataRow.
                      _buildMetadataRow(
                        icon: Icons.flag_outlined, // Icon cờ
                        iconColor: Colors.orange.shade700,
                        text: 'Độ ưu tiên: ${_getPriorityText(note.priority)}', // Lấy text từ hàm helper
                      ),
                      const SizedBox(height: innerPadding / 1.5), // Khoảng cách nhỏ hơn

                      // Hiển thị Ngày tạo.
                      _buildMetadataRow(
                        icon: Icons.calendar_today_outlined, // Icon lịch
                        iconColor: Colors.blue.shade600,
                        // Định dạng lại chuỗi DateTime chỉ hiển thị YYYY-MM-DD HH:MM.
                        text: 'Ngày tạo: ${note.createdAt.toString().substring(0, 16)}',
                      ),
                      const SizedBox(height: innerPadding / 1.5),

                      // Hiển thị Ngày sửa đổi cuối cùng.
                      _buildMetadataRow(
                        icon: Icons.edit_calendar_outlined, // Icon lịch sửa đổi
                        iconColor: Colors.green.shade600,
                        text: 'Sửa đổi: ${note.modifiedAt.toString().substring(0, 16)}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: sectionSpacing), // Khoảng cách

              // --- Phần Hiển thị Nội dung ---
              Card(
                elevation: cardElevation,
                color: cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  side: const BorderSide(color: borderColor),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(innerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label "Nội dung".
                      const Text(
                        'Nội dung:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8), // Khoảng cách nhỏ
                      // Text hiển thị nội dung chính của ghi chú.
                      SelectableText( // Cho phép người dùng chọn và copy text
                        note.content,
                        style: const TextStyle(
                          fontSize: 16, // Cỡ chữ nội dung
                          height: 1.5, // Tăng khoảng cách giữa các dòng cho dễ đọc
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.justify, // Căn đều 2 bên (tùy chọn)
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: sectionSpacing), // Khoảng cách

              // --- Phần Hiển thị Tags ---
              // Chỉ hiển thị phần này nếu note có tags và danh sách tags không rỗng.
              if (note.tags != null && note.tags!.isNotEmpty) ...[
                Card(
                  elevation: cardElevation,
                  color: cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: const BorderSide(color: borderColor),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(innerPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label "Tags".
                        const Text(
                          'Tags:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Sử dụng Wrap để hiển thị các Chip tag, tự động xuống dòng.
                        Wrap(
                          spacing: 8, // Khoảng cách ngang giữa các tag.
                          runSpacing: 8, // Khoảng cách dọc giữa các hàng tag.
                          // Map qua danh sách tags và tạo một Chip cho mỗi tag.
                          children: note.tags!.map((tag) {
                            return Chip(
                              label: Text(tag), // Text hiển thị là tên tag.
                              backgroundColor: primaryColor.withOpacity(0.8), // Màu nền Chip.
                              labelStyle: const TextStyle(
                                color: Colors.white, // Màu chữ tag.
                                fontSize: 14,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // Padding bên trong Chip.
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Giảm vùng chạm
                            );
                          }).toList(), // Chuyển Iterable thành List.
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: sectionSpacing), // Khoảng cách cuối cùng (nếu có tags).
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Widget trợ giúp để xây dựng một hàng hiển thị metadata (icon + text).
  /// Giúp code trong `build` gọn gàng và tái sử dụng được cấu trúc này.
  Widget _buildMetadataRow({
    required IconData icon, // Icon cần hiển thị.
    required Color iconColor, // Màu của icon.
    required String text, // Nội dung text cần hiển thị.
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa icon và text theo chiều dọc.
      children: [
        Icon(icon, size: 20, color: iconColor), // Icon với kích thước và màu sắc.
        const SizedBox(width: 10), // Khoảng cách giữa icon và text.
        // Expanded để Text chiếm hết không gian còn lại trên hàng.
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15, // Cỡ chữ cho metadata.
              color: Colors.grey[700], // Màu chữ hơi xám.
            ),
          ),
        ),
      ],
    );
  }
}