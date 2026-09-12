import 'package:flutter/material.dart';
import '../models/guest_model.dart';
import '../services/database_service.dart';
import '../services/messaging_service.dart';

class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({super.key});

  @override
  State<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  final _dbService = SupabaseDatabaseService();
  final _guestName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  Future<void> _addGuest() async {
    await _dbService.addGuest(_guestName.text, _email.text, _phone.text);
    _guestName.clear();
    _email.clear();
    _phone.clear();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE91E63),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Add Guest'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _guestName, decoration: const InputDecoration(labelText: 'Guest Name')),
                TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
                TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone Number (e.g. 60123456789)')),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(onPressed: _addGuest, child: const Text('Save Guest')),
            ],
          ),
        ),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: StreamBuilder<List<GuestModel>>(
        stream: _dbService.getGuestsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final guests = snapshot.data!;
          return ListView.builder(
            itemCount: guests.length,
            itemBuilder: (context, index) {
              final g = guests[index];
              return ListTile(
                title: Text(g.guestName),
                subtitle: Text('RSVP: ${g.rsvpStatus} | ${g.email}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.email, color: Colors.blue), onPressed: () => InvitationMessagingService.sendEmailInvitation(g)),
                    IconButton(icon: const Icon(Icons.chat, color: Colors.green), onPressed: () => InvitationMessagingService.sendWhatsAppInvitation(g)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}