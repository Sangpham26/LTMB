import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note.dart';
import '../widgets/note_item.dart';
import 'note_form_screen.dart';
import 'note_detail_screen.dart';
import '../service/NoteService.dart';
import 'login_screen.dart';

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
        fetchedNotes = await NoteService.instance.searchNotes(query);
      } else if (priority != null) {
        fetchedNotes = await NoteService.instance.getNotesByPriority(priority);
      } else {
        fetchedNotes = await NoteService.instance.getAllNotes();
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

  Future<void> _deleteNote(String id) async {
    try {
      await NoteService.instance.deleteNote(id);
      _loadNotes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa ghi chú: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Ghi chú', style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF3A3A3A),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  _filterPriority = null;
                  _searchController.clear();
                  _loadNotes();
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
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
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
                    _loadNotes(query: value);
                  },
                ),
              ),
              Expanded(
                child: _notes.isEmpty
                    ? const Center(child: Text('Chưa có ghi chú nào'))
                    : _isGridView
                    ? GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
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
      },
    );
  }
}