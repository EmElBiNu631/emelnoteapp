class Note {
  final String id;
  final String title;
  final String content;
  final int timestamp; // Expecting int

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  factory Note.fromSnapshot(String id, Map<String, dynamic> snapshot) {
    int ts;
    var tsFromDb = snapshot['timestamp'];
    if (tsFromDb is int) {
      ts = tsFromDb;
    } else if (tsFromDb is String) {
      ts = int.tryParse(tsFromDb) ?? 0; // fallback 0 if parse fails
    } else {
      ts = 0;
    }

    return Note(
      id: id,
      title: snapshot['title'] ?? '',
      content: snapshot['content'] ?? '',
      timestamp: ts,
    );
  }
}
