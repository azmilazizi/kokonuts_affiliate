import 'package:flutter/material.dart';

import '../config.dart';
import '../models.dart';
import 'net_image.dart';

/// Height of everything under the square image (title + price + padding).
/// home_page.dart uses it to size grid tiles.
const double kCardTextHeight = 112;

class ProductCard extends StatelessWidget {
  final Item item;
  final bool highlighted;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.item,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(8);
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(radius),
        side: highlighted
            ? const BorderSide(color: kOrange, width: 2)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetImage(item.imageUrl),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Row(
                      children: [
                        if (item.shopeeUrl != null)
                          const _PlatformBadge(
                            'Shopee',
                            kOrange,
                            Icons.shopping_bag_rounded,
                          ),
                        if (item.shopeeUrl != null && item.tiktokUrl != null)
                          const SizedBox(width: 4),
                        if (item.tiktokUrl != null)
                          const _PlatformBadge(
                            'TikTok Shop',
                            Colors.black,
                            Icons.music_note_rounded,
                          ),
                      ],
                    ),
                  ),
                  if (item.discountPercent != null && item.discountPercent! > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 7,
                        ),
                        color: const Color(0xFFFFF1ED),
                        child: Text(
                          '-${item.discountPercent!.round()}%',
                          style: const TextStyle(
                            color: kOrange,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  if (item.videoUrl != null)
                    const Positioned(
                      right: 10,
                      bottom: 10,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black54,
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${item.itemNo}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: item.name),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, height: 1.2),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (item.price != null)
                        Text(
                          'RM${item.price!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: kOrange,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      if (item.soldCount != null)
                        Text(
                          '${_compactCount(item.soldCount!)} sold',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _PlatformBadge(this.label, this.color, this.icon);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 12),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

String _compactCount(int count) {
  if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(count % 1000000 == 0 ? 0 : 1)}m+';
  }
  if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1)}k+';
  }
  return '$count';
}

/// Grey box shown while items load.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AspectRatio(
          aspectRatio: 1,
          child: ColoredBox(color: Color(0xFFEAEAEA)),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bar(double.infinity),
              const SizedBox(height: 6),
              _bar(60),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _bar(double w) =>
      Container(width: w, height: 12, color: const Color(0xFFEAEAEA));
}
