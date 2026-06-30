import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/errors/api_error_handler.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class PostProvider extends ChangeNotifier {
  PostProvider({PostService? postService})
    : _postService = postService ?? PostService();

  final PostService _postService;

  List<PostModel> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPosts() async {
    _setLoading(true);

    try {
      _posts = await _postService.getPosts();
      _error = null;
    } catch (error) {
      _error = ApiErrorHandler.messageFrom(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshPosts() async {
    try {
      _posts = await _postService.getPosts();
      _error = null;
      notifyListeners();
    } catch (error) {
      _error = ApiErrorHandler.messageFrom(error);
      notifyListeners();
    }
  }

  Future<bool> createPost({required String body, File? image}) async {
    _setLoading(true);

    try {
      await _postService.createPost(body: body, image: image);
      _posts = await _postService.getPosts();
      _error = null;
      return true;
    } on FormatException {
      _posts = await _postService.getPosts();
      _error = null;
      return true;
    } catch (error) {
      _error = ApiErrorHandler.messageFrom(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<PostModel?> updatePost({
    required PostModel post,
    required String body,
    File? image,
    bool removeImage = false,
  }) async {
    _setLoading(true);

    try {
      await _postService.updatePost(
        postId: post.id,
        body: body,
        image: image,
        removeImage: removeImage,
      );
      _posts = await _postService.getPosts();
      final updatedPost = _posts.firstWhere(
        (item) => item.id == post.id,
        orElse: () => post,
      );
      _error = null;
      return updatedPost;
    } on FormatException {
      _posts = await _postService.getPosts();
      final updatedPost = _posts.firstWhere(
        (item) => item.id == post.id,
        orElse: () => post,
      );
      _error = null;
      return updatedPost;
    } catch (error) {
      _error = ApiErrorHandler.messageFrom(error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleLike(PostModel post) async {
    final postIndex = _posts.indexWhere((item) => item.id == post.id);

    if (postIndex == -1) return;

    final oldPost = _posts[postIndex];
    final newIsLiked = !oldPost.isLiked;
    final newLikesCount = newIsLiked
        ? oldPost.likesCount + 1
        : (oldPost.likesCount - 1).clamp(0, oldPost.likesCount);

    _posts = List<PostModel>.from(_posts)
      ..[postIndex] = oldPost.copyWith(
        isLiked: newIsLiked,
        likesCount: newLikesCount,
      );
    _error = null;
    notifyListeners();

    try {
      await _postService.toggleLike(post.id);
    } catch (error) {
      _posts = List<PostModel>.from(_posts)..[postIndex] = oldPost;
      _error = ApiErrorHandler.messageFrom(error);
      notifyListeners();
    }
  }

  Future<bool> deletePost(PostModel post) async {
    final postIndex = _posts.indexWhere((item) => item.id == post.id);

    if (postIndex == -1) return false;

    final oldPost = _posts[postIndex];
    _posts = List<PostModel>.from(_posts)..removeAt(postIndex);
    _error = null;
    notifyListeners();

    try {
      await _postService.deletePost(post.id);
      return true;
    } catch (error) {
      final restoredPosts = List<PostModel>.from(_posts);
      final restoreIndex = postIndex.clamp(0, restoredPosts.length);
      restoredPosts.insert(restoreIndex, oldPost);
      _posts = restoredPosts;
      _error = ApiErrorHandler.messageFrom(error);
      notifyListeners();
      return false;
    }
  }

  void incrementCommentsCount(int postId) {
    final postIndex = _posts.indexWhere((item) => item.id == postId);

    if (postIndex == -1) return;

    final post = _posts[postIndex];
    _posts = List<PostModel>.from(_posts)
      ..[postIndex] = post.copyWith(commentsCount: post.commentsCount + 1);
    notifyListeners();
  }

  void decrementCommentsCount(int postId) {
    final postIndex = _posts.indexWhere((item) => item.id == postId);

    if (postIndex == -1) return;

    final post = _posts[postIndex];
    final commentsCount = (post.commentsCount - 1).clamp(0, post.commentsCount);
    _posts = List<PostModel>.from(_posts)
      ..[postIndex] = post.copyWith(commentsCount: commentsCount);
    notifyListeners();
  }

  void clear() {
    _posts = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
