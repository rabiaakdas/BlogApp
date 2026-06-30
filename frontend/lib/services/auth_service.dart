import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../core/errors/api_error_handler.dart';
import '../core/network/dio_client.dart';
import '../models/user_model.dart';

class AuthResponse {
  const AuthResponse({required this.user, required this.token});

  final UserModel user;
  final String token;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
}

class AuthService {
  AuthService({DioClient? dioClient}) : _dio = (dioClient ?? DioClient()).dio;

  final Dio _dio;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiErrorHandler.handle(error);
    }
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiErrorHandler.handle(error);
    }
  }

  Future<UserModel> getUser() async {
    try {
      final response = await _dio.get(ApiConstants.user);
      final data = response.data as Map<String, dynamic>;
      final userJson = data['user'] ?? data;

      return UserModel.fromJson(userJson as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiErrorHandler.handle(error);
    }
  }

  Future<UserModel> updateProfile({required String name, File? image}) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw Exception('İsim alanı boş olamaz.');
    }

    debugPrint('updateProfile name: $trimmedName');
    debugPrint('updateProfile image path: ${image?.path}');

    try {
      final response = image == null
          ? await _dio.put(ApiConstants.user, data: {'name': trimmedName})
          : await _dio.post(
              ApiConstants.user,
              data: FormData.fromMap({
                '_method': 'PUT',
                'name': trimmedName,
                'image': await MultipartFile.fromFile(
                  image.path,
                  filename: image.path.split('/').last,
                ),
              }),
              options: Options(
                contentType: Headers.multipartFormDataContentType,
              ),
            );

      return _parseUserResponse(response.data);
    } on DioException catch (error) {
      debugPrint('updateProfile statusCode: ${error.response?.statusCode}');
      debugPrint('updateProfile response data: ${error.response?.data}');
      debugPrint('updateProfile sent name: $trimmedName');
      debugPrint('updateProfile sent image path: ${image?.path}');
      throw ApiErrorHandler.handle(error);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException catch (error) {
      throw ApiErrorHandler.handle(error);
    }
  }

  Future<UserModel> _parseUserResponse(Object? responseData) async {
    if (responseData is Map<String, dynamic>) {
      final candidate = responseData['user'] ?? responseData['data'];

      if (candidate is Map<String, dynamic>) {
        return UserModel.fromJson(candidate);
      }

      if (responseData.containsKey('id') ||
          responseData.containsKey('name') ||
          responseData.containsKey('email')) {
        return UserModel.fromJson(responseData);
      }
    }

    return getUser();
  }
}
