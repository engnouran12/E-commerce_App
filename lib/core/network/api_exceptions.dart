import 'package:dio/dio.dart';

/// Custom exception class representing network & API errors in a structured format.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final DioExceptionType? type;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
    this.type,
  });

  /// Factory to translate a [DioException] into a user-friendly [ApiException].
  factory ApiException.fromDioException(DioException dioException) {
    final int? statusCode = dioException.response?.statusCode;
    final dynamic data = dioException.response?.data;
    String? serverMessage;

    // Attempt to extract server error message if available in response body
    if (data is Map<String, dynamic>) {
      if (data['message'] != null) {
        serverMessage = data['message'].toString();
      } else if (data['error'] != null) {
        serverMessage = data['error'].toString();
      }
    } else if (data is String && data.isNotEmpty) {
      serverMessage = data;
    }

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: serverMessage ??
              'Connection timed out. Please check your internet connection.',
          statusCode: statusCode,
          data: data,
          type: dioException.type,
        );

      case DioExceptionType.sendTimeout:
        return ApiException(
          message: serverMessage ??
              'Request timed out while sending data to server.',
          statusCode: statusCode,
          data: data,
          type: dioException.type,
        );

      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: serverMessage ??
              'Server took too long to respond. Please try again.',
          statusCode: statusCode,
          data: data,
          type: dioException.type,
        );

      case DioExceptionType.badCertificate:
        return ApiException(
          message: serverMessage ??
              'SSL Certificate error. Connection is not secure.',
          statusCode: statusCode,
          data: data,
          type: dioException.type,
        );

      case DioExceptionType.badResponse:
        switch (statusCode) {
          case 400:
            return ApiException(
              message:
                  serverMessage ?? 'Bad request. Please verify your data.',
              statusCode: statusCode,
              data: data,
              type: dioException.type,
            );
          case 401:
            return ApiException(
              message:
                  serverMessage ?? 'Unauthorized. Please login again.',
              statusCode: statusCode,
              data: data,
              type: dioException.type,
            );
          case 403:
            return ApiException(
              message: serverMessage ?? 'Access forbidden.',
              statusCode: statusCode,
              data: data,
              type: dioException.type,
            );
          case 404:
            return ApiException(
              message:
                  serverMessage ?? 'Requested resource was not found.',
              statusCode: statusCode,
              data: data,
              type: dioException.type,
            );
          case 409:
            return ApiException(
              message: serverMessage ?? 'Conflict occurred.',
              statusCode: statusCode,
              data: data,
              type: dioException.type,
            );
          case 500:
          case 502:
          case 503:
            return ApiException(
              message: serverMessage ??
                  'Server error (${statusCode ?? 500}). Please try again later.',
              statusCode: statusCode,
              data: data,
              type: dioException.type,
            );
          default:
            return ApiException(
              message: serverMessage ??
                  'Received error status code: $statusCode',
              statusCode: statusCode,
              data: data,
              type: dioException.type,
            );
        }

      case DioExceptionType.cancel:
        return ApiException(
          message: serverMessage ?? 'Request was cancelled.',
          statusCode: statusCode,
          data: data,
          type: dioException.type,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: serverMessage ??
              'Unable to connect to the server. Please check your internet connection.',
          statusCode: statusCode,
          data: data,
          type: dioException.type,
        );

      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: serverMessage ??
              dioException.message ??
              'Unknown network error occurred.',
          statusCode: statusCode,
          data: data,
          type: dioException.type,
        );
    }
  }

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}
