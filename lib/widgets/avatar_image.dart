import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A circular profile picture that falls back to a plain icon whenever the
/// URL doesn't resolve to real image bytes (broken/expired links, or a
/// server returning an HTML error page instead of the image — both show up
/// as an image-decode failure, not a network error).
class AvatarImage extends StatelessWidget {
  const AvatarImage({
    super.key,
    required this.imageUrl,
    this.radius = 46,
    this.icon = Icons.person,
  });

  final String? imageUrl;
  final double radius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _fallback();
    }
    return ClipOval(
      child: Image.network(
        imageUrl!,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.mintLight,
      child: Icon(icon, size: radius * 0.9, color: AppColors.mintDark),
    );
  }
}
