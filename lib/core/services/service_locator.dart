import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasource/loginservice.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/cart/data/datasources/cart_api_datasource.dart';
import '../../features/cart/data/repositories/cart_repository.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/category_feature/data/datasources/category_api_datasource.dart';
import '../../features/category_feature/data/repositories/category_repository.dart';
import '../../features/category_feature/data/repositories/category_repository_impl.dart';
import '../../features/products/data/datasources/products_api_datasource.dart';
import '../../features/products/data/datasources/search_history_local_datasource.dart';
import '../../features/products/data/repositories/products_repository.dart';
import '../../features/products/data/repositories/products_repository_impl.dart';
import '../../features/products/data/repositories/search_history_repository.dart';
import '../../features/products/data/repositories/search_history_repository_impl.dart';
import '../../features/profile/presentation/view_models/profile_cubit.dart';
import '../../features/ratings/data/datasources/ratings_image_store.dart';
import '../../features/ratings/data/datasources/ratings_local_datasource.dart';
import '../../features/ratings/data/repositories/ratings_repository.dart';
import '../../features/ratings/data/repositories/ratings_repository_impl.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import '../network/token_storage.dart';

/// Global service locator instance.
///  pattern singleton ===== dioclent // login//
final getIt = GetIt.instance;

/// Registers the network stack and feature services.
///
/// Call once from `main()` after `WidgetsFlutterBinding.ensureInitialized()`.
Future<void> configureDependencies() async {
  // --- Core / infrastructure ---------------------------------------------

  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Persistent local token cache (survives app restarts).
  getIt.registerLazySingleton<TokenStorage>(
    () => SharedPrefsTokenStorage(getIt<SharedPreferences>()),
  );

  // Base Dio, shared so interceptors/options are configured in one place.
  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        sendTimeout: ApiEndpoints.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    ),
  );

  // DioClient owns auth-header injection, token refresh and ApiException mapping.
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(dio: getIt<Dio>(), tokenStorage: getIt<TokenStorage>()),
  );

  // --- Feature: Auth ------------------------------------------------------

  getIt.registerLazySingleton<LoginService>(() => LoginService());

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      loginService: getIt<LoginService>(),
      tokenStorage: getIt<TokenStorage>(),
    ),
  );

  // --- Feature: Profile ---------------------------------------------------

  getIt.registerFactory<ProfileCubit>(() => ProfileCubit());

  // --- Feature: Products --------------------------------------------------

  getIt.registerLazySingleton<ProductsApiDatasource>(
    () => ProductsApiDatasource(),
  );

  getIt.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(datasource: getIt<ProductsApiDatasource>()),
  );

  getIt.registerLazySingleton<SearchHistoryLocalDatasource>(
    () => SearchHistoryLocalDatasource(),
  );

  getIt.registerLazySingleton<SearchHistoryRepository>(
    () => SearchHistoryRepositoryImpl(
      datasource: getIt<SearchHistoryLocalDatasource>(),
    ),
  );

  // --- Feature: Categories ------------------------------------------------

  getIt.registerLazySingleton<CategoryApiDatasource>(
    () => CategoryApiDatasource(),
  );

  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(getIt<CategoryApiDatasource>()),
  );

  // --- Feature: Ratings --------------------------------------------------

  getIt.registerLazySingleton<RatingsLocalDatasource>(
    () => RatingsLocalDatasource(),
  );

  getIt.registerLazySingleton<RatingsImageStore>(() => RatingsImageStore());

  getIt.registerLazySingleton<RatingsRepository>(
    () => RatingsRepositoryImpl(
      datasource: getIt<RatingsLocalDatasource>(),
      imageStore: getIt<RatingsImageStore>(),
    ),
  );

  // --- Feature: Cart ------------------------------------------------------

  getIt.registerLazySingleton<CartApiDatasource>(
    () => CartApiDatasource(),
  );

  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(datasource: getIt<CartApiDatasource>()),
  );
}
