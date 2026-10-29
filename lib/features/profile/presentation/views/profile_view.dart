import 'package:e_commerce/core/responsive/responsive_context.dart';
import 'package:e_commerce/core/services/service_locator.dart';
import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/widgets/app_button.dart';
import 'package:e_commerce/core/widgets/cash_img.dart';
import 'package:e_commerce/features/auth/data/models/user_model.dart';
import 'package:e_commerce/features/profile/presentation/view_models/profile_cubit.dart';
import 'package:e_commerce/features/profile/presentation/view_models/profile_state.dart';
import 'package:e_commerce/features/profile/presentation/views/widgets/profile_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..loadProfile(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return switch (state) {
              ProfileInitial() || ProfileLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              ProfileError(:final message) => _ProfileErrorView(
                  message: message,
                  onRetry: () => context.read<ProfileCubit>().retry(),
                ),
              ProfileSuccess(:final user) => _ProfileContent(user: user),
            };
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.spacing.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ClipOval(
                  child: AppNetworkImage(
                    url: user.image,
                    width: context.responsive(mobile: 96, tablet: 112),
                    height: context.responsive(mobile: 96, tablet: 112),
                  ),
                ),
              ),
              SizedBox(height: context.spacing.md),
              Text(
                user.fullName,
                textAlign: TextAlign.center,
                style: context.textStyles.heading4,
              ),
              SizedBox(height: context.spacing.xs),
              Text(
                '@${user.username}',
                textAlign: TextAlign.center,
                style: context.textStyles.body,
              ),
              SizedBox(height: context.spacing.xl),
              ProfileLine(
                title: 'Email',
                subtitle: user.email.isEmpty ? '—' : user.email,
                icon: Icons.mail_outline,
              ),
              SizedBox(height: context.spacing.sm),
              ProfileLine(
                title: 'Phone',
                subtitle: (user.phone == null || user.phone!.isEmpty)
                    ? '—'
                    : user.phone!,
                icon: Icons.phone_outlined,
              ),
              SizedBox(height: context.spacing.sm),
              ProfileLine(
                title: 'User ID',
                subtitle: user.id.toString(),
                icon: Icons.badge_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  const _ProfileErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.discount,
              size: 48,
            ),
            SizedBox(height: context.spacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textStyles.body,
            ),
            SizedBox(height: context.spacing.md),
            AppButton(
              text: 'Retry',
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
