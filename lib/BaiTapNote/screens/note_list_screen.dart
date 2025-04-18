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
  bool _isGridView = false;
  int? _filterPriority;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes({String? query, int? priority}) async {
    try {
      List<Note> fetchedNotes;
      if (query != null && query.isNotEmpty) {
        fetchedNotes = await NoteDatabaseHelper.instance.searchNotes(query);
      } else if (priority != null) {
        fetchedNotes = await NoteDatabaseHelper.instance.getNotesByPriority(priority);
      } else {
        fetchedNotes = await NoteDatabaseHelper.instance.getAllNotes();
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

  Future<void> _deleteNote(int id) async {
    try {
      await NoteDatabaseHelper.instance.deleteNote(id);
      _loadNotes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa ghi chú: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define styling constants to match the first version
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
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view, color: Colors.white),
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
            icon: const Icon(Icons.filter_list, color: Colors.white),
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
              ),
              style: const TextStyle(color: Colors.black87),
              onChanged: (value) {
                _loadNotes(query: value);
              },
            ),
          ),
          // Danh sách ghi chú
          Expanded(
            child: _notes.isEmpty
                ? const Center(child: Text('Chưa có ghi chú nào'))
                : _isGridView
                ? GridView.builder(
              padding: const EdgeInsets.all(sectionPadding),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                mainAxisSpacing: itemSpacing,
                crossAxisSpacing: itemSpacing,
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
              padding: const EdgeInsets.all(sectionPadding),
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
                    padding: const EdgeInsets.symmetric(vertical: itemSpacing / 2),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteFormScreen()),
          ).then((_) => _loadNotes());
        },
        backgroundColor: fabColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        shape: const CircleBorder(),
      ),
    );
  }
}