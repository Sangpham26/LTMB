import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Import thư viện color picker
import '../models/note.dart'; // Import model Note
import '../service/NoteService.dart'; // Import service để lưu/cập nhật note

// NoteFormScreen là StatefulWidget vì nó cần quản lý trạng thái của form
// (dữ liệu người dùng nhập, màu sắc, tags, độ ưu tiên).
class NoteFormScreen extends StatefulWidget {
  // Tham số tùy chọn 'note'. Nếu được cung cấp, màn hình sẽ ở chế độ chỉnh sửa.
  // Nếu null, màn hình ở chế độ thêm mới.
  final Note? note;

  // Constructor: yêu cầu key và có thể nhận 'note'.
  const NoteFormScreen({Key? key, this.note}) : super(key: key);

  @override
  _NoteFormScreenState createState() => _NoteFormScreenState();
}

// Lớp State chứa trạng thái và logic của NoteFormScreen.
class _NoteFormScreenState extends State<NoteFormScreen> {
  // GlobalKey để định danh Form và quản lý trạng thái của nó (validation).
  final _formKey = GlobalKey<FormState>();
  // Controller cho TextField tiêu đề.
  late TextEditingController _titleController;
  // Controller cho TextField nội dung.
  late TextEditingController _contentController;
  // Controller cho TextField nhập tag mới.
  late TextEditingController _tagsController;
  // Biến lưu trữ giá trị độ ưu tiên được chọn (mặc định là 1 - Thấp).
  late int _priority;
  // Danh sách các tag của ghi chú.
  late List<String> _tags;
  // Màu nền được chọn cho ghi chú (mặc định là trắng).
  Color _selectedColor = Colors.white;

  // initState được gọi một lần khi widget được tạo.
  @override
  void initState() {
    super.initState();
    // Khởi tạo các controller và biến trạng thái dựa trên việc có 'note' được truyền vào hay không.

    // Nếu có 'note' (chế độ sửa), lấy giá trị từ 'note'. Nếu không (chế độ thêm), dùng giá trị rỗng/mặc định.
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _tagsController = TextEditingController(); // TextField tag luôn bắt đầu rỗng.
    _priority = widget.note?.priority ?? 1; // Lấy priority từ note hoặc mặc định là 1.
    _tags = widget.note?.tags ?? []; // Lấy list tags từ note hoặc list rỗng.

    // Xử lý màu sắc: Nếu note có màu, chuyển đổi chuỗi hex thành Color.
    if (widget.note?.color != null && widget.note!.color!.isNotEmpty) {
      try {
        // Chuyển đổi chuỗi hex (ví dụ: "#RRGGBB") thành giá trị integer và tạo đối tượng Color.
        _selectedColor = Color(int.parse('0xFF${widget.note!.color!.substring(1)}'));
      } catch(e) {
        print("Lỗi parse màu: $e");
        // Giữ màu mặc định nếu parse lỗi
        _selectedColor = Colors.white;
      }
    }
  }

