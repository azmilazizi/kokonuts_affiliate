import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../models.dart';

/// One link -> open it straight away. Two links -> let the user pick.
Future<void> openItem(BuildContext context, Item item) async {
  final shopee = item.shopeeUrl;
  final tiktok = item.tiktokUrl;

  if (shopee != null && tiktok != null) {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${item.itemNo}: ${item.name}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: kOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _open(shopee),
                child: const Text('Beli di Shopee'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _open(tiktok),
                child: const Text('Beli di TikTok Shop'),
              ),
            ],
          ),
        ),
      ),
    );
  } else if (shopee != null || tiktok != null) {
    await _open((shopee ?? tiktok)!);
  }
}

/// '_self' = same tab. In TikTok/FB/IG in-app browsers a new tab often gets
/// blocked or opens a blank page; same tab lets the Shopee/TikTok page (or
/// app deep link) take over normally, and Back returns to this list.
Future<void> _open(String url) =>
    launchUrl(Uri.parse(url), webOnlyWindowName: '_self');
