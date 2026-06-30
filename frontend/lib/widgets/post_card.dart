import 'package:flutter/material.dart';

import '../core/helpers/image_url_helper.dart';
import '../models/post_model.dart';
import 'app_popup_menu.dart';
import 'avatar_view.dart';
import 'section_card.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.canEdit = false,
    this.onEdit,
    this.canDelete = false,
    this.onDelete,
    this.onTap,
  });

  final PostModel post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final bool canEdit;
  final VoidCallback? onEdit;
  final bool canDelete;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final postImageUrl = ImageUrlHelper.resolve(post.image);
    final canManage = canEdit || canDelete;

    return SectionCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AvatarView(
                    name: post.userName,
                    imageUrl: post.userImage,
                    radius: 23,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(_formatDate(post.createdAt)),
                      ],
                    ),
                  ),
                  if (canManage)
                    AppPopupMenu(
                      onEdit: canEdit ? onEdit : null,
                      onDelete: canDelete
                          ? () => _confirmDelete(context)
                          : null,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(post.body, style: theme.textTheme.bodyLarge),
              if (postImageUrl != null) ...[
                const SizedBox(height: 14),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      postImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          alignment: Alignment.center,
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.broken_image_outlined),
                        );
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  _ActionChip(
                    icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                    label: '${post.likesCount}',
                    isActive: post.isLiked,
                    onTap: onLike,
                  ),
                  const SizedBox(width: 10),
                  _ActionChip(
                    icon: Icons.mode_comment_outlined,
                    label: '${post.commentsCount}',
                    onTap: onComment,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day.$month $hour:$minute';
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bu gönderi silinsin mi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) onDelete?.call();
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? const Color(0xFFEC4899)
        : Theme.of(context).colorScheme.primary;
    final background = isActive
        ? const Color(0xFFFCE7F3)
        : const Color(0xFFF3E8FF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
