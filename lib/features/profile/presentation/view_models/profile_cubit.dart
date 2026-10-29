import 'package:e_commerce/core/network/api_exceptions.dart';
import 'package:e_commerce/core/services/service_locator.dart';
import 'package:e_commerce/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'profile_state.dart';

/// Drives the profile screen: loading → success / error.
class ProfileCubit extends Cubit<ProfileState> {
  static const _tag = '[ProfileCubit]';

  ProfileCubit() : super(const ProfileInitial()) {
    debugPrint('$_tag created (state: ProfileInitial)');
  }

  AuthRepository get _repository => getIt<AuthRepository>();

  /// Fetches the authenticated user from the API.
  Future<void> loadProfile() async {
    debugPrint('$_tag loadProfile() called');
    emit(const ProfileLoading());
    debugPrint('$_tag state -> ProfileLoading');

    try {
      final user = await _repository.fetchCurrentUser();
      debugPrint(
        '$_tag api returned user id=${user.id}, username=${user.username}, '
        'phone=${user.phone}, image=${user.image}',
      );
      emit(ProfileSuccess(user));
      debugPrint('$_tag state -> ProfileSuccess (${user.fullName})');
    } on ApiException catch (error, stackTrace) {
      debugPrint('$_tag ApiException: ${error.message}');
      debugPrintStack(stackTrace: stackTrace, label: _tag);
      emit(ProfileError(error.message));
      debugPrint('$_tag state -> ProfileError (${error.message})');
    } catch (error, stackTrace) {
      debugPrint('$_tag unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace, label: _tag);
      emit(const ProfileError('Something went wrong. Please try again.'));
      debugPrint('$_tag state -> ProfileError (unexpected error)');
    }
  }

  /// Retries the load after a failure.
  Future<void> retry() {
    debugPrint('$_tag retry() called');
    return loadProfile();
  }
}
