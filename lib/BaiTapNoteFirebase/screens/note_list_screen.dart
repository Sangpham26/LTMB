import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Để kiểm tra trạng thái đăng nhập và đăng xuất
import '../models/note.dart'; // Model dữ liệu cho ghi chú
import '../widgets/note_item.dart'; // Widget hiển thị một ghi chú đơn lẻ
import 'note_form_screen.dart'; // Màn hình thêm/sửa ghi chú
import 'note_detail_screen.dart'; // Màn hình xem chi tiết ghi chú
import '../service/NoteService.dart'; // Service để tương tác với Firestore
import 'login_screen.dart'; // Màn hình đăng nhập

// NoteListScreen là StatefulWidget vì trạng thái của nó (danh sách ghi chú, chế độ xem, bộ lọc) có thể thay đổi.
class NoteListScreen extends StatefulWidget {
  const NoteListScreen({Key? key}) : super(key: key);

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

// Lớp State chứa trạng thái và logic cho NoteListScreen.
class _NoteListScreenState extends State<NoteListScreen> {
  // Danh sách các ghi chú sẽ được hiển thị.
  List<Note> _notes = [];
  // Trạng thái chế độ xem: true = GridView, false = ListView.
  bool _isGridView = false;
  // Lưu trữ giá trị độ ưu tiên đang được lọc (null = không lọc).
  int? _filterPriority;
  // Controller cho TextField tìm kiếm.
  final TextEditingController _searchController = TextEditingController();

  // initState được gọi một lần khi widget được tạo lần đầu tiên.
  @override
  void initState() {
    super.initState();
    // Tải danh sách ghi chú ban đầu khi màn hình được khởi tạo.
    _loadNotes();
  }

  // Giải phóng tài nguyên khi widget bị hủy.
  @override
  void dispose() {
    _searchController.dispose(); // Quan trọng: phải dispose controller
    super.dispose();
  }

