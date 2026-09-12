class NoteModel {
  final String id;
  final String title;
  final String contents;

  NoteModel({required this.id, required this.title, required this.contents});

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      contents: map['contents'] ?? '',
    );
  }
}