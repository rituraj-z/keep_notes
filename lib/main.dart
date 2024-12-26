import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color.fromARGB(255, 0, 3, 151),
          brightness: Brightness.dark),
      title: 'Notes App',
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  void _fetchNotes() async {
    final notes = await _dbHelper.getNotes();
    setState(() {
      _notes = notes;
    });
  }

  void _addOrUpdateNote({Map<String, dynamic>? note}) {
    final titleController = TextEditingController(text: note?['title']);
    final contentController = TextEditingController(text: note?['content']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note == null ? 'Add Note' : 'Update Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(
              height: 15,
            ),
            TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (note == null) {
                // Create new note
                await _dbHelper.insertNote({
                  'title': titleController.text,
                  'content': contentController.text,
                });
              } else {
                // Update existing note
                await _dbHelper.updateNote({
                  'id': note['id'],
                  'title': titleController.text,
                  'content': contentController.text,
                });
              }
              Navigator.of(context).pop();
              _fetchNotes();
            },
            child: Text(note == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteNote(int id) async {
    await _dbHelper.deleteNote(id);
    _fetchNotes();
  }

  void _navigateToDetail(Map<String, dynamic> note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailPage(note: note),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return ListTile(
            title: Text(note['title']),
            subtitle: Text(note['content']),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteNote(note['id']),
            ),
            onTap: () =>
                _navigateToDetail(note), // Navigate to detail page on tap
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateNote(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteDetailPage extends StatelessWidget {
  final Map<String, dynamic> note;
  const NoteDetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(note['title'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note['content'],
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