  /// Hàm tải danh sách ghi chú từ NoteService.
  /// Có thể tải tất cả, lọc theo độ ưu tiên, hoặc tìm kiếm theo từ khóa.
  ///
  /// [query]: Từ khóa tìm kiếm (nếu có).
  /// [priority]: Độ ưu tiên cần lọc (nếu có).
  Future<void> _loadNotes({String? query, int? priority}) async {
    try {
      List<Note> fetchedNotes;
      // Ưu tiên tìm kiếm nếu có query
      if (query != null && query.isNotEmpty) {
        fetchedNotes = await NoteService.instance.searchNotes(query);
      }
      // Nếu không tìm kiếm, kiểm tra lọc theo độ ưu tiên
      else if (priority != null) {
        fetchedNotes = await NoteService.instance.getNotesByPriority(priority);
      }
      // Mặc định: lấy tất cả ghi chú
      else {
        fetchedNotes = await NoteService.instance.getAllNotes();
      }

      // Cập nhật trạng thái và rebuild UI với danh sách ghi chú mới.
      if (mounted) { // Kiểm tra widget còn tồn tại trước khi gọi setState
        setState(() {
          _notes = fetchedNotes;
        });
      }
    } catch (e) {
      // Hiển thị lỗi nếu có vấn đề khi tải ghi chú.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải ghi chú: $e')),
        );
      }
    }
  }

  /// Hàm xóa một ghi chú dựa trên ID.
  ///
  /// [id]: ID của ghi chú cần xóa.
  Future<void> _deleteNote(String id) async {
    try {
      // Gọi hàm xóa từ NoteService.
      final deleted = await NoteService.instance.deleteNote(id);
      if (mounted) {
        if (deleted) {
          // Tải lại danh sách ghi chú sau khi xóa thành công.
          _loadNotes(query: _searchController.text, priority: _filterPriority); // Tải lại với bộ lọc/tìm kiếm hiện tại
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể xóa ghi chú hoặc ghi chú không tồn tại.')),
          );
        }
      }
    } catch (e) {
      // Hiển thị lỗi nếu có vấn đề khi xóa.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa ghi chú: $e')),
        );
      }
    }
  }

  // Build method xây dựng giao diện người dùng.
  @override
  Widget build(BuildContext context) {
    // StreamBuilder lắng nghe trạng thái đăng nhập của người dùng.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Stream cung cấp thông tin User?
      builder: (context, snapshot) {
        // --- Xử lý trạng thái kết nối của Stream ---
        // Nếu đang chờ dữ liệu (kiểm tra trạng thái đăng nhập)
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Hiển thị vòng tròn loading ở giữa màn hình.
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        // Nếu stream không có dữ liệu (nghĩa là người dùng chưa đăng nhập).
        if (!snapshot.hasData) {
          // Chuyển hướng người dùng đến màn hình LoginScreen.
          return const LoginScreen();
        }

        // --- Nếu người dùng đã đăng nhập, xây dựng giao diện chính ---
        return Scaffold(
          appBar: AppBar(
            title: const Text('Ghi chú', style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF3A3A3A), // Màu nền AppBar
            iconTheme: const IconThemeData(color: Colors.white), // Màu cho các icon trên AppBar
            // Các nút hành động trên AppBar.
            actions: [
              // Nút làm mới danh sách ghi chú.
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Làm mới / Xóa bộ lọc', // Tooltip khi giữ chuột/nhấn giữ
                onPressed: () {
                  // Reset bộ lọc và ô tìm kiếm, sau đó tải lại tất cả ghi chú.
                  _filterPriority = null;
                  _searchController.clear();
                  _loadNotes();
                },
              ),
              // Nút chuyển đổi chế độ xem List/Grid.
              IconButton(
                // Icon thay đổi dựa trên trạng thái _isGridView.
                icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                tooltip: _isGridView ? 'Chế độ danh sách' : 'Chế độ lưới',
                onPressed: () {
                  // Cập nhật trạng thái và rebuild UI để thay đổi layout.
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
              ),
              // Nút lọc theo độ ưu tiên (sử dụng PopupMenuButton).
              PopupMenuButton<int>(
                tooltip: 'Lọc theo độ ưu tiên',
                // Hàm được gọi khi một mục trong menu được chọn.
                onSelected: (value) {
                  setState(() {
                    _filterPriority = value; // Cập nhật trạng thái bộ lọc
                    _searchController.clear(); // Xóa tìm kiếm khi lọc
                  });
                  // Tải lại ghi chú với độ ưu tiên đã chọn.
                  _loadNotes(priority: value);
                },
                // Hàm xây dựng các mục trong menu popup.
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 1, child: Text('Ưu tiên: Thấp')),
                  PopupMenuItem(value: 2, child: Text('Ưu tiên: Trung bình')),
                  PopupMenuItem(value: 3, child: Text('Ưu tiên: Cao')),
                  // Có thể thêm mục "Tất cả" nếu muốn
                  // PopupMenuItem(value: null, child: Text('Tất cả')),
                ],
                icon: const Icon(Icons.filter_list), // Icon cho nút lọc.
              ),
              // Nút đăng xuất.
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Đăng xuất',
                onPressed: () async {
                  // Gọi hàm signOut của FirebaseAuth.
                  await FirebaseAuth.instance.signOut();
                  // Thay thế màn hình hiện tại bằng LoginScreen, không cho quay lại.
                  if (mounted) { // Kiểm tra trước khi sử dụng context
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
              ),
            ],
          ),
          // Body của Scaffold chứa nội dung chính.
          body: Column(
            children: [
              // --- Thanh tìm kiếm ---
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: _searchController, // Gắn controller.
                  decoration: InputDecoration(
                    labelText: 'Tìm kiếm tiêu đề, nội dung...', // Nhãn gợi ý
                    filled: true, // Cho phép tô màu nền
                    fillColor: Colors.grey[200], // Màu nền xám nhạt
                    // Định dạng đường viền khi không focus và khi có focus
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20), // Bo tròn góc
                      borderSide: BorderSide.none, // Không có viền khi bình thường
                    ),
                    enabledBorder: OutlineInputBorder( // Viền khi không focus
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder( // Viền khi đang focus
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.grey, width: 1.5), // Viền xám nhẹ
                    ),
                    prefixIcon: const Icon(Icons.search), // Icon tìm kiếm ở đầu
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Padding bên trong
                    // Thêm nút xóa nhanh nội dung tìm kiếm (tùy chọn)
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _loadNotes(priority: _filterPriority); // Tải lại với bộ lọc hiện tại (nếu có)
                      },
                    )
                        : null,
                  ),
                  // Hàm được gọi mỗi khi nội dung TextField thay đổi.
                  onChanged: (value) {
                    // Tải lại danh sách ghi chú với từ khóa tìm kiếm mới.
                    // Debounce có thể được thêm ở đây để tránh gọi API quá thường xuyên.
                    setState(() {
                      _filterPriority = null; // Xóa bộ lọc khi đang tìm kiếm
                    });
                    _loadNotes(query: value);
                  },
                ),
              ),
              // --- Danh sách hoặc lưới ghi chú ---
              // Expanded đảm bảo phần này chiếm hết không gian còn lại trong Column.
              Expanded(
                // Kiểm tra xem danh sách ghi chú có rỗng không.
                child: _notes.isEmpty
                // Nếu rỗng, hiển thị thông báo.
                    ? Center(
                    child: Text(
                      _searchController.text.isNotEmpty || _filterPriority != null
                          ? 'Không tìm thấy ghi chú phù hợp'
                          : 'Chưa có ghi chú nào.\nNhấn + để thêm mới.' , // Thông báo tùy ngữ cảnh
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    )
                )
                // Nếu không rỗng, hiển thị GridView hoặc ListView dựa trên _isGridView.
                    : _isGridView
                // --- Chế độ GridView ---
                    ? GridView.builder(
                  padding: const EdgeInsets.all(10), // Padding xung quanh Grid.
                  // Cấu hình cách các item được sắp xếp trong Grid.
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250, // Chiều rộng tối đa của mỗi item.
                    mainAxisSpacing: 10, // Khoảng cách dọc giữa các item.
                    crossAxisSpacing: 10, // Khoảng cách ngang giữa các item.
                    childAspectRatio: 0.85, // Tỷ lệ chiều rộng/chiều cao của item.
                  ),
                  itemCount: _notes.length, // Số lượng item trong Grid.
                  // Hàm xây dựng từng item trong Grid.
                  itemBuilder: (context, index) {
                    final note = _notes[index]; // Lấy ghi chú tại vị trí index.
                    // GestureDetector bắt sự kiện nhấn vào item.
                    return GestureDetector(
                      onTap: () {
                        // Điều hướng đến màn hình chi tiết khi nhấn vào.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteDetailScreen(note: note),
                          ),
                        );
                      },
                      // Sử dụng NoteItem widget để hiển thị thông tin ghi chú.
                      child: NoteItem(
                        note: note,
                        // Callback khi nhấn nút sửa trên NoteItem.
                        onEdit: () {
                          // Điều hướng đến màn hình sửa ghi chú.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteFormScreen(note: note),
                            ),
                            // `.then` được gọi sau khi màn hình NoteFormScreen đóng lại.
                            // Tải lại danh sách ghi chú để cập nhật thay đổi (nếu có).
                          ).then((_) => _loadNotes(query: _searchController.text, priority: _filterPriority));
                        },
                        // Callback khi nhấn nút xóa trên NoteItem.
                        onDelete: () => _deleteNote(note.id!), // Gọi hàm xóa với ID của ghi chú.
                      ),
                    );
                  },
                )
                // --- Chế độ ListView ---
                    : ListView.builder(
                  padding: const EdgeInsets.all(8), // Padding xung quanh ListView.
                  itemCount: _notes.length, // Số lượng item.
                  // Hàm xây dựng từng item trong ListView.
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    // GestureDetector bắt sự kiện nhấn.
                    return GestureDetector(
                      onTap: () {
                        // Điều hướng đến màn hình chi tiết.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteDetailScreen(note: note),
                          ),
                        );
                      },
                      // Padding dọc cho mỗi item trong ListView.
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        // Đảm bảo item có chiều cao tối thiểu (tránh bị quá nhỏ).
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 150),
                          // Sử dụng NoteItem để hiển thị.
                          child: NoteItem(
                            note: note,
                            // Callback khi nhấn nút sửa.
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NoteFormScreen(note: note),
                                ),
                              ).then((_) => _loadNotes(query: _searchController.text, priority: _filterPriority));
                            },
                            // Callback khi nhấn nút xóa.
                            onDelete: () => _deleteNote(note.id!),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // FloatingActionButton để thêm ghi chú mới.
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Điều hướng đến màn hình NoteFormScreen để tạo ghi chú mới (không truyền note).
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NoteFormScreen()),
                // Tải lại danh sách sau khi màn hình thêm mới đóng lại.
              ).then((_) => _loadNotes(query: _searchController.text, priority: _filterPriority));
            },
            backgroundColor: Colors.black87, // Màu nền FAB.
            foregroundColor: Colors.white, // Màu icon FAB.
            child: const Icon(Icons.add), // Icon dấu cộng.
            shape: const CircleBorder(), // Hình tròn.
            tooltip: 'Thêm ghi chú mới', // Tooltip
          ),
        );
      },
    );
  }
}