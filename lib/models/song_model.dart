class SongModel {
  final String id;
  final String title;
  final String songUrl;

  SongModel({required this.id, required this.title, required this.songUrl});

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      songUrl: map['song_url'] ?? '',
    );
  }
}