import 'package:e_commerce/core/services/service_locator.dart';
import 'package:e_commerce/features/auth/data/repositories/auth_repository.dart';
import 'package:e_commerce/features/auth/presentation/views/login.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/products/presentation/views/products_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register Dio, DioClient, token storage and all services.
  await configureDependencies();

  // Local-cache-first: skip login when a cached session exists.
  final isLoggedIn = await getIt<AuthRepository>().isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce',
      theme: AppTheme.light,
      home: isLoggedIn ? const ProductsView() : const LoginView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
