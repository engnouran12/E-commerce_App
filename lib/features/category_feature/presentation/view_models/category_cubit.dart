import 'package:e_commerce/core/services/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../data/repositories/category_repository.dart';
import 'category_state.dart';

/// Drives the categories list state machine: loading → success / empty / error.
class CategoryCubit extends Cubit<CategoryState> {
  static const _tag = '[CategoryCubit]';

  CategoryCubit() : super(const CategoryInitial()) {
    debugPrint('$_tag created (state: CategoryInitial)');
  }

  CategoryRepository get _repository => getIt<CategoryRepository>();

  /// Loads all categories.
  Future<void> loadCategories() async {
    debugPrint('$_tag loadCategories() called');
    emit(const CategoryLoading());
    debugPrint('$_tag state -> CategoryLoading');

    try {
      final categories = await _repository.getCategories();
      debugPrint('$_tag repository returned ${categories.length} categories');

      if (categories.isEmpty) {
        emit(const CategoryEmpty());
        debugPrint('$_tag state -> CategoryEmpty');
      } else {
        emit(CategorySuccess(categories));
        debugPrint(
          '$_tag state -> CategorySuccess (${categories.length} categories)',
        );
      }
    } on ApiException catch (error, stackTrace) {
      debugPrint('$_tag ApiException: ${error.message}');
      debugPrintStack(stackTrace: stackTrace, label: _tag);
      emit(CategoryError(error.message));
      debugPrint('$_tag state -> CategoryError (${error.message})');
    } catch (error, stackTrace) {
      debugPrint('$_tag unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace, label: _tag);
      emit(const CategoryError('Something went wrong. Please try again.'));
      debugPrint('$_tag state -> CategoryError (unexpected error)');
    }
  }

  /// Retries the load after a failure.
  Future<void> retry() {
    debugPrint('$_tag retry() called');
    return loadCategories();
  }
}
