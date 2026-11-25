import 'package:flutter/material.dart';

import '../config.dart';
import '../models.dart';
import 'net_image.dart';

/// Height of everything under the square image (title + price + padding).
/// home_page.dart uses it to size grid tiles.
const double kCardTextHeight = 78;

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
                          const _Badge('Shopee', kOrange),
                        if (item.shopeeUrl != null && item.tiktokUrl != null)
                          const SizedBox(width: 4),
                        if (item.tiktokUrl != null)
                          const _Badge('TikTok', Colors.black),
                      ],
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
                    style: const TextStyle(fontSize: 13, height: 1.3),
                  ),
                  if (item.price != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'RM${item.price!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: kOrange,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
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
