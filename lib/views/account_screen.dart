import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/database_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _dbService = SupabaseDatabaseService();
  final _inviteCodeController = TextEditingController();
  String? _myInviteCode;

  @override
  void initState() {
    super.initState();
    _fetchInviteCode();
  }

  Future<void> _fetchInviteCode() async {
    final code = await _dbService.fetchInviteCode();
    setState(() {
      _myInviteCode = code;
    });
  }

  Future<void> _bindPartner() async {
    final message = await _dbService.bindPartner(_inviteCodeController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Logged in as: ${Supabase.instance.client.auth.currentUser?.email}'),
          const SizedBox(height: 20),
          const Text('Your Partner Invite Code:', style: TextStyle(fontWeight: FontWeight.bold)),
          SelectableText(
            _myInviteCode ?? 'Loading code...',
            style: const TextStyle(
              fontSize: 24,
              color: Color(0xFFE91E63),
              fontWeight: FontWeight.bold,
            ),
          ), // <-- Changed semicolon to comma
          const SizedBox(height: 30),
          const Text('Bind Account with Spouse:', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: _inviteCodeController,
            decoration: const InputDecoration(labelText: 'Enter Partner Invite Code'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _bindPartner,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
            ),
            child: const Text('Link Partner Account'),
          ),
        ],
      ),
    );
  }
}