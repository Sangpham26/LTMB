import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../database/note_database_helper.dart';
import '../models/note.dart';

// Màn hình form để thêm mới hoặc chỉnh sửa ghi chú
class NoteFormScreen extends StatefulWidget {
  final Note? note;

  const NoteFormScreen({Key? key, this.note}) : super(key: key);

  @override
  _NoteFormScreenState createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;

  late int _priority;
  late List<String> _tags;
  Color _selectedColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _tagsController = TextEditingController();
    _priority = widget.note?.priority ?? 1;
    _tags = widget.note?.tags ?? [];

    if (widget.note?.color != null) {
      _selectedColor = Color(
        int.parse('0xFF${widget.note!.color!.substring(1)}'),
      );
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();

      final note = Note(
        id: widget.note?.id,
        title: _titleController.text,
        content: _contentController.text,
        priority: _priority,
        createdAt: widget.note?.createdAt ?? now,
        modifiedAt: now,
        tags: _tags,
        color: '#${_selectedColor.value.toRadixString(16).substring(2)}',
      );

      try {
        if (widget.note == null) {
          await NoteDatabaseHelper.instance.insertNote(note);
        } else {
          await NoteDatabaseHelper.instance.updateNote(note);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi lưu ghi chú: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define styling constants to match NoteDetailScreen and NoteItem
    const double cardElevation = 2.0;
    const double borderRadius = 12.0;
    const double sectionSpacing = 16.0;
    const double innerPadding = 12.0;
    const Color borderColor = Colors.black12;
    const Color cardBackground = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.note == null ? 'Thêm ghi chú' : 'Chỉnh sửa ghi chú',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3A3A3A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _submit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(sectionSpacing),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tiêu đề
                Card(
                  elevation: cardElevation,
                  color: cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: const BorderSide(color: borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(innerPadding),
                    child: TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Tiêu đề',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF3A3A3A),
                          ),
                        ),
                        labelStyle: const TextStyle(color: Colors.black54),
                      ),
                      style: const TextStyle(color: Colors.black87),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Hãy nhập tiêu đề'
                                  : null,
                    ),
                  ),
                ),
                const SizedBox(height: sectionSpacing),

                // Nội dung
                Card(
                  elevation: cardElevation,
                  color: cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: const BorderSide(color: borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(innerPadding),
                    child: TextFormField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: 'Nội dung',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF3A3A3A),
                          ),
                        ),
                        labelStyle: const TextStyle(color: Colors.black54),
                      ),
                      style: const TextStyle(color: Colors.black87),
                      maxLines: 10,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Hãy nhập nội dung'
                                  : null,
                    ),
                  ),
                ),
                const SizedBox(height: sectionSpacing),

                // Độ ưu tiên
                Card(
                  elevation: cardElevation,
                  color: cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: const BorderSide(color: borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(innerPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Độ ưu tiên:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Radio<int>(
                              value: 1,
                              groupValue: _priority,
                              onChanged:
                                  (value) => setState(() => _priority = value!),
                              activeColor: const Color(0xFF3A3A3A),
                            ),
                            const Text(
                              'Thấp',
                              style: TextStyle(color: Colors.black87),
                            ),
                            Radio<int>(
                              value: 2,
                              groupValue: _priority,
                              onChanged:
                                  (value) => setState(() => _priority = value!),
                              activeColor: const Color(0xFF3A3A3A),
                            ),
                            const Text(
                              'Trung bình',
                              style: TextStyle(color: Colors.black87),
                            ),
                            Radio<int>(
                              value: 3,
                              groupValue: _priority,
                              onChanged:
                                  (value) => setState(() => _priority = value!),
                              activeColor: const Color(0xFF3A3A3A),
                            ),
                            const Text(
                              'Cao',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: sectionSpacing),

                // Màu sắc
                Card(
                  elevation: cardElevation,
                  color: cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: const BorderSide(color: borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(innerPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Màu sắc:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Chọn màu nền'),
                                    content: SingleChildScrollView(
                                      child: BlockPicker(
                                        pickerColor: _selectedColor,
                                        onColorChanged:
                                            (color) => setState(
                                              () => _selectedColor = color,
                                            ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Xong'),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: _selectedColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: const Center(
                              child: Text(
                                'Chọn màu nền',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: sectionSpacing),

                // Tags
                Card(
                  elevation: cardElevation,
                  color: cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: const BorderSide(color: borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(innerPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tags:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _tagsController,
                                decoration: InputDecoration(
                                  labelText: 'Thêm tag',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF3A3A3A),
                                    ),
                                  ),
                                  labelStyle: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              backgroundColor: const Color(0xFF3A3A3A),
                              radius: 18,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () {
                                  if (_tagsController.text.trim().isNotEmpty) {
                                    setState(() {
                                      _tags.add(_tagsController.text.trim());
                                      _tagsController.clear();
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _tags
                                  .map(
                                    (tag) => Chip(
                                      label: Text(
                                        tag,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFF3A3A3A),
                                      deleteIcon: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.white70,
                                      ),
                                      onDeleted:
                                          () =>
                                              setState(() => _tags.remove(tag)),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
