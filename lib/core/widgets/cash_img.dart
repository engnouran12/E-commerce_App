

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
////

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.version, // e.g. updatedAt from backend: changes -> image reloads
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String? url;
  final String? version;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final link = url?.trim();
    if (link == null || link.isEmpty) return _box(const Icon(Icons.image_not_supported));

    return CachedNetworkImage(

      imageUrl: link,
      // New url OR new version = new cache entry (old one expires automatically).
      cacheKey: version == null ? link : '$link?v=$version',
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => _box(const CircularProgressIndicator(strokeWidth: 2)),
      errorWidget: (_, __, ___) => _box(const Icon(Icons.broken_image)),
    );
  }

  Widget _box(Widget child) => SizedBox(
        width: width,
        height: height,
        child: Center(child: child),
      );
}
//clear cash h

// Usage:
// AppNetworkImage(
//   url: user.avatarUrl,
//   version: user.updatedAt?.millisecondsSinceEpoch.toString(),
//   width: 80,
//   height: 80,
// )