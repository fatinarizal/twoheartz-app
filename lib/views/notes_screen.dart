import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/database_service.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = SupabaseDatabaseService();
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE91E63),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('New Kahwin Note'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: contentCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Contents')),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  await dbService.addNote(titleCtrl.text, contentCtrl.text);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save Note'),
              ),
            ],
          ),
        ),
        child: const Icon(Icons.note_add, color: Colors.white),
      ),
      body: StreamBuilder<List<NoteModel>>(
        stream: dbService.getNotesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final notes = snapshot.data!;
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(note.contents),
                ),
              );
            },
          );
        },
      ),
    );
  }
}