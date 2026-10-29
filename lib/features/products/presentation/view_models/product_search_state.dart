import '../../data/models/product_model.dart';
import '../../data/models/search_history_model.dart';

/// States emitted by [ProductSearchCubit].
sealed class ProductSearchState {
  const ProductSearchState();
}

/// No search has been performed yet. [history] holds cached queries.
class ProductSearchInitial extends ProductSearchState {
  final List<SearchHistoryEntry> history;

  const ProductSearchInitial({this.history = const []});
}

/// A search request is in progress.
class ProductSearchLoading extends ProductSearchState {
  const ProductSearchLoading();
}

/// The search returned at least one product.
class ProductSearchSuccess extends ProductSearchState {
  final String query;
  final List<ProductModel> products;

  const ProductSearchSuccess({required this.query, required this.products});
}

/// The search returned no products for [query].
class ProductSearchEmpty extends ProductSearchState {
  final String query;

  const ProductSearchEmpty(this.query);
}

/// The search failed. [message] is safe to show to the user.
class ProductSearchError extends ProductSearchState {
  final String message;

  const ProductSearchError(this.message);
}
