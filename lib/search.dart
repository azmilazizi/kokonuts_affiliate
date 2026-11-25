import 'models.dart';

/// Filters + sorts items for the grid. Pure function so it's easy to test.
///
/// - Always newest first (item_no descending).
/// - [categoryId] null = all categories.
/// - Query of only digits ("23"): the exact item 23 goes first, then any
///   other item whose number or name contains "23".
/// - Any other query: case-insensitive name match (or number contains).
List<Item> filterItems(List<Item> items, String query, {int? categoryId}) {
  final q = query.trim().toLowerCase();

  var result =
      items
          .where((i) => categoryId == null || i.categoryId == categoryId)
          .where(
            (i) =>
                q.isEmpty ||
                i.name.toLowerCase().contains(q) ||
                i.itemNo.toString().contains(q),
          )
          .toList()
        ..sort((a, b) => b.itemNo.compareTo(a.itemNo));

  final exact = exactNumber(query);
  if (exact != null) {
    // Move the exact match to the top without changing the others' order.
    final hit = result.where((i) => i.itemNo == exact).toList();
    result = [...hit, ...result.where((i) => i.itemNo != exact)];
  }
  return result;
}

/// Returns the number if the query is digits only, else null.
int? exactNumber(String query) {
  final q = query.trim();
  return RegExp(r'^\d+$').hasMatch(q) ? int.tryParse(q) : null;
}
