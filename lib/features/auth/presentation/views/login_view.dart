import 'package:e_commerce/core/services/service_locator.dart';
import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/theme/app_spacing.dart';
import 'package:e_commerce/core/responsive/responsive_context.dart';
import 'package:e_commerce/core/widgets/app_button.dart';
import 'package:e_commerce/core/widgets/app_text_field.dart';
import 'package:e_commerce/features/auth/data/repositories/auth_repository.dart';
import 'package:e_commerce/features/auth/presentation/view_model/login_cubit.dart';
import 'package:e_commerce/features/auth/presentation/view_model/login_state.dart';
import 'package:e_commerce/features/products/presentation/views/products_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(getIt<AuthRepository>()),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProductsView()),
            );
          }

          if (state is LoginError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final bool isLoading = state is LoginLoading;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsive(
                      mobile: context.spacing.md,
                      tablet: context.spacing.xxl,
                      desktop: context.spacing.xxl,
                    ),
                    vertical: context.spacing.lg,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: AppRadius.lg,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ),
                        SizedBox(height: context.spacing.md),

                        Text(
                          'Welcome to E-Comm',
                          style: context.textStyles.heading3,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.spacing.xs),

                        Text(
                          'Sign in to continue',
                          style: context.textStyles.body,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.spacing.xl),

                        AppTextField(
                          controller: _emailController,
                          hintText: 'Your Email',
                          prefixIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: context.spacing.sm),

                        AppTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          onSuffixPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          textInputAction: TextInputAction.done,
                        ),
                        SizedBox(height: context.spacing.md),

                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              // Navigate or trigger forgot password.
                            },
                            child: Text(
                              'Forgot Password?',
                              style: context.textStyles.title.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: context.spacing.md),

                        AppButton(
                          text: 'Sign In',
                          isLoading: isLoading,
                          onPressed: isLoading
                              ? null
                              : () {
                            FocusScope.of(context).unfocus();

                            context.read<LoginCubit>().login(
                              username: _emailController.text.trim(),
                              password: _passwordController.text,
                            );
                          },
                        ),
                        SizedBox(height: context.spacing.lg),

                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: AppColors.border,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.spacing.sm,
                              ),
                              child: Text(
                                'OR',
                                style: context.textStyles.title.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: AppColors.border,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.spacing.lg),

                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: context.textStyles.body,
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigate to register view.
                              },
                              child: Text(
                                'Register',
                                style: context.textStyles.title.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}