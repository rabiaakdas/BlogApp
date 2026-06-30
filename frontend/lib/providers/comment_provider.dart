import 'package:flutter/foundation.dart';

import '../core/errors/api_error_handler.dart';
import '../models/comment_model.dart';
import '../services/comment_service.dart';

class CommentProvider extends ChangeNotifier {
  CommentProvider({CommentService? commentService})
    : _commentService = commentService ?? CommentService();

  final CommentService _commentService;

  List<CommentModel> _comments = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Future<void> fetchComments(int postId) async {
    _setLoading(true);

    try {
      _comments = await _commentService.getComments(postId);
      _error = null;
    } catch (error) {
      _error = ApiErrorHandler.messageFrom(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addComment(int postId, String comment) async {
    _setSubmitting(true);

    try {
      final newComment = await _commentService.createComment(postId, comment);
      _comments = [newComment, ..._comments];
      _error = null;
      return true;
    } on FormatException {
      await fetchComments(postId);
      _error = null;
      return true;
    } catch (error) {
      _error = ApiErrorHandler.messageFrom(error);
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> updateComment({
    required int postId,
    required CommentModel oldComment,
    required String newComment,
  }) async {
    _setSubmitting(true);

    try {
      await _commentService.updateComment(
        commentId: oldComment.id,
        comment: newComment,
      );
      _comments = await _commentService.getComments(postId);
      _error = null;
      return true;
    } catch (error) {
      _error = ApiErrorHandler.messageFrom(error);
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> deleteComment(CommentModel comment) async {
    final commentIndex = _comments.indexWhere((item) => item.id == comment.id);

    if (commentIndex == -1) return false;

    final oldComment = _comments[commentIndex];
    _comments = List<CommentModel>.from(_comments)..removeAt(commentIndex);
    _error = null;
    notifyListeners();

    try {
      await _commentService.deleteComment(comment.id);
      return true;
    } catch (error) {
      final restoredComments = List<CommentModel>.from(_comments);
      final restoreIndex = commentIndex.clamp(0, restoredComments.length);
      restoredComments.insert(restoreIndex, oldComment);
      _comments = restoredComments;
      _error = ApiErrorHandler.messageFrom(error);
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void clear() {
    _comments = [];
    _error = null;
    _isLoading = false;
    _isSubmitting = false;
    notifyListeners();
  }
}
