import 'package:shadcn_flutter/shadcn_flutter.dart';

/// A long list loaded page by page: asks for the next page when little is
/// left below the viewport, and shows a loader under the last item while it
/// comes. Spec taxi-vroom-api/docs/specs/mes-courses-par-pages.md.
///
/// ListView.builder creates the items as they scroll onto the screen.
/// ScrollNotification only comes while scrolling, ScrollMetricsNotification
/// when the content changes: the second one asks for the next page when the
/// items do not fill the viewport.
/// Docs: https://api.flutter.dev/flutter/widgets/ScrollMetricsNotification-class.html
class PagedListView extends StatelessWidget {
  const PagedListView({
    required this.itemCount,
    required this.itemBuilder,
    required this.isLoadingNextPage,
    required this.onNextPage,
    this.padding,
    super.key,
  });

  // The next page is asked when this little content is left below the
  // viewport (about two cards): it arrives before the end is reached.
  static const _nextPageDistance = 400.0;

  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final bool isLoadingNextPage;
  final VoidCallback onNextPage;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _askNextPage(notification.metrics);
        return false;
      },
      child: NotificationListener<ScrollMetricsNotification>(
        onNotification: (notification) {
          _askNextPage(notification.metrics);
          return false;
        },
        child: ListView.builder(
          padding: padding,
          itemCount: itemCount + (isLoadingNextPage ? 1 : 0),
          itemBuilder: (context, index) => index < itemCount
              ? itemBuilder(context, index)
              : const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
        ),
      ),
    );
  }

  void _askNextPage(ScrollMetrics metrics) {
    if (metrics.extentAfter < _nextPageDistance) onNextPage();
  }
}
