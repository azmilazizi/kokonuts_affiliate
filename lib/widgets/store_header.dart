import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../config.dart';
import 'net_image.dart';

/// Blurred cover + avatar + name + item count + tagline + search field.
class StoreHeader extends StatelessWidget {
  final int itemCount;
  final TextEditingController search;
  final ValueChanged<String> onSearch;

  const StoreHeader({
    super.key,
    required this.itemCount,
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
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: SizedBox.square(
                          dimension: 72,
                          child: NetImage(Config.avatar),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Config.name,
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
                            child: Text(
                              '$itemCount item',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  Config.tagline,
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
                    hintText: 'Cari nombor atau nama barang',
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