  // Giải phóng tài nguyên của các controller khi widget bị hủy.
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }


  /// Hàm xử lý khi người dùng nhấn nút lưu.
  void _submit() async {
    // Validate form: kiểm tra xem các trường bắt buộc đã được nhập đúng chưa.
    if (_formKey.currentState!.validate()) {
      // Lấy thời gian hiện tại để cập nhật `modifiedAt` và `createdAt` (nếu là note mới).
      final now = DateTime.now();

      // Tạo đối tượng Note từ dữ liệu trên form.
      final note = Note(
        // ID: giữ nguyên ID cũ nếu là sửa, null nếu là thêm mới (Firestore sẽ tự tạo).
        id: widget.note?.id,
        title: _titleController.text.trim(), // Lấy tiêu đề, xóa khoảng trắng thừa.
        content: _contentController.text.trim(), // Lấy nội dung, xóa khoảng trắng thừa.
        priority: _priority, // Độ ưu tiên đã chọn.
        // createdAt: giữ nguyên ngày tạo cũ nếu là sửa, dùng ngày hiện tại nếu là thêm mới.
        createdAt: widget.note?.createdAt ?? now,
        modifiedAt: now, // Luôn cập nhật thời gian sửa đổi là hiện tại.
        tags: _tags, // Danh sách tags đã thêm.
        // Chuyển đổi đối tượng Color thành chuỗi hex màu (vd: "#RRGGBB").
        // `value.toRadixString(16)` chuyển int thành hex.
        // `substring(2)` bỏ đi 2 ký tự đầu (alpha channel FF).
        color: '#${_selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
      );

      // Tương tác với NoteService để lưu hoặc cập nhật ghi chú.
      try {
        // Nếu widget.note là null -> chế độ thêm mới.
        if (widget.note == null) {
          await NoteService.instance.createNote(note);
        }
        // Ngược lại -> chế độ cập nhật.
        else {
          await NoteService.instance.updateNote(note);
        }
        // Sau khi lưu/cập nhật thành công, đóng màn hình form và trả về true
        // để màn hình trước (NoteListScreen) biết cần tải lại dữ liệu.
        if (mounted) {
          Navigator.pop(context, true); // true báo hiệu có thay đổi
        }
      } catch (e) {
        // Hiển thị lỗi nếu có vấn đề xảy ra trong quá trình lưu/cập nhật.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi lưu ghi chú: $e')),
          );
        }
      }
    } // Kết thúc if validate
  }

  // Build method xây dựng giao diện người dùng của form.
  @override
  Widget build(BuildContext context) {
    // --- Định nghĩa các hằng số style để tái sử dụng ---
    const double cardElevation = 2.0;
    const double borderRadius = 12.0;
    const double sectionSpacing = 16.0; // Khoảng cách giữa các Card
    const double innerPadding = 12.0; // Padding bên trong các Card
    const Color borderColor = Colors.black12; // Màu viền Card và TextField
    const Color cardBackground = Colors.white; // Màu nền Card
    const Color primaryColor = Color(0xFF3A3A3A); // Màu chính (AppBar, Radio active, ...)

    return Scaffold(
      appBar: AppBar(
        // Tiêu đề AppBar thay đổi tùy theo chế độ thêm mới hay chỉnh sửa.
        title: Text(
          widget.note == null ? 'Thêm ghi chú' : 'Chỉnh sửa ghi chú',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor, // Màu nền AppBar
        iconTheme: const IconThemeData(color: Colors.white), // Màu icon back
        // Nút hành động Lưu trên AppBar.
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white), // Icon lưu
            tooltip: 'Lưu ghi chú',
            onPressed: _submit, // Gọi hàm _submit khi nhấn.
          ),
        ],
      ),
      // Body của Scaffold chứa Form.
      body: Padding(
        padding: const EdgeInsets.all(sectionSpacing), // Padding xung quanh toàn bộ form
        child: Form(
          key: _formKey, // Gắn GlobalKey vào Form.
          // SingleChildScrollView cho phép cuộn nếu nội dung form dài hơn màn hình.
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Kéo dãn các Card theo chiều ngang
              children: [
                // --- Card Nhập Tiêu đề ---
                Card(
                  elevation: cardElevation,
                  color: cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: const BorderSide(color: borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(innerPadding),
                    // TextFormField cho tiêu đề.
                    child: TextFormField(
                      controller: _titleController, // Gắn controller.
                      decoration: InputDecoration(
                        labelText: 'Tiêu đề', // Nhãn
                        // Định dạng viền cho các trạng thái khác nhau
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
                          borderSide: const BorderSide(color: primaryColor), // Viền màu chính khi focus
                        ),
                        labelStyle: const TextStyle(color: Colors.black54), // Màu nhãn
                      ),
                      style: const TextStyle(color: Colors.black87), // Màu chữ nhập
                      // Validator kiểm tra tiêu đề không được rỗng.
                      validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Hãy nhập tiêu đề' : null,
                      textCapitalization: TextCapitalization.sentences, // Tự động viết hoa chữ cái đầu câu
                    ),
                  ),
                ),
                const SizedBox(height: sectionSpacing), // Khoảng cách

                // --- Card Nhập Nội dung ---
                Card(
                  elevation: cardElevation,
                  color: cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: const BorderSide(color: borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(innerPadding),
                    // TextFormField cho nội dung.
                    child: TextFormField(
                      controller: _contentController, // Gắn controller.
                      decoration: InputDecoration(
                        labelText: 'Nội dung',
                        alignLabelWithHint: true, // Căn chỉnh label với top của input field
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
                          borderSide: const BorderSide(color: primaryColor),
                        ),
                        labelStyle: const TextStyle(color: Colors.black54),
                      ),
                      style: const TextStyle(color: Colors.black87),
                      maxLines: 8, // Cho phép nhập nhiều dòng, tối đa 8 dòng hiển thị ban đầu.
                      // Validator kiểm tra nội dung không được rỗng.
                      validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Hãy nhập nội dung' : null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                const SizedBox(height: sectionSpacing), // Khoảng cách

                // --- Card Chọn Độ ưu tiên ---
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
                      crossAxisAlignment: CrossAxisAlignment.start, // Căn label sang trái
                      children: [
                        const Text( // Label
                          'Độ ưu tiên:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Row chứa các Radio button để chọn độ ưu tiên.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround, // Phân bố đều khoảng cách
                          children: [
                            // Sử dụng Flexible để các phần tử chiếm không gian linh hoạt
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min, // Chỉ chiếm không gian cần thiết
                                children: [
                                  Radio<int>(
                                    value: 1, // Giá trị của radio button này.
                                    groupValue: _priority, // Giá trị đang được chọn trong nhóm.
                                    // Hàm được gọi khi radio button này được chọn. Cập nhật _priority.
                                    onChanged: (value) => setState(() => _priority = value!),
                                    activeColor: primaryColor, // Màu khi được chọn.
                                  ),
                                  const Text('Thấp', style: TextStyle(color: Colors.black87)),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<int>(
                                    value: 2,
                                    groupValue: _priority,
                                    onChanged: (value) => setState(() => _priority = value!),
                                    activeColor: primaryColor,
                                  ),
                                  const Text('Trung bình', style: TextStyle(color: Colors.black87)),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<int>(
                                    value: 3,
                                    groupValue: _priority,
                                    onChanged: (value) => setState(() => _priority = value!),
                                    activeColor: primaryColor,
                                  ),
                                  const Text('Cao', style: TextStyle(color: Colors.black87)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: sectionSpacing), // Khoảng cách

                // --- Card Chọn Màu sắc ---
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
                        const Text( // Label
                          'Màu nền ghi chú:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // GestureDetector để bắt sự kiện nhấn vào ô hiển thị màu.
                        GestureDetector(
                          onTap: () {
                            // Hiển thị Dialog chứa Color Picker.
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Chọn màu nền'),
                                content: SingleChildScrollView(
                                  // Sử dụng BlockPicker từ thư viện flutter_colorpicker.
                                  child: BlockPicker(
                                    pickerColor: _selectedColor, // Màu hiện tại đang được chọn.
                                    // Callback được gọi khi người dùng chọn màu mới. Cập nhật _selectedColor.
                                    onColorChanged: (color) =>
                                        setState(() => _selectedColor = color),
                                    availableColors: const [ // Giới hạn các màu có sẵn (tùy chọn)
                                      Colors.white, Colors.yellowAccent, Colors.lightBlueAccent,
                                      Colors.lightGreenAccent, Colors.pinkAccent, Colors.orangeAccent,
                                      Colors.grey, Colors.tealAccent, Colors.purpleAccent,
                                    ],
                                  ),
                                ),
                                actions: [
                                  // Nút "Xong" để đóng Dialog.
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Xong'),
                                  ),
                                ],
                              ),
                            );
                          },
                          // Container hiển thị màu đang được chọn.
                          child: Container(
                            height: 45, // Chiều cao của ô màu
                            decoration: BoxDecoration(
                              color: _selectedColor, // Màu nền là màu đã chọn.
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black26), // Viền nhẹ
                            ),
                            child: Center(
                              // Hiển thị text hướng dẫn hoặc mã màu (tùy chọn)
                              child: Text(
                                'Nhấn để chọn màu',
                                style: TextStyle(
                                  // Chọn màu chữ tương phản với màu nền
                                  color: _selectedColor.computeLuminance() > 0.5
                                      ? Colors.black54
                                      : Colors.white70,
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
                const SizedBox(height: sectionSpacing), // Khoảng cách

                // --- Card Quản lý Tags ---
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
                        const Text( // Label
                          'Tags (Nhãn):',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Row chứa TextField nhập tag và nút Add.
                        Row(
                          children: [
                            // TextField để nhập tag mới.
                            Expanded(
                              child: TextField(
                                controller: _tagsController, // Gắn controller.
                                decoration: InputDecoration(
                                    labelText: 'Thêm tag mới',
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
                                      borderSide: const BorderSide(color: primaryColor),
                                    ),
                                    labelStyle: const TextStyle(color: Colors.black54),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10) // Điều chỉnh padding
                                ),
                                style: const TextStyle(color: Colors.black87),
                                // Cho phép nhấn Enter để thêm tag (tùy chọn)
                                onSubmitted: (value) {
                                  if (value.trim().isNotEmpty) {
                                    setState(() {
                                      if (!_tags.contains(value.trim())) { // Tránh thêm tag trùng
                                        _tags.add(value.trim());
                                      }
                                      _tagsController.clear();
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8), // Khoảng cách
                            // Nút Add tag dạng CircleAvatar chứa IconButton.
                            CircleAvatar(
                              backgroundColor: primaryColor, // Màu nền nút
                              radius: 22, // Kích thước nút
                              child: IconButton(
                                icon: const Icon(Icons.add, color: Colors.white, size: 24), // Icon dấu cộng
                                tooltip: 'Thêm tag',
                                onPressed: () {
                                  // Chỉ thêm tag nếu TextField không rỗng.
                                  final newTag = _tagsController.text.trim();
                                  if (newTag.isNotEmpty) {
                                    setState(() {
                                      // Tránh thêm tag trùng lặp
                                      if (!_tags.contains(newTag)) {
                                        _tags.add(newTag);
                                      }
                                      _tagsController.clear(); // Xóa text trong TextField sau khi thêm.
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12), // Khoảng cách trước khi hiển thị tags
                        // Wrap để hiển thị danh sách các tag đã thêm.
                        // Wrap tự động xuống dòng nếu không đủ chỗ trên một hàng.
                        Wrap(
                          spacing: 8, // Khoảng cách ngang giữa các Chip.
                          runSpacing: 4, // Khoảng cách dọc giữa các hàng Chip.
                          children: _tags.map((tag) => Chip(
                            // Nội dung text của Chip là tên tag.
                            label: Text(
                              tag,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: primaryColor.withOpacity(0.8), // Màu nền Chip.
                            // Icon xóa tag (hình dấu X).
                            deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white70),
                            // Callback được gọi khi nhấn vào icon xóa.
                            onDeleted: () => setState(() => _tags.remove(tag)), // Xóa tag khỏi list.
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // Padding bên trong Chip.
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Giảm vùng chạm
                          )).toList(), // Chuyển Iterable thành List để Wrap có thể sử dụng.
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: sectionSpacing * 2), // Thêm khoảng trống ở cuối
              ],
            ),
          ),
        ),
      ),
    );
  }
}