import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/paged_list.dart';

PagedList<String> _page(
  List<String> items, {
  required int count,
  int page = 0,
}) => PagedList(items: items, count: count, page: page);

String _idOf(String item) => item;

void main() {
  group('PagedList', () {
    test('has more while it holds fewer items than the total', () {
      // Arrange
      final list = _page(['a', 'b'], count: 5);

      // Act
      final hasMore = list.hasMore;

      // Assert
      expect(hasMore, isTrue);
    });

    test('has no more once every item is loaded', () {
      // Arrange
      final list = _page(['a', 'b'], count: 2);

      // Act
      final hasMore = list.hasMore;

      // Assert
      expect(hasMore, isFalse);
    });

    test('has no more when the passenger has no item at all', () {
      // Arrange
      final list = _page([], count: 0);

      // Act
      final hasMore = list.hasMore;

      // Assert
      expect(hasMore, isFalse);
    });

    test('asks for the page after the last one it holds', () {
      // Arrange
      final list = _page(['a'], count: 3, page: 2);

      // Act
      final nextPage = list.nextPage;

      // Assert
      expect(nextPage, 3);
    });

    test('adds the next page after the items it already holds', () {
      // Arrange
      final first = _page(['a', 'b'], count: 4);
      final second = _page(['c', 'd'], count: 4, page: 1);

      // Act
      final merged = first.appended(second, idOf: _idOf);

      // Assert
      expect(merged.items, ['a', 'b', 'c', 'd']);
      expect(merged.page, 1);
      expect(merged.hasMore, isFalse);
    });

    test('drops an item of the next page it already holds', () {
      // Arrange: a ride was added meanwhile, so "b" moved to the next page.
      final first = _page(['a', 'b'], count: 5);
      final second = _page(['b', 'c'], count: 5, page: 1);

      // Act
      final merged = first.appended(second, idOf: _idOf);

      // Assert
      expect(merged.items, ['a', 'b', 'c']);
    });

    test('takes the total of the latest page', () {
      // Arrange: a ride was cancelled meanwhile.
      final first = _page(['a', 'b'], count: 4);
      final second = _page(['c'], count: 3, page: 1);

      // Act
      final merged = first.appended(second, idOf: _idOf);

      // Assert
      expect(merged.hasMore, isFalse);
    });

    test('stops asking when the next page is empty', () {
      // Arrange: the server still counts more items than it gives.
      final first = _page(['a', 'b'], count: 5);
      final second = _page([], count: 5, page: 1);

      // Act
      final merged = first.appended(second, idOf: _idOf);

      // Assert
      expect(merged.items, ['a', 'b']);
      expect(merged.hasMore, isFalse);
    });
  });
}
