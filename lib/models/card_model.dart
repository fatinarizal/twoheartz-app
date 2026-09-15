class CardModel {
  final String id;
  final String weddingId;
  final String brideName;
  final String groomName;
  final String location;
  final String? songUrl;
  final String designTheme;
  final String? description;

  CardModel({
    required this.id,
    required this.weddingId,
    required this.brideName,
    required this.groomName,
    required this.location,
    this.songUrl,
    this.designTheme = 'Modern Classic',
    this.description,
  });

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'] ?? '',
      weddingId: map['wedding_id'] ?? '',
      brideName: map['bride_name'] ?? '',
      groomName: map['groom_name'] ?? '',
      location: map['location'] ?? '',
      songUrl: map['song_url'],
      designTheme: map['design_theme'] ?? 'Modern Classic',
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bride_name': brideName,
      'groom_name': groomName,
      'location': location,
      'song_url': songUrl,
      'design_theme': designTheme,
      'description': description,
    };
  }
}