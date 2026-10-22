import '../datasources/search_history_local_datasource.dart';
import '../models/search_history_model.dart';
import 'search_history_repository.dart';

/// SQLite-backed [SearchHistoryRepository].
class SearchHistoryRepositoryImpl implements SearchHistoryRepository {
  final SearchHistoryLocalDatasource _datasource;

  SearchHistoryRepositoryImpl({
    required SearchHistoryLocalDatasource datasource,
  }) : _datasource = datasource;

  @override
  Future<List<SearchHistoryEntry>> getHistory({int limit = 20}) {
    return _datasource.getHistory(limit: limit);
  }

  @override
  Future<void> saveQuery(String query) {
    return _datasource.saveQuery(query);
  }

  @override
  Future<void> deleteEntry(int id) {
    return _datasource.deleteEntry(id);
  }

  @override
  Future<void> clearHistory() {
    return _datasource.clearHistory();
  }
}
