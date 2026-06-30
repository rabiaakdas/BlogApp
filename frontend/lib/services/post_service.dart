import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../core/errors/api_error_handler.dart';
import '../core/network/dio_client.dart';
import '../models/post_model.dart';

class PostService {
  PostService({DioClient? dioClient}) : _dio = (dioClient ?? DioClient()).dio;

  final Dio _dio;

  Future<List<PostModel>> getPosts() async {
    try {
      final response = await _dio.get(ApiConstants.posts);
      final data = response.data as Map<String, dynamic>;
      final postsJson = data['posts'] as List<dynamic>? ?? [];

      return postsJson
          .map(
            (postJson) => PostModel.fromJson(postJson as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (error) {
      throw ApiErrorHandler.handle(error);
    }
  }

  Future<PostModel> createPost({required String body, File? image}) async {
    Object? responseData;

    try {
      final formData = FormData.fromMap({
        'body': body,
        if (image != null)
          'image': await MultipartFile.fromFile(
            image.path,
            filename: image.uri.pathSegments.last,
          ),
      });

      final response = await _dio.post(
        ApiConstants.posts,
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );
      responseData = response.data;
      debugPrint('createPost response data: $responseData');
      final postJson = _extractPostJson(responseData);

      return PostModel.fromJson(postJson);
    } on DioException catch (error) {
      throw ApiErrorHandler.handle(error);
    } catch (error) {
      debugPrint('createPost parse error: $error');
      debugPrint('createPost response data: $responseData');
      throw const FormatException('Post response parse edilemedi.');
    }
  }

  Future<PostModel> updatePost({
    required int postId,
    required String body,
    File? image,
    bool removeImage = false,
  }) async {
    final trimmedBody = body.trim();

    if (trimmedBody.isEmpty) {
      throw Exception('Post içeriği boş olamaz.');
    }

    Object? responseData;

    try {
      final response = image == null
          ? await _dio.put(
              ApiConstants.postById(postId),
              data: {'body': trimmedBody, if (removeImage) 'image': ''},
            )
          : await _dio.post(
              ApiConstants.postById(postId),
              data: FormData.fromMap({
                '_method': 'PUT',
                'body': trimmedBody,
                'image': await MultipartFile.fromFile(
                  image.path,
                  filename: image.path.split('/').last,
                ),
              }),
              options: Options(
                contentType: Headers.multipartFormDataContentType,
              ),
            );
      responseData = response.data;
      final postJson = _extractPostJson(responseData);

      return PostModel.fromJson(postJson);
    } on DioException catch (error) {
      throw ApiErrorHandler.handle(error);
    } catch (error) {
      debugPrint('updatePost parse error: $error');
      debugPrint('updatePost response data: $responseData');
      throw const FormatException('Post response parse edilemedi.');
    }
  }

  Future<void> toggleLike(int postId) async {
    try {
      await _dio.post(ApiConstants.postLikes(postId));
    } on DioException catch (error) {
      throw ApiErrorHandler.handle(error);
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      await _dio.delete(ApiConstants.postById(postId));
    } on DioException catch (error) {
      throw ApiErrorHandler.handle(error);
    }
  }

  Map<String, dynamic> _extractPostJson(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Post response map degil.');
    }

    final candidate = data['post'] ?? data['data'] ?? data;

    if (candidate is Map<String, dynamic>) {
      return candidate;
    }

    throw const FormatException('Post objesi bulunamadi.');
  }
}
