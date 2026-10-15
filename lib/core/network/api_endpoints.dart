class ApiEndpoints {
  ApiEndpoints._();

  // Base URL
  static const String baseUrl = 'https://dummyjson.com/';

  // Authentication Endpoints
  static const String login = 'auth/login';
  static const String refresh = 'auth/refresh';
  static const String me = 'auth/me';

  // Products Endpoints
  static const String products = 'products';
  static const String categories = 'products/categories';

  // Users & Carts
  static const String users = 'users';
  static const String carts = 'carts';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}
