import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/comment_model.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/comment_tile.dart';
import '../../widgets/post_card.dart';
import '../../widgets/snackbar_helper.dart';
import 'edit_post_screen.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.post});

  final PostModel post;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  late PostModel _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CommentProvider>().fetchComments(_post.id);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final comment = _commentController.text.trim();
    final currentPost = _currentPost(context.read<PostProvider>());

    if (comment.isEmpty) {
      showErrorSnackBar(context, 'Yorum boş olamaz');
      return;
    }

    final commentProvider = context.read<CommentProvider>();
    final success = await commentProvider.addComment(currentPost.id, comment);

    if (!mounted) return;

    if (success) {
      _commentController.clear();
      context.read<PostProvider>().incrementCommentsCount(currentPost.id);
      setState(() {
        _post = currentPost.copyWith(
          commentsCount: currentPost.commentsCount + 1,
        );
      });
      showSuccessSnackBar(context, 'Yorum eklendi');
    } else {
      showErrorSnackBar(context, 'Yorum eklenemedi');
    }
  }

  Future<void> _deletePost() async {
    final postProvider = context.read<PostProvider>();
    final currentPost = _currentPost(postProvider);
    final success = await postProvider.deletePost(currentPost);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      showSuccessSnackBar(context, 'Gönderi silindi');
    } else {
      showErrorSnackBar(context, postProvider.error ?? 'Gönderi silinemedi');
    }
  }

  Future<void> _editPost() async {
    final currentPost = _currentPost(context.read<PostProvider>());
    final updatedPost = await Navigator.of(context).push<PostModel>(
      MaterialPageRoute(builder: (_) => EditPostScreen(post: currentPost)),
    );

    if (!mounted || updatedPost == null) return;

    setState(() {
      _post = updatedPost;
    });

    showSuccessSnackBar(context, 'Gönderi güncellendi');
  }

  Future<void> _editComment({
    required CommentProvider commentProvider,
    required CommentModel comment,
    required String newComment,
  }) async {
    final success = await commentProvider.updateComment(
      postId: _currentPost(context.read<PostProvider>()).id,
      oldComment: comment,
      newComment: newComment,
    );

    if (!mounted) return;

    if (success) {
      showSuccessSnackBar(context, 'Yorum güncellendi');
    } else {
      showErrorSnackBar(context, 'Yorum güncellenemedi');
    }
  }

  Future<void> _deleteComment({
    required CommentProvider commentProvider,
    required CommentModel comment,
  }) async {
    final currentPost = _currentPost(context.read<PostProvider>());
    final success = await commentProvider.deleteComment(comment);

    if (!mounted) return;

    if (success) {
      context.read<PostProvider>().decrementCommentsCount(currentPost.id);
      setState(() {
        _post = currentPost.copyWith(
          commentsCount: (currentPost.commentsCount - 1).clamp(
            0,
            currentPost.commentsCount,
          ),
        );
      });
      showSuccessSnackBar(context, 'Yorum silindi');
    } else {
      showErrorSnackBar(context, 'Yorum silinemedi');
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = context.watch<CommentProvider>();
    final postProvider = context.watch<PostProvider>();
    final currentUserId = context.watch<AuthProvider>().user?.id;
    final providerPost = _currentPost(postProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gönderi Detayı')),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: PostCard(
                    post: providerPost,
                    onLike: () => postProvider.toggleLike(providerPost),
                    canEdit: providerPost.userId == currentUserId,
                    onEdit: _editPost,
                    canDelete: providerPost.userId == currentUserId,
                    onDelete: _deletePost,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          'Yorumlar',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${providerPost.commentsCount}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (commentProvider.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (commentProvider.error != null &&
                    commentProvider.comments.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          commentProvider.error!,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                else if (commentProvider.comments.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text('Bu gönderiye henüz yorum yapılmamış.'),
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: commentProvider.comments.length,
                    itemBuilder: (context, index) {
                      final comment = commentProvider.comments[index];

                      return CommentTile(
                        comment: comment,
                        canEditDelete: comment.userId == currentUserId,
                        onEdit: (newComment) => _editComment(
                          commentProvider: commentProvider,
                          comment: comment,
                          newComment: newComment,
                        ),
                        onDelete: () => _deleteComment(
                          commentProvider: commentProvider,
                          comment: comment,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          _CommentInput(
            controller: _commentController,
            isSubmitting: commentProvider.isSubmitting,
            onSubmit: _submitComment,
          ),
        ],
      ),
    );
  }

  PostModel _currentPost(PostProvider postProvider) {
    return postProvider.posts.firstWhere(
      (post) => post.id == widget.post.id,
      orElse: () => _post,
    );
  }
}

class _CommentInput extends StatelessWidget {
  const _CommentInput({
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Yorum yaz...'),
              ),
            ),
            const SizedBox(width: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: IconButton(
                onPressed: isSubmitting ? null : onSubmit,
                icon: isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_outlined, color: Colors.white),
                tooltip: 'Gönder',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
