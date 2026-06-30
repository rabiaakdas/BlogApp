import 'package:flutter/material.dart';

import '../core/helpers/image_url_helper.dart';

class AvatarView extends StatelessWidget {
  const AvatarView({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 22,
  });

  final String name;
  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ImageUrlHelper.resolve(imageUrl);

    return Container(
      height: radius * 2,
      width: radius * 2,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
      ),
      child: resolvedUrl == null
          ? Center(
              child: Text(
                _initial(name),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: radius * 0.72,
                ),
              ),
            )
          : Image.network(
              resolvedUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    _initial(name),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: radius * 0.72,
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _initial(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }
}
