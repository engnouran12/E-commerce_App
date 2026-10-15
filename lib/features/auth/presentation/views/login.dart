import 'package:e_commerce/core/network/api_exceptions.dart';
import 'package:e_commerce/core/services/service_locator.dart';
import 'package:e_commerce/features/auth/data/repositories/auth_repository.dart';
import 'package:e_commerce/features/products/presentation/views/products_view.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final AuthRepository _authRepository = getIt<AuthRepository>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      // Repository logs in via API and syncs tokens to the local cache.
      await _authRepository.login(
        username: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ProductsView()),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // App Branding / Logo Icon
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadius.lg,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
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

                  // Header Texts
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

                  // Email Text Field
                  AppTextField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$', caseSensitive: false).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    controller: _emailController,
                    hintText: 'Your Email',
                                    prefixIcon: Icons.mail_outline,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: context.spacing.sm),
                                    
                  // Password Text Field
                  AppTextField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$', caseSensitive: false).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
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
                                    
                  // Forgot Password Link
                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        // Navigate or trigger forgot password
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
                                    
                  // Sign In Button
                  AppButton(
                                    text: 'Sign In',
                                    onPressed: _onSignIn,
                                    isLoading: _isLoading,
                  ),
                  SizedBox(height: context.spacing.lg),
                                    
                  // OR Divider
                  Row(
                                    children: [
                                      const Expanded(
                                        child: Divider(color: AppColors.border, thickness: 1),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: context.spacing.sm),
                                        child: Text(
                                          'OR',
                                          style: context.textStyles.title.copyWith(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        child: Divider(color: AppColors.border, thickness: 1),
                                      ),
                                    ],
                  ),
                  SizedBox(height: context.spacing.lg),
                                    
                  // Register Prompt
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
                                          // Navigate to register view
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
         ]   ),
              ),
        ),
      ),
      )
    );
  }
}
