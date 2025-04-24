// note_list_screen.dart
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:flutter/material.dart';
import '../database/note_database_helper.dart';
import '../models/note.dart';
import '../widgets/note_item.dart';
import 'note_form_screen.dart';
import 'note_detail_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({Key? key}) : super(key: key);

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Note> _notes = [];
  bool _isLoading = false; // Thêm biến trạng thái loading
  bool _isGridView = false;
  int? _filterPriority;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Không cần kiểm tra user ở đây nữa vì Wrapper đã đảm bảo
    _loadNotes();
  }

  Future<void> _loadNotes({String? query, int? priority}) async {
    setState(() {
      _isLoading = true; // Bắt đầu loading
    });
    try {
      List<Note> fetchedNotes;
      // Sử dụng NoteDatabaseHelper.instance đã được khởi tạo
      if (query != null && query.isNotEmpty) {
        fetchedNotes = await NoteDatabaseHelper.instance.searchNotes(query);
      } else if (priority != null) {
        fetchedNotes = await NoteDatabaseHelper.instance.getNotesByPriority(
          priority,
        );
      } else {
        fetchedNotes = await NoteDatabaseHelper.instance.getAllNotes();
      }

      // Kiểm tra widget còn tồn tại trước khi gọi setState
      if (mounted) {
        setState(() {
          _notes = fetchedNotes;
        });
      }
    } catch (e) {
      print('Lỗi khi tải ghi chú: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải ghi chú: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Kết thúc loading
        });
      }
    }
  }

  Future<void> _deleteNote(int id) async {
    // if (FirebaseAuth.instance.currentUser == null) return;
    try {
      await NoteDatabaseHelper.instance.deleteNote(id);
      _loadNotes(
        query: _searchController.text,
        priority: _filterPriority,
      ); // Tải lại danh sách sau khi xóa
    } catch (e) {
      print('Lỗi khi xóa ghi chú: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa ghi chú: $e')));
      }
    }
  }

  // Hàm xử lý đăng xuất
  Future<void> _logout() async {
    try {
      await NoteDatabaseHelper.closeDatabase(); // Đóng DB của người dùng hiện tại
      await FirebaseAuth.instance.signOut(); // Đăng xuất khỏi Firebase
      // StreamBuilder trong AuthenticationWrapper sẽ tự động điều hướng về LoginScreen
      // Không cần Navigator.pushReplacement ở đây
      print("User logged out successfully.");
    } catch (e) {
      print("Error during logout: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi đăng xuất: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double sectionPadding = 10.0;
    const double itemSpacing = 10.0;
    const Color appBarColor = Color(0xFF3A3A3A);
    const Color fabColor = Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi chú', style: TextStyle(color: Colors.white)),
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _filterPriority = null;
              _searchController.clear();
              _loadNotes();
            },
          ),
          IconButton(
            icon: Icon(
              _isGridView ? Icons.list : Icons.grid_view,
              color: Colors.white,
            ),
            onPressed: () {
              if (mounted) {
                setState(() {
                  _isGridView = !_isGridView;
                });
              }
            },
          ),
          PopupMenuButton<int>(
            onSelected: (value) {
              _filterPriority = value;
              _loadNotes(priority: value); // Chỉ cần gọi loadNotes
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem(value: 1, child: Text('Ưu tiên: Thấp')),
                  PopupMenuItem(value: 2, child: Text('Ưu tiên: Trung bình')),
                  PopupMenuItem(value: 3, child: Text('Ưu tiên: Cao')),
                ],
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
          // Nút Logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Đăng xuất',
            onPressed: _logout, // Gọi hàm đăng xuất
          ),
        ],
      ),
      body: Column(
        children: [
          // Ô tìm kiếm
          Padding(
            padding: const EdgeInsets.all(sectionPadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                ),
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                // Thêm nút xóa tìm kiếm
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _loadNotes(
                              priority: _filterPriority,
                            ); // Tải lại khi xóa search
                          },
                        )
                        : null,
              ),
              style: const TextStyle(color: Colors.black87),
              onChanged: (value) {
                _loadNotes(query: value, priority: _filterPriority);
              },
            ),
          ),
          // Danh sách ghi chú
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(),
                    ) // Hiển thị loading
                    : _notes.isEmpty
                    ? const Center(child: Text('Chưa có ghi chú nào'))
                    : RefreshIndicator(
                      // Cho phép kéo để làm mới
                      onRefresh:
                          () => _loadNotes(
                            query: _searchController.text,
                            priority: _filterPriority,
                          ),
                      child:
                          _isGridView
                              ? GridView.builder(
                                padding: const EdgeInsets.all(sectionPadding),
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 250,
                                      mainAxisSpacing: itemSpacing,
                                      crossAxisSpacing: itemSpacing,
                                      childAspectRatio:
                                          0.85, // Điều chỉnh tỷ lệ nếu cần
                                    ),
                                itemCount: _notes.length,
                                itemBuilder: (context, index) {
                                  final note = _notes[index];
                                  return GestureDetector(
                                    onTap: () async {
                                      // Đánh dấu async
                                      // Chờ kết quả trả về từ màn hình chi tiết/form
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  NoteDetailScreen(note: note),
                                        ),
                                      );
                                      // Tải lại danh sách khi quay lại
                                      _loadNotes(
                                        query: _searchController.text,
                                        priority: _filterPriority,
                                      );
                                    },
                                    child: NoteItem(
                                      note: note,
                                      onEdit: () async {
                                        // Đánh dấu async
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    NoteFormScreen(note: note),
                                          ),
                                        );
                                        _loadNotes(
                                          query: _searchController.text,
                                          priority: _filterPriority,
                                        ); // Tải lại
                                      },
                                      onDelete: () => _deleteNote(note.id!),
                                    ),
                                  );
                                },
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.all(sectionPadding),
                                itemCount: _notes.length,
                                itemBuilder: (context, index) {
                                  final note = _notes[index];
                                  return GestureDetector(
                                    onTap: () async {
                                      // Đánh dấu async
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  NoteDetailScreen(note: note),
                                        ),
                                      );
                                      _loadNotes(
                                        query: _searchController.text,
                                        priority: _filterPriority,
                                      ); // Tải lại
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: itemSpacing / 2,
                                      ),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minHeight: 120,
                                        ), // Giảm chiều cao tối thiểu một chút
                                        child: NoteItem(
                                          note: note,
                                          onEdit: () async {
                                            // Đánh dấu async
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => NoteFormScreen(
                                                      note: note,
                                                    ),
                                              ),
                                            );
                                            _loadNotes(
                                              query: _searchController.text,
                                              priority: _filterPriority,
                                            ); // Tải lại
                                          },
                                          onDelete: () => _deleteNote(note.id!),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Đánh dấu async
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteFormScreen()),
          );
          _loadNotes(
            query: _searchController.text,
            priority: _filterPriority,
          ); // Tải lại
        },
        backgroundColor: fabColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        shape: const CircleBorder(),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
