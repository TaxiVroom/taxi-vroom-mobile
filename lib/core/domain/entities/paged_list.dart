import 'package:equatable/equatable.dart';

// The pages of a list loaded so far, e.g. the passenger's rides. Spec
// taxi-vroom-api/docs/specs/mes-courses-par-pages.md.
class PagedList<T> extends Equatable {
  const PagedList({
    required this.items,
    required this.count,
    required this.page,
  });

  final List<T> items;

  // How many items the passenger has in all, as the API counts them.
  final int count;

  // The last page loaded, the first one is 0.
  final int page;

  bool get hasMore => items.length < count;

  int get nextPage => page + 1;

  // The next page goes after the items already held. A ride added meanwhile
  // pushes one item onto the next page: an item already held is dropped. An
  // empty page ends the list, even if the total says more: asking again
  // would never stop.
  PagedList<T> appended(
    PagedList<T> next, {
    required String Function(T item) idOf,
  }) {
    final heldIds = {for (final item in items) idOf(item)};
    final merged = [
      ...items,
      for (final item in next.items)
        if (!heldIds.contains(idOf(item))) item,
    ];
    return PagedList(
      items: merged,
      count: next.items.isEmpty ? merged.length : next.count,
      page: next.page,
    );
  }

  @override
  List<Object?> get props => [items, count, page];
}
