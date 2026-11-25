import 'package:flutter/material.dart';

/// Shows an asset ("assets/...") or a network image, with a grey
/// placeholder while loading / on error.
///
/// WebHtmlElementStrategy.fallback: Flutter web normally downloads images
/// with fetch(), which needs CORS headers from the image host. Shopee's CDN
/// (and cPanel by default) don't send them, so the image would fail. With
/// `fallback`, Flutter retries as a plain <img> element, which ignores CORS.
/// Downside: those images can't be blurred/filtered, which is fine here.
class NetImage extends StatelessWidget {
  final String src;
  final BoxFit fit;

  const NetImage(this.src, {super.key, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (src.isEmpty) return const _Placeholder();
    if (!src.startsWith('http')) {
      return Image.asset(
        src,
        fit: fit,
        errorBuilder: (_, _, _) => const _Placeholder(),
      );
    }
    return Image.network(
      src,
      fit: fit,
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const _Placeholder(),
      errorBuilder: (_, _, _) => const _Placeholder(icon: true),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final bool icon;
  const _Placeholder({this.icon = false});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFFE6E6E6),
    child: icon
        ? const Center(child: Icon(Icons.image_outlined, color: Colors.black26))
        : const SizedBox.expand(),
  );
}
