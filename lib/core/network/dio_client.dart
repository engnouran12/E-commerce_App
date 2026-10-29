import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import 'api_exceptions.dart';
import 'auth_interceptor.dart';
import 'token_storage.dart';


/// Production-ready Dio HTTP Client that wraps all HTTP methods (GET, POST, PUT,
/// PATCH, DELETE, HEAD, DOWNLOAD, UPLOAD), handles authentication headers,
/// token refresh via [AuthInterceptor], and transforms errors into [ApiException].
class DioClient {
  late final Dio _dio;
  late final TokenStorage _tokenStorage;
  late final AuthInterceptor _authInterceptor;

  // Singleton instance
  static DioClient? _instance;

  /// Returns the singleton instance of [DioClient].
  static DioClient get instance => _instance ??= DioClient();

  /// Exposes the underlying [Dio] instance for advanced customizations.
  Dio get dio => _dio;

  /// Exposes the [TokenStorage] used by this client.
  TokenStorage get tokenStorage => _tokenStorage;

  DioClient({
    Dio? dio,
    TokenStorage? tokenStorage,
    Dio? refreshDio,
    String baseUrl = ApiEndpoints.baseUrl,
    Duration connectTimeout = ApiEndpoints.connectTimeout,
    Duration receiveTimeout = ApiEndpoints.receiveTimeout,
    Duration sendTimeout = ApiEndpoints.sendTimeout,
    Map<String, dynamic>? defaultHeaders,
    List<Interceptor>? additionalInterceptors,
    bool enableLogging = true,
    OnUnauthorizedCallback? onUnauthorized,
    OnTokenRefreshedCallback? onTokenRefreshed,
  }) {
    _tokenStorage = tokenStorage ?? InMemoryTokenStorage();

    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: connectTimeout,
            receiveTimeout: receiveTimeout,
            sendTimeout: sendTimeout,
            headers: defaultHeaders ??
                {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
            responseType: ResponseType.json,
          ),
        );

    _authInterceptor = AuthInterceptor(
      tokenStorage: _tokenStorage,
      refreshDio: refreshDio,
      retryDio: _dio,
      refreshEndpoint: ApiEndpoints.refresh,
      onUnauthorized: onUnauthorized,
      onTokenRefreshed: onTokenRefreshed,
    );

    // Add interceptors
    _dio.interceptors.add(_authInterceptor);

    if (enableLogging) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ),
      );
    }

    if (additionalInterceptors != null && additionalInterceptors.isNotEmpty) {
      _dio.interceptors.addAll(additionalInterceptors);
    }

    _instance = this;
  }

  // ==========================================
  // TOKEN CONVENIENCE HELPERS
  // ==========================================

  /// Sets or updates the access and refresh tokens.
  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// Retrieves the current access token.
  Future<String?> getAccessToken() async => _tokenStorage.getAccessToken();

  /// Retrieves the current refresh token.
  Future<String?> getRefreshToken() async => _tokenStorage.getRefreshToken();

  /// Clears stored authentication tokens.
  Future<void> clearTokens() async => _tokenStorage.clearTokens();

  // ==========================================
  // HTTP METHODS
  // ==========================================

  /// Performs a GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool requiresAuth = true,
  }) async {
    try {
      final opts = _mergeOptions(options, requiresAuth: requiresAuth);
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Performs a POST request.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool requiresAuth = true,
  }) async {
    try {
      final opts = _mergeOptions(options, requiresAuth: requiresAuth);
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Performs a PUT request.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool requiresAuth = true,
  }) async {
    try {
      final opts = _mergeOptions(options, requiresAuth: requiresAuth);
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Performs a PATCH request.
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool requiresAuth = true,
  }) async {
    try {
      final opts = _mergeOptions(options, requiresAuth: requiresAuth);
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Performs a DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    try {
      final opts = _mergeOptions(options, requiresAuth: requiresAuth);
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Performs a HEAD request.
  Future<Response<T>> head<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    try {
      final opts = _mergeOptions(options, requiresAuth: requiresAuth);
      return await _dio.head<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Downloads a file from [urlPath] and writes it to [savePath].
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    dynamic data,
    Options? options,
    bool requiresAuth = true,
  }) async {
    try {
      final opts = _mergeOptions(options, requiresAuth: requiresAuth);
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        data: data,
        options: opts,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Uploads a single file using `multipart/form-data`.
  Future<Response<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fileFieldName,
    String? filename,
    Map<String, dynamic>? additionalFields,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    bool requiresAuth = true,
  }) async {
    try {
      final multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: filename,
      );

      final formData = FormData.fromMap({
        fileFieldName: multipartFile,
        ...?additionalFields,
      });

      final opts = _mergeOptions(
        options,
        requiresAuth: requiresAuth,
        contentType: 'multipart/form-data',
      );

      return await _dio.post<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ==========================================
  // HELPER METHODS
  // ==========================================

  /// Merges user-supplied [Options] with internal flags such as `requiresAuth`.
  Options _mergeOptions(
    Options? options, {
    required bool requiresAuth,
    String? contentType,
  }) {
    final extra = Map<String, dynamic>.from(options?.extra ?? {});
    extra['requiresAuth'] = requiresAuth;

    return (options ?? Options()).copyWith(
      extra: extra,
      contentType: contentType ?? options?.contentType,
    );
  }
}
