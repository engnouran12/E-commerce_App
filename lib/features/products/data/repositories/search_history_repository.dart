import '../models/search_history_model.dart';

/// Local persistence contract for cached product search queries.
abstract class SearchHistoryRepository {
  Future<List<SearchHistoryEntry>> getHistory({int limit});

  Future<void> saveQuery(String query);

  Future<void> deleteEntry(int id);

  Future<void> clearHistory();
}
