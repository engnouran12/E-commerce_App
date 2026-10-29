import 'package:e_commerce/core/services/service_locator.dart';
import 'package:e_commerce/features/auth/data/repositories/auth_repository.dart';
import 'package:e_commerce/features/auth/presentation/views/login_view.dart';
import 'package:e_commerce/features/products/presentation/views/product_detail_view.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'root.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

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
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const Root() : const LoginView(),
      routes: {
        '/root': (context) => const Root(),
        '/login': (context) => const LoginView(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/product-details') {
          final productId = settings.arguments;

          if (productId is int) {
            return MaterialPageRoute(
              builder: (context) => ProductDetailView(productId: productId),
              settings: settings,
            );
          }
        }
        return null;
      },
    );
  }
}
