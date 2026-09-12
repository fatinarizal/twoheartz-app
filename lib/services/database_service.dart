import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import '../models/guest_model.dart';
import '../models/song_model.dart';
import '../models/note_model.dart';
import '../models/task_model.dart';

class SupabaseDatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  SupabaseClient get client => _client;

  Future<String> getCurrentWeddingId() async {
    final userId = _client.auth.currentUser!.id;
    final res = await _client.from('profiles').select('wedding_id').eq('id', userId).single();
    return res['wedding_id'] as String;
  }

  Stream<List<TaskModel>> getTasksStream() {
    return _client.from('tasks').stream(primaryKey: ['id']).map(
          (list) => list.map((item) => TaskModel.fromMap(item)).toList(),
    );
  }

  Future<void> addTask(String name, String desc, double goal) async {
    final weddingId = await getCurrentWeddingId();
    await _client.from('tasks').insert({
      'wedding_id': weddingId,
      'task_name': name,
      'description': desc,
      'financial_goal': goal,
    });
  }

  Stream<List<GuestModel>> getGuestsStream() {
    return _client.from('guests').stream(primaryKey: ['id']).map(
          (list) => list.map((item) => GuestModel.fromMap(item)).toList(),
    );
  }

  Future<void> addGuest(String name, String email, String phone) async {
    final weddingId = await getCurrentWeddingId();
    await _client.from('guests').insert({
      'wedding_id': weddingId,
      'guest_name': name,
      'email': email,
      'phone_number': phone,
    });
  }

  Future<void> saveCardDetails(String bride, String groom, String location, String song, String desc) async {
    final weddingId = await getCurrentWeddingId();
    await _client.from('cards').insert({
      'wedding_id': weddingId,
      'bride_name': bride,
      'groom_name': groom,
      'location': location,
      'song_url': song,
      'description': desc,
    });
  }

  Stream<List<SongModel>> getSongsStream() {
    return _client.from('songs').stream(primaryKey: ['id']).map(
          (list) => list.map((item) => SongModel.fromMap(item)).toList(),
    );
  }

  Future<void> addSong(String title, String url) async {
    final weddingId = await getCurrentWeddingId();
    await _client.from('songs').insert({
      'wedding_id': weddingId,
      'title': title,
      'song_url': url,
    });
  }

  Stream<List<NoteModel>> getNotesStream() {
    return _client.from('kahwin_notes').stream(primaryKey: ['id']).map(
          (list) => list.map((item) => NoteModel.fromMap(item)).toList(),
    );
  }

  Future<void> addNote(String title, String contents) async {
    final weddingId = await getCurrentWeddingId();
    await _client.from('kahwin_notes').insert({
      'wedding_id': weddingId,
      'title': title,
      'contents': contents,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<String> fetchInviteCode() async {
    final weddingId = await getCurrentWeddingId();
    final res = await _client.from('weddings').select('invite_code').eq('id', weddingId).single();
    return res['invite_code'] as String;
  }

  Future<String> bindPartner(String code) async {
    final response = await _client.rpc('bind_partner_account', params: {'target_invite_code': code});
    return response['message'] as String;
  }
}