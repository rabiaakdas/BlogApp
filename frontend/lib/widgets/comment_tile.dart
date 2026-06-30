import 'package:flutter/material.dart';

import '../models/comment_model.dart';
import 'app_popup_menu.dart';
import 'avatar_view.dart';
import 'section_card.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.comment,
    this.canEditDelete = false,
    this.onEdit,
    this.onDelete,
  });

  final CommentModel comment;
  final bool canEditDelete;
  final ValueChanged<String>? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvatarView(
            name: comment.userName,
            imageUrl: comment.userImage,
            radius: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(comment.createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.comment,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          if (canEditDelete)
            AppPopupMenu(
              onEdit: () => _showEditDialog(context),
              onDelete: () => _confirmDelete(context),
            ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final controller = TextEditingController(text: comment.comment);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Yorumu düzenle'),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Yorum'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isEmpty) return;

                Navigator.of(dialogContext).pop(value);
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );

    await Future<void>.delayed(const Duration(milliseconds: 250));
    controller.dispose();

    if (!context.mounted || result == null || result == comment.comment) return;

    onEdit?.call(result);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bu yorum silinsin mi?'),
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

    if (confirmed == true) {
      onDelete?.call();
    }
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day.$month $hour:$minute';
  }
}
