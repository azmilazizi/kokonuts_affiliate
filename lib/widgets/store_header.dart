import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../config.dart';
import 'net_image.dart';

/// Blurred cover + avatar + name + item count + tagline + search field.
class StoreHeader extends StatelessWidget {
  final int itemCount;
  final String title;
  final String description;
  final bool hasShopee;
  final bool hasTiktok;
  final TextEditingController search;
  final ValueChanged<String> onSearch;

  const StoreHeader({
    super.key,
    required this.itemCount,
    required this.title,
    required this.description,
    required this.hasShopee,
    required this.hasTiktok,
    required this.search,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    // ClipRect: stops the blur from bleeding past the header's bottom edge.
    return ClipRect(
      child: Stack(
        children: [
          // Cover fills the whole header, blurred + darkened so white text
          // stays readable. (Keep Config.cover an asset or a CORS-enabled URL:
          // a cross-origin image shown via the <img> fallback can't be blurred.)
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: NetImage(Config.cover),
            ),
          ),
          Positioned.fill(
            child: ColoredBox(color: Colors.black.withAlpha(110)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox.square(
                        dimension: 76,
                        child: NetImage(Config.avatar, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(50),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              if (hasShopee) ...[
                                const Icon(Icons.shopping_bag_rounded, color: Color(0xFFFFB000), size: 14),
                                const SizedBox(width: 3),
                              ],
                              if (hasTiktok) ...[
                                const Icon(Icons.music_note_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                              ],
                              Text('$itemCount items', style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: search,
                  onChanged: onSearch,
                  // Plain text keyboard so users can type numbers OR names.
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search by item number or product name',
                    hintStyle: const TextStyle(color: Colors.black38),
                    prefixIcon: const Icon(Icons.search, color: Colors.black38),
                    // Clear button only when there's text.
                    suffixIcon: ValueListenableBuilder(
                      valueListenable: search,
                      builder: (_, value, _) => value.text.isEmpty
                          ? const SizedBox.shrink()
                          : IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                search.clear();
                                onSearch('');
                              },
                            ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
