import 'package:e_commerce/core/services/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../data/repositories/products_repository.dart';
import '../../data/repositories/search_history_repository.dart';
import 'product_search_state.dart';

/// Drives the product search screen: initial → loading → success / empty / error.
///
/// Successful queries are cached in the local SQLite history and surfaced on
/// the initial state.
class ProductSearchCubit extends Cubit<ProductSearchState> {
  ProductSearchCubit() : super(const ProductSearchInitial()) {
    _refreshHistory();
  }

  ProductsRepository get _repository => getIt<ProductsRepository>();
  SearchHistoryRepository get _historyRepository =>
      getIt<SearchHistoryRepository>();

  String _query = '';
  int _requestId = 0;

  /// Searches products matching [query].
  ///
  /// An empty query resets the screen to its initial state.
  Future<void> search(String query) async {
    final trimmed = query.trim();
    _query = trimmed;

    if (trimmed.isEmpty) {
      _requestId++;
      emit(const ProductSearchInitial());
      await _refreshHistory();
      return;
    }

    final requestId = ++_requestId;
    emit(const ProductSearchLoading());

    try {
      final products = await _repository.searchProducts(query: trimmed);
      await _saveToHistory(trimmed);
      if (requestId != _requestId) return;

      if (products.isEmpty) {
        emit(ProductSearchEmpty(trimmed));
      } else {
        emit(ProductSearchSuccess(query: trimmed, products: products));
      }
    } on ApiException catch (error) {
      if (requestId != _requestId) return;
      emit(ProductSearchError(error.message));
    } catch (_) {
      if (requestId != _requestId) return;
      emit(const ProductSearchError('Something went wrong. Please try again.'));
    }
  }

  /// Re-runs the latest search after a failure.
  Future<void> retry() => search(_query);

  /// Deletes a single cached query.
  Future<void> deleteHistoryEntry(int id) async {
    try {
      await _historyRepository.deleteEntry(id);
    } catch (_) {
      return;
    }
    await _refreshHistory();
  }

  /// Removes every cached query.
  Future<void> clearHistory() async {
    try {
      await _historyRepository.clearHistory();
    } catch (_) {
      return;
    }
    emit(const ProductSearchInitial());
  }

  Future<void> _saveToHistory(String query) async {
    try {
      await _historyRepository.saveQuery(query);
    } catch (_) {
      // A failed cache write must not break the search result.
    }
  }

  Future<void> _refreshHistory() async {
    try {
      final history = await _historyRepository.getHistory();
      if (isClosed) return;
      if (state is ProductSearchInitial) {
        emit(ProductSearchInitial(history: history));
      }
    } catch (_) {
      // Keep the current state if the local database is unavailable.
    }
  }
}
