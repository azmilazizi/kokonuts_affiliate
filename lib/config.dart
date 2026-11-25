import 'package:flutter/painting.dart' show Color;

/// Shopee-ish orange used for accents (tabs, price, highlight).
const kOrange = Color(0xFFEE4D2D);

/// App-wide settings. Edit the header details here.
///
/// apiBase / useMock come from --dart-define at build/run time, e.g.
///   flutter run -d chrome --dart-define=USE_MOCK=true
///   flutter build web --release --dart-define=API_BASE=https://crm.kokonuts.my
class Config {
  static const String apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://crm.kokonuts.my',
  );

  static const bool useMock = bool.fromEnvironment('USE_MOCK');

  // ---- Header ----
  static const String name = 'Kokonuts';

  /// Either an asset path ("assets/...") or a full https URL.
  static const String avatar = 'assets/avatar.png';
  static const String cover = 'assets/cover.png';

  static const String tagline =
      'Taip nombor item dari video kat bawah ni 🔍\n'
      'Nanti keluar barang yang korang cari.';
}
