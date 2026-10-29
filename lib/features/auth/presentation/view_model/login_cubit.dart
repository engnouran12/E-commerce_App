import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/core/network/api_exceptions.dart';
import 'package:e_commerce/features/auth/data/repositories/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit(this._authRepository) : super(const LoginInitial());

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(const LoginLoading());

    try {
      await _authRepository.login(username: username, password: password);

      emit(const LoginSuccess());
    } on ApiException catch (error) {
      emit(LoginError(error.message));
    } catch (_) {
      emit(const LoginError('Something went wrong. Please try again.'));
    }
  }
}