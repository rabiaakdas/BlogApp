import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiErrorHandler {
  const ApiErrorHandler._();

  static ApiException handle(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const ApiException('Sunucuya bağlanılamadı.');
    }

    final statusCode = error.response?.statusCode;

    return switch (statusCode) {
      401 => const ApiException(
        'Oturum süresi doldu. Lütfen tekrar giriş yapın.',
      ),
      403 => const ApiException('Bu işlem için yetkiniz yok.'),
      404 => const ApiException('Kayıt bulunamadı.'),
      422 => ApiException(_validationMessage(error.response?.data)),
      _ => const ApiException('Bir hata oluştu.'),
    };
  }

  static String messageFrom(Object error) {
    if (error is ApiException) return error.message;
    if (error is DioException) return handle(error).message;

    return 'Bir hata oluştu.';
  }

  static String _validationMessage(Object? data) {
    if (data is! Map<String, dynamic>) {
      return 'Bilgileri kontrol edip tekrar deneyin.';
    }

    final errors = data['errors'];

    if (errors is Map<String, dynamic>) {
      final messages = errors.values
          .expand((value) => value is List ? value : [value])
          .whereType<String>()
          .toList();

      if (messages.isNotEmpty) {
        return messages.join('\n');
      }
    }

    final message = data['message'];

    if (message is String && message.isNotEmpty) {
      return message;
    }

    return 'Bilgileri kontrol edip tekrar deneyin.';
  }
}
