import 'package:flutter_test/flutter_test.dart';
import 'package:kokonuts_affiliate/models.dart';
import 'package:kokonuts_affiliate/search.dart';

Item item(int no, String name, {int? cat}) =>
    Item(itemNo: no, name: name, imageUrl: '', categoryId: cat);

void main() {
  final items = [
    item(5, 'Air Fryer', cat: 1),
    item(230, 'Lampu 23W', cat: 2),
    item(23, 'Vacuum', cat: 2),
    item(123, 'Rak Kasut', cat: 1),
  ];

  test('empty query = all, newest first', () {
    expect(filterItems(items, '').map((i) => i.itemNo), [230, 123, 23, 5]);
  });

  test('digits: exact number first, then partial matches', () {
    expect(filterItems(items, ' 23 ').map((i) => i.itemNo), [23, 230, 123]);
  });

  test('text: case-insensitive name match', () {
    expect(filterItems(items, 'air').map((i) => i.itemNo), [5]);
  });

  test('category filter', () {
    expect(filterItems(items, '', categoryId: 1).map((i) => i.itemNo), [
      123,
      5,
    ]);
  });

  test('exactNumber', () {
    expect(exactNumber('23'), 23);
    expect(exactNumber('23a'), isNull);
    expect(exactNumber(''), isNull);
  });
}
