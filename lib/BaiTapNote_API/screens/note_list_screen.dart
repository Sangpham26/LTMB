import 'package:app_02/BaiTapNote_API/api/NoteAPIService.dart';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../widgets/note_item.dart';
import 'note_form_screen.dart';
import 'note_detail_screen.dart';
import '../api/NoteAPIService.dart'; // Gọi API thay vì SQLite

// Màn hình hiển thị danh sách các ghi chú
class NoteListScreen extends StatefulWidget {
  const NoteListScreen({Key? key}) : super(key: key);

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  // Danh sách ghi chú
  List<Note> _notes = [];

  // Chế độ hiển thị (grid/list)
  bool _isGridView = false;

  // Bộ lọc độ ưu tiên
  int? _filterPriority;

  // Bộ điều khiển tìm kiếm
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes(); // Tải dữ liệu khi mở màn hình
  }

  // Hàm tải danh sách ghi chú từ API
  Future<void> _loadNotes({String? query, int? priority}) async {
    try {
      List<Note> fetchedNotes;
      if (query != null && query.isNotEmpty) {
        fetchedNotes = await NoteAPIService.instance.searchNotes(query);
      } else if (priority != null) {
        fetchedNotes = await NoteAPIService.instance.getNotesByPriority(priority);
      } else {
        fetchedNotes = await NoteAPIService.instance.getAllNotes();
      }

      setState(() {
        _notes = fetchedNotes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải ghi chú: $e')),
      );
    }
  }

  // Hàm xóa ghi chú
  Future<void> _deleteNote(int id) async {
    try {
      await NoteAPIService.instance.deleteNote(id);
      _loadNotes(); // Cập nhật danh sách sau khi xóa
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa ghi chú: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi chú', style: TextStyle(color: Colors.white)),
        backgroundColor: 	Color(0xFF3A3A3A),

        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _filterPriority = null;
              _searchController.clear();
              _loadNotes(); // Làm mới danh sách
            },
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          PopupMenuButton<int>(
            onSelected: (value) {
              _filterPriority = value;
              _loadNotes(priority: value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 1, child: Text('Ưu tiên: Thấp')),
              PopupMenuItem(value: 2, child: Text('Ưu tiên: Trung bình')),
              PopupMenuItem(value: 3, child: Text('Ưu tiên: Cao')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),

      body: Column(
        children: [
          // Ô tìm kiếm
          Padding(
            padding: const EdgeInsets.all(10.0),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onChanged: (value) {
                _loadNotes(query: value); // Gọi API tìm kiếm
              },
            ),
          ),

          // Danh sách ghi chú
          Expanded(
            child: _notes.isEmpty
                ? const Center(child: Text('Chưa có ghi chú nào'))
                : _isGridView
                ? GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250, // mỗi item có chiều rộng tối đa là 250
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteDetailScreen(note: note),
                      ),
                    );
                  },
                  child: NoteItem(
                    note: note,
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteFormScreen(note: note),
                        ),
                      ).then((_) => _loadNotes());
                    },
                    onDelete: () => _deleteNote(note.id!),
                  ),
                );
              },
            )
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteDetailScreen(note: note),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 150),
                      child: NoteItem(
                        note: note,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteFormScreen(note: note),
                            ),
                          ).then((_) => _loadNotes());
                        },
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

      // Nút thêm ghi chú mới
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteFormScreen()),
          ).then((_) => _loadNotes());
        },
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        shape: const CircleBorder(),
      ),
    );
  }
}
