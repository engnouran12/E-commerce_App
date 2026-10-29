import 'package:e_commerce/features/auth/data/models/user_model.dart';

sealed class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileSuccess extends ProfileState {
  final UserModel user;

  const ProfileSuccess(this.user);
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);
}
