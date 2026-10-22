import 'package:flutter/foundation.dart';

/// A single cached product search query stored in the local SQLite database.
@immutable
class SearchHistoryEntry {
  final int id;
  final String query;
  final DateTime createdAt;

  const SearchHistoryEntry({
    required this.id,
    required this.query,
    required this.createdAt,
  });

  factory SearchHistoryEntry.fromMap(Map<String, Object?> map) {
    return SearchHistoryEntry(
      id: (map['id'] as num?)?.toInt() ?? 0,
      query: map['query']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'query': query,
    'createdAt': createdAt.toIso8601String(),
  };
}
