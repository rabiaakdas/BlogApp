import 'package:flutter/material.dart';

class AppPopupMenu extends StatelessWidget {
  const AppPopupMenu({super.key, this.onEdit, this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_PopupAction>(
      color: Colors.white,
      elevation: 10,
      shadowColor: const Color(0xFF111827).withValues(alpha: 0.12),
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      constraints: const BoxConstraints(minWidth: 156),
      offset: const Offset(0, 10),
      icon: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF3E8FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.more_horiz, size: 20, color: Color(0xFF6D28D9)),
      ),
      onSelected: (value) {
        switch (value) {
          case _PopupAction.edit:
            onEdit?.call();
          case _PopupAction.delete:
            onDelete?.call();
        }
      },
      itemBuilder: (context) => [
        if (onEdit != null)
          const PopupMenuItem(
            value: _PopupAction.edit,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: _PopupMenuRow(
              icon: Icons.edit_outlined,
              label: 'Düzenle',
              color: Color(0xFF8B5CF6),
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: _PopupAction.delete,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: _PopupMenuRow(
              icon: Icons.delete_outline,
              label: 'Sil',
              color: Color(0xFFEF4444),
            ),
          ),
      ],
    );
  }
}

enum _PopupAction { edit, delete }

class _PopupMenuRow extends StatelessWidget {
  const _PopupMenuRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
