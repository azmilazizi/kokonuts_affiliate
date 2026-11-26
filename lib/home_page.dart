import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'api.dart';
import 'config.dart';
import 'models.dart';
import 'search.dart';
import 'widgets/buy_sheet.dart';
import 'widgets/product_card.dart';
import 'widgets/store_header.dart';

/// The one and only screen.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double _maxWidth = 480;
  static const double _gap = 8;

  // null while loading; set once loaded. _error set if loading failed.
  Catalog? _catalog;
  PublicSettings _settings = const PublicSettings(
    title: 'Kokonuts Affiliate Store',
    description:
        'Find the products from our videos by entering the item number below.',
  );
  Object? _error;

  // Pre-fill from the URL, e.g. affiliate.kokonuts.my/?q=23
  final _search = TextEditingController(
    text: Uri.base.queryParameters['q'] ?? '',
  );
  int? _categoryId; // null = all
  int _tab = 0; // 0 = Products, 1 = Categories

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _catalog = null;
      _error = null;
    });
    try {
      final c = await loadCatalog();
      PublicSettings s;
      try {
        s = await loadPublicSettings();
      } catch (_) {
        s = _settings;
      }
      if (mounted) {
        setState(() {
          _catalog = c;
          _settings = s;
        });
      }
    } catch (e) {
      debugPrint('loadCatalog failed: $e');
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Darker grey outside the centred column on desktop.
      backgroundColor: const Color(0xFFE4E4E4),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: ColoredBox(
            color: const Color(0xFFF5F5F5),
            child: LayoutBuilder(
              builder: (context, box) => CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: StoreHeader(
                      itemCount: _catalog?.items.length ?? 0,
                      title: _settings.title,
                      description: _settings.description,
                      shopeeCount:
                          _catalog?.items
                              .where((i) => i.shopeeUrl != null)
                              .length ??
                          0,
                      tiktokCount:
                          _catalog?.items
                              .where((i) => i.tiktokUrl != null)
                              .length ??
                          0,
                      search: _search,
                      // Typing always jumps back to the product grid.
                      onSearch: (_) => setState(() => _tab = 0),
                    ),
                  ),
                  SliverToBoxAdapter(child: _tabs()),
                  ..._body(box.maxWidth),
                  const SliverToBoxAdapter(child: _Footer()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Tabs ----------

  Widget _tabs() {
    Widget tab(String label, int index) {
      final active = _tab == index;
      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _tab = index),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: active ? kOrange : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: active ? kOrange : Colors.black87,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.white,
      child: Row(children: [tab('Products', 0), tab('Categories', 1)]),
    );
  }

  // ---------- Body (depends on state) ----------

  List<Widget> _body(double width) {
    if (_error != null) return [SliverFillRemaining(child: _errorView())];

    final catalog = _catalog;
    if (catalog != null && _tab == 1) return [_categoryList(catalog)];

    // Tile height = square image (tile width) + text area under it.
    final tileWidth = (math.min(width, _maxWidth) - _gap * 3) / 2;
    final grid = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: _gap,
      crossAxisSpacing: _gap,
      mainAxisExtent: tileWidth + kCardTextHeight,
    );
    const padding = EdgeInsets.all(_gap);

    if (catalog == null) {
      // Loading: 6 grey placeholder cards.
      return [
        SliverPadding(
          padding: padding,
          sliver: SliverGrid(
            gridDelegate: grid,
            delegate: SliverChildBuilderDelegate(
              (_, _) => const ProductCardSkeleton(),
              childCount: 6,
            ),
          ),
        ),
      ];
    }

    final items = filterItems(
      catalog.items,
      _search.text,
      categoryId: _categoryId,
    );
    final highlightNo = exactNumber(_search.text);

    return [
      if (_categoryId != null)
        SliverToBoxAdapter(child: _categoryChip(catalog)),
      if (items.isEmpty)
        const SliverToBoxAdapter(child: _EmptyView())
      else
        SliverPadding(
          padding: padding,
          sliver: SliverGrid(
            gridDelegate: grid,
            delegate: SliverChildBuilderDelegate(
              (context, i) => ProductCard(
                item: items[i],
                highlighted: items[i].itemNo == highlightNo,
                onTap: () => openItem(context, items[i]),
              ),
              childCount: items.length,
            ),
          ),
        ),
    ];
  }

  /// Shows which category is active, with an ✕ to clear it.
  Widget _categoryChip(Catalog catalog) {
    final name = catalog.categories
        .where((c) => c.id == _categoryId)
        .map((c) => c.name)
        .firstOrNull;
    return Padding(
      padding: const EdgeInsets.fromLTRB(_gap, _gap, _gap, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InputChip(
          label: Text(name ?? 'Category'),
          onDeleted: () => setState(() => _categoryId = null),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _categoryList(Catalog catalog) {
    // Count items per category so the list shows e.g. "Rumah (12)".
    final counts = <int?, int>{};
    for (final i in catalog.items) {
      counts[i.categoryId] = (counts[i.categoryId] ?? 0) + 1;
    }

    Widget row(String label, int? id, int count) => ListTile(
      tileColor: Colors.white,
      title: Text(label),
      trailing: Text('$count', style: const TextStyle(color: Colors.black45)),
      selected: _categoryId == id,
      selectedColor: kOrange,
      onTap: () => setState(() {
        _categoryId = id;
        _tab = 0;
      }),
    );

    return SliverList.list(
      children: [
        const SizedBox(height: _gap),
        row('All products', null, catalog.items.length),
        for (final c in catalog.categories) ...[
          const Divider(height: 1),
          row(c.name, c.id, counts[c.id] ?? 0),
        ],
      ],
    );
  }

  Widget _errorView() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, size: 40, color: Colors.black38),
          const SizedBox(height: 12),
          const Text('Unable to load products.', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kOrange),
            onPressed: _load,
            child: const Text('Try again'),
          ),
        ],
      ),
    ),
  );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
    child: Column(
      children: [
        Icon(Icons.search_off, size: 40, color: Colors.black38),
        SizedBox(height: 12),
        Text(
          'Item not found. Try another number.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
    child: Text(
      'Affiliate links may earn us a small commission. Prices are shown for '
      'reference only.\n© ${DateTime.now().year} Kokonuts',
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 12, color: Colors.black45),
    ),
  );
}
