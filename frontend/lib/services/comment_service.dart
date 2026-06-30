import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../core/errors/api_error_handler.dart';
import '../core/network/dio_client.dart';
import '../models/comment_model.dart';

class CommentService {
  CommentService({DioClient? dioClient})
    : _dio = (dioClient ?? DioClient()).dio;

  final Dio _dio;

  Future<List<CommentModel>> getComments(int postId) async {
    try {
      final response = await _dio.get(ApiConstants.postComments(postId));
      final data = response.data as Map<String, dynamic>;
      final commentsJson = data['comments'] as List<dynamic>? ?? [];

      return commentsJson
          .map(
            (commentJson) =>
                CommentModel.fromJson(commentJson as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (error) {
      throw ApiErrorHandler.handle(error);
    }
  }

  Future<CommentModel> createComment(int postId, String comment) async {
    Object? responseData;

    try {
      final response = await _dio.post(
        ApiConstants.postComments(postId),
        data: {'comment': comment},
      );
      responseData = response.data;
      final commentJson = _extractCommentJson(responseData);

      return CommentModel.fromJson(commentJson);
    } on DioException catch (error) {
      throw ApiErrorHandler.handle(error);
    } catch (error) {
      debugPrint('createComment parse error: $error');
      debugPrint('createComment response data: $responseData');
      throw const FormatException('Comment response parse edilemedi.');
    }
  }

  Future<void> updateComment({
    required int commentId,
    required String comment,
  }) async {
    try {
      await _dio.put(
        ApiConstants.commentById(commentId),
        data: {'comment': comment},
      );
    } on DioException catch (error) {
      throw ApiErrorHandler.handle(error);
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      await _dio.delete(ApiConstants.commentById(commentId));
    } on DioException catch (error) {
      throw ApiErrorHandler.handle(error);
    }
  }

  Map<String, dynamic> _extractCommentJson(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Comment response map degil.');
    }

    final candidate = data['comment'] ?? data['data'] ?? data;

    if (candidate is Map<String, dynamic>) {
      return candidate;
    }

    throw const FormatException('Comment objesi bulunamadi.');
  }
}
