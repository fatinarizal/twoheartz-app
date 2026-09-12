import 'package:flutter/material.dart';
import '../services/database_service.dart';

class CardGenScreen extends StatefulWidget {
  const CardGenScreen({super.key});

  @override
  State<CardGenScreen> createState() => _CardGenScreenState();
}

class _CardGenScreenState extends State<CardGenScreen> {
  final _dbService = SupabaseDatabaseService();
  final _bride = TextEditingController();
  final _groom = TextEditingController();
  final _location = TextEditingController();
  final _song = TextEditingController();
  final _desc = TextEditingController();

  Future<void> _saveCardPrompt() async {
    await _dbService.saveCardDetails(_bride.text, _groom.text, _location.text, _song.text, _desc.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI Card Metadata Saved & Generated!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI Digital Invitation Card Generator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(controller: _bride, decoration: const InputDecoration(labelText: 'Bride Name')),
          TextField(controller: _groom, decoration: const InputDecoration(labelText: 'Groom Name')),
          TextField(controller: _location, decoration: const InputDecoration(labelText: 'Event Location')),
          TextField(controller: _song, decoration: const InputDecoration(labelText: 'Background Song Link')),
          TextField(controller: _desc, maxLines: 3, decoration: const InputDecoration(labelText: 'Custom Descriptions / Prompts')),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _saveCardPrompt,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE91E63), foregroundColor: Colors.white),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Card'),
          )
        ],
      ),
    );
  }
}