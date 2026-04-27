class JournalEntry {
  final String id;
  final DateTime date;
  final String mood;
  final String content;
  final List<String> tags;

  JournalEntry({
    required this.id,
    required this.date,
    required this.mood,
    required this.content,
    this.tags = const [],
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood,
      'content': content,
      'tags': tags,
    };
  }

  // Create from Map
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] ?? '',
      date: DateTime.parse(map['date']),
      mood: map['mood'] ?? '',
      content: map['content'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  // Copy with method for updates
  JournalEntry copyWith({
    String? id,
    DateTime? date,
    String? mood,
    String? content,
    List<String>? tags,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      content: content ?? this.content,
      tags: tags ?? this.tags,
    );
  }
}
