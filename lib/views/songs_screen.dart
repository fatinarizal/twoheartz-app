import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/song_model.dart';
import '../services/database_service.dart';

class SongsScreen extends StatelessWidget {
  const SongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = SupabaseDatabaseService();
    final titleController = TextEditingController();
    final urlController = TextEditingController();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE91E63),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Save Song Link'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Song Title')),
                TextField(controller: urlController, decoration: const InputDecoration(labelText: 'URL (Spotify/YouTube)')),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  await dbService.addSong(titleController.text, urlController.text);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
        child: const Icon(Icons.music_note, color: Colors.white),
      ),
      body: StreamBuilder<List<SongModel>>(
        stream: dbService.getSongsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final songs = snapshot.data!;
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return ListTile(
                leading: const Icon(Icons.play_circle_fill, color: Color(0xFFE91E63)),
                title: Text(song.title),
                subtitle: Text(song.songUrl),
                onTap: () async {
                  final Uri uri = Uri.parse(song.songUrl);
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
              );
            },
          );
        },
      ),
    );
  }
}