/// Data classes matching GET {API_BASE}/affiliate/public/items.
library;

class Item {
  final int itemNo;
  final String name;
  final String imageUrl;
  final double? price;
  final double? discountPercent;
  final int? soldCount;
  final String? videoUrl;
  final int? categoryId;
  final String? shopeeUrl;
  final String? tiktokUrl;

  const Item({
    required this.itemNo,
    required this.name,
    required this.imageUrl,
    this.price,
    this.discountPercent,
    this.soldCount,
    this.videoUrl,
    this.categoryId,
    this.shopeeUrl,
    this.tiktokUrl,
  });

  factory Item.fromJson(Map<String, dynamic> j) {
    final links = (j['links'] as Map<String, dynamic>?) ?? const {};
    return Item(
      // `num` then toInt/toDouble: PHP json_encode may send 30 instead of 30.0
      // (or even "145" as a string), so be forgiving.
      itemNo: _toInt(j['item_no']) ?? 0,
      name: (j['name'] ?? '').toString(),
      imageUrl: (j['image_url'] ?? '').toString(),
      price: _toDouble(j['price']),
      discountPercent: _toDouble(j['discount_percent']),
      soldCount: _toInt(j['sold_count']),
      videoUrl: _nonEmpty(j['video_url']),
      categoryId: _toInt(j['category_id']),
      shopeeUrl: _nonEmpty(links['shopee']),
      tiktokUrl: _nonEmpty(links['tiktok']),
    );
  }
}

class Category {
  final int id;
  final String name;

  const Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> j) =>
      Category(id: _toInt(j['id']) ?? 0, name: (j['name'] ?? '').toString());
}

class Catalog {
  final List<Item> items;
  final List<Category> categories;

  const Catalog({required this.items, required this.categories});

  factory Catalog.fromJson(Map<String, dynamic> j) => Catalog(
    items: ((j['items'] as List?) ?? const [])
        .map((e) => Item.fromJson(e as Map<String, dynamic>))
        .toList(),
    categories: ((j['categories'] as List?) ?? const [])
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class PublicSettings {
  final String title;
  final String description;

  const PublicSettings({required this.title, required this.description});

  factory PublicSettings.fromJson(Map<String, dynamic> j) => PublicSettings(
    title: (j['title'] ?? '').toString(),
    description: (j['description'] ?? '').toString(),
  );
}

int? _toInt(Object? v) =>
    v is num ? v.toInt() : (v is String ? int.tryParse(v) : null);

double? _toDouble(Object? v) =>
    v is num ? v.toDouble() : (v is String ? double.tryParse(v) : null);

String? _nonEmpty(Object? v) {
  final s = v?.toString().trim() ?? '';
  return s.isEmpty ? null : s;
}
