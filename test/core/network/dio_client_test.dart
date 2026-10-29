import 'package:dio/dio.dart';
import 'package:e_commerce/core/network/api_endpoints.dart';
import 'package:e_commerce/core/network/api_exceptions.dart';
import 'package:e_commerce/core/network/auth_interceptor.dart';
import 'package:e_commerce/core/network/dio_client.dart';
import 'package:e_commerce/core/network/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TokenStorage Tests', () {
    test('InMemoryTokenStorage stores, retrieves, and clears tokens', () async {
      final storage = InMemoryTokenStorage();

      expect(await storage.hasAccessToken(), isFalse);
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);

      await storage.saveTokens(
        accessToken: 'access_123',
        refreshToken: 'refresh_456',
      );

      expect(await storage.hasAccessToken(), isTrue);
      expect(await storage.getAccessToken(), 'access_123');
      expect(await storage.getRefreshToken(), 'refresh_456');

      await storage.clearTokens();
      expect(await storage.hasAccessToken(), isFalse);
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
    });
  });

  group('AuthInterceptor Tests', () {
    test('Attaches Authorization header when accessToken exists and requiresAuth is true', () async {
      final storage = InMemoryTokenStorage(
        accessToken: 'test_token',
        refreshToken: 'test_refresh',
      );
      final interceptor = AuthInterceptor(tokenStorage: storage);

      final options = RequestOptions(path: '/users');
      final handler = _TestRequestHandler();

      interceptor.onRequest(options, handler);
      await Future<void>.delayed(Duration.zero);

      expect(handler.nextOptions?.headers['Authorization'], 'Bearer test_token');
    });

    test('Omits Authorization header when requiresAuth is false', () async {
      final storage = InMemoryTokenStorage(
        accessToken: 'test_token',
        refreshToken: 'test_refresh',
      );
      final interceptor = AuthInterceptor(tokenStorage: storage);

      final options = RequestOptions(
        path: '/auth/login',
        extra: {'requiresAuth': false},
      );
      final handler = _TestRequestHandler();

      interceptor.onRequest(options, handler);
      await Future<void>.delayed(Duration.zero);

      expect(handler.nextOptions?.headers['Authorization'], isNull);
    });

    test('Refreshes token on 401 error and retries original request', () async {
      final storage = InMemoryTokenStorage(
        accessToken: 'old_access',
        refreshToken: 'valid_refresh',
      );

      final mockRefreshDio = Dio();
      mockRefreshDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.refresh) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'accessToken': 'new_access_token',
                    'refreshToken': 'new_refresh_token',
                  },
                ),
              );
            }
            if (options.path == '/protected') {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true},
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      bool notifiedRefresh = false;
      final interceptor = AuthInterceptor(
        tokenStorage: storage,
        refreshDio: mockRefreshDio,
        onTokenRefreshed: (newAcc, newRef) {
          notifiedRefresh = true;
        },
      );

      final err = DioException(
        requestOptions: RequestOptions(
          path: '/protected',
          headers: {'Authorization': 'Bearer old_access'},
        ),
        response: Response(
          requestOptions: RequestOptions(path: '/protected'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      final handler = _TestErrorHandler();
      interceptor.onError(err, handler);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(notifiedRefresh, isTrue);
      expect(await storage.getAccessToken(), 'new_access_token');
      expect(await storage.getRefreshToken(), 'new_refresh_token');
      expect(handler.resolvedResponse?.statusCode, 200);
      expect(handler.resolvedResponse?.data, {'success': true});
    });

    test('Clears tokens and calls onUnauthorized when refresh fails', () async {
      final storage = InMemoryTokenStorage(
        accessToken: 'old_access',
        refreshToken: 'invalid_refresh',
      );

      final mockRefreshDio = Dio();
      mockRefreshDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      bool unauthorizedTriggered = false;
      final interceptor = AuthInterceptor(
        tokenStorage: storage,
        refreshDio: mockRefreshDio,
        onUnauthorized: () {
          unauthorizedTriggered = true;
        },
      );

      final err = DioException(
        requestOptions: RequestOptions(path: '/protected'),
        response: Response(
          requestOptions: RequestOptions(path: '/protected'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      final handler = _TestErrorHandler();
      interceptor.onError(err, handler);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(unauthorizedTriggered, isTrue);
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
      expect(handler.nextError, isNotNull);
    });
  });

  group('DioClient HTTP Methods Tests', () {
    test('DioClient can be instantiated and helper methods function', () async {
      final client = DioClient(enableLogging: false);

      await client.setTokens(
        accessToken: 'my_access_token',
        refreshToken: 'my_refresh_token',
      );

      expect(await client.getAccessToken(), 'my_access_token');
      expect(await client.getRefreshToken(), 'my_refresh_token');

      await client.clearTokens();
      expect(await client.getAccessToken(), isNull);
      expect(await client.getRefreshToken(), isNull);
    });
  });

  group('ApiException Tests', () {
    test('ApiException correctly maps 401 Unauthorized status', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/me'),
        response: Response(
          requestOptions: RequestOptions(path: '/me'),
          statusCode: 401,
          data: {'message': 'Token expired'},
        ),
        type: DioExceptionType.badResponse,
      );

      final apiException = ApiException.fromDioException(dioException);
      expect(apiException.statusCode, 401);
      expect(apiException.message, 'Token expired');
    });

    test('ApiException falls back to readable status message when body is empty', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/not-found'),
        response: Response(
          requestOptions: RequestOptions(path: '/not-found'),
          statusCode: 404,
          data: null,
        ),
        type: DioExceptionType.badResponse,
      );

      final apiException = ApiException.fromDioException(dioException);
      expect(apiException.statusCode, 404);
      expect(apiException.message, 'Requested resource was not found.');
    });
  });
}

class _TestRequestHandler extends RequestInterceptorHandler {
  RequestOptions? nextOptions;

  @override
  void next(RequestOptions requestOptions) {
    nextOptions = requestOptions;
  }
}

class _TestErrorHandler extends ErrorInterceptorHandler {
  Response? resolvedResponse;
  DioException? nextError;

  @override
  void resolve(Response response) {
    resolvedResponse = response;
  }

  @override
  void next(DioException err) {
    nextError = err;
  }
}
