import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import 'config.dart';
import 'models.dart';

/// Loads the whole catalogue in one go (a few hundred items is tiny).
/// Mock mode reads assets/mock.json so you can work without the CRM.
Future<Catalog> loadCatalog() async {
  if (Config.useMock) {
    final raw = await rootBundle.loadString('assets/mock.json');
    return Catalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  final uri = Uri.parse('${Config.apiBase}/affiliate/public/items');
  final res = await http.get(uri).timeout(const Duration(seconds: 15));
  if (res.statusCode != 200) {
    throw Exception('HTTP ${res.statusCode}');
  }
  // utf8.decode on bodyBytes: if the CRM forgets "charset=utf-8" in the
  // Content-Type, res.body would mangle emoji / special characters.
  return Catalog.fromJson(
    jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
  );
}

Future<PublicSettings> loadPublicSettings() async {
  if (Config.useMock) {
    return const PublicSettings(
      title: 'Kokonuts Affiliate Products',
      description: 'Find the products from our videos by entering the item number below.',
    );
  }
  final uri = Uri.parse('${Config.apiBase}/affiliate/public/settings');
  final res = await http.get(uri).timeout(const Duration(seconds: 15));
  if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
  return PublicSettings.fromJson(
    jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
  );
}
