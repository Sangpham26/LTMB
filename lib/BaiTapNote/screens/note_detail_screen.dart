import 'package:flutter/material.dart';
import '../models/note.dart';
import 'note_form_screen.dart';

// Màn hình hiển thị chi tiết một ghi chú
class NoteDetailScreen extends StatelessWidget {
  final Note note; // Note object được truyền từ màn hình trước

  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

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
    // Define common styling constants
    const double cardElevation = 2.0;
    const double borderRadius = 12.0;
    const double sectionSpacing = 16.0;
    const double innerPadding = 12.0;
    const Color borderColor = Colors.black12;
    const Color cardBackground = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chi tiết',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3A3A3A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteFormScreen(note: note),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(sectionSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Đảm bảo các phần tử trải rộng hết chiều ngang
            children: [
              // Title Section
              Card(
                elevation: cardElevation,
                color: cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  side: const BorderSide(color: borderColor),
                ),
                child: Container(
                  width: double.infinity, // Đảm bảo chiều rộng tối đa
                  padding: const EdgeInsets.all(innerPadding),
                  child: Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: sectionSpacing),

              // Metadata Section
              Card(
                elevation: cardElevation,
                color: cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  side: const BorderSide(color: borderColor),
                ),
                child: Container(
                  width: double.infinity, // Đảm bảo chiều rộng tối đa
                  padding: const EdgeInsets.all(innerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Priority
                      _buildMetadataRow(
                        icon: Icons.priority_high,
                        iconColor: Colors.red,
                        text: 'Độ ưu tiên: ${_getPriorityText(note.priority)}',
                      ),
                      const SizedBox(height: innerPadding),

                      // Created At
                      _buildMetadataRow(
                        icon: Icons.calendar_today,
                        iconColor: Colors.blue,
                        text: 'Ngày tạo: ${note.createdAt.toString().substring(0, 16)}',
                      ),
                      const SizedBox(height: innerPadding),

                      // Modified At
                      _buildMetadataRow(
                        icon: Icons.edit,
                        iconColor: Colors.green,
                        text: 'Sửa đổi: ${note.modifiedAt.toString().substring(0, 16)}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: sectionSpacing),

              // Content Section
              Card(
                elevation: cardElevation,
                color: cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  side: const BorderSide(color: borderColor),
                ),
                child: Container(
                  width: double.infinity, // Đảm bảo chiều rộng tối đa
                  padding: const EdgeInsets.all(innerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nội dung:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        note.content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: sectionSpacing),

              // Tags Section
              if (note.tags != null && note.tags!.isNotEmpty) ...[
                Card(
                  elevation: cardElevation,
                  color: cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: const BorderSide(color: borderColor),
                  ),
                  child: Container(
                    width: double.infinity, // Đảm bảo chiều rộng tối đa
                    padding: const EdgeInsets.all(innerPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tags:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: note.tags!.map((tag) {
                            return Chip(
                              label: Text(tag),
                              backgroundColor: const Color(0xFF3A3A3A),
                              labelStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: sectionSpacing),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build metadata rows with aligned icons and text
  Widget _buildMetadataRow({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}