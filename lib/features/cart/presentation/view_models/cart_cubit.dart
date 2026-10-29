import 'package:e_commerce/core/services/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../data/repositories/cart_repository.dart';
import 'cart_state.dart';

/// Drives the cart state machine: loading → success / empty / error.
class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartInitial());

  CartRepository get _repository => getIt<CartRepository>();

  /// Loads all carts.
  Future<void> loadCarts({int limit = 30, int skip = 0}) async {
    emit(const CartLoading());

    try {
      final response = await _repository.getCarts(limit: limit, skip: skip);

      if (response.carts.isEmpty) {
        emit(const CartEmpty());
      } else {
        emit(CartSuccess(carts: response.carts));
      }
    } on ApiException catch (error) {
      emit(CartError(error.message));
    } catch (_) {
      emit(const CartError('Something went wrong. Please try again.'));
    }
  }

  /// Loads carts for a specific user.
  Future<void> loadCartsByUserId(int userId) async {
    emit(const CartLoading());

    try {
      final response = await _repository.getCartsByUserId(userId);

      if (response.carts.isEmpty) {
        emit(const CartEmpty());
      } else {
        emit(CartSuccess(carts: response.carts));
      }
    } on ApiException catch (error) {
      emit(CartError(error.message));
    } catch (_) {
      emit(const CartError('Something went wrong. Please try again.'));
    }
  }

  /// Retries the load after a failure.
  Future<void> retry() => loadCarts();
}
