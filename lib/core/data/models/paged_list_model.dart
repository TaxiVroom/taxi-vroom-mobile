import 'dart:math';

import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/domain/entities/paged_list.dart';

// A page of a paginated list from the API: { data, count, limit, page }.
class PagedListModel<T> {
  const PagedListModel({
    required this.items,
    required this.count,
    required this.page,
  });

  factory PagedListModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) itemFromJson,
  ) => PagedListModel(
    items: [
      for (final item in json['data'] as List<dynamic>)
        itemFromJson(item as Map<String, dynamic>),
    ],
    count: json['count'] as int,
    page: json['page'] as int,
  );

  // One page cut from a whole list, as the API does: for the simulated
  // sources.
  factory PagedListModel.pageOf(List<T> all, {required int page}) {
    final start = min(page * AppConstants.listPageSize, all.length);
    final end = min(start + AppConstants.listPageSize, all.length);
    return PagedListModel(
      items: all.sublist(start, end),
      count: all.length,
      page: page,
    );
  }

  final List<T> items;
  final int count;
  final int page;

  PagedList<D> toDomain<D>(D Function(T item) itemToDomain) => PagedList(
    items: [for (final item in items) itemToDomain(item)],
    count: count,
    page: page,
  );
}
