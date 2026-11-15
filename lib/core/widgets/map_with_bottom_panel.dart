import 'package:flutter/scheduler.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// A full-screen map with a [panel] docked at the bottom, and the panel's real
/// height given to the map, so it frames what it shows above the panel and
/// not under it. The height is measured, never guessed: the panel changes
/// with its content, the text size and the screen. Spec
/// taxi-vroom-api/docs/specs/cadrage-de-la-carte.md.
///
/// Flutter's SizeChangedLayoutNotifier does not notify the first layout
/// (framework source, size_changed_layout_notifier.dart), so the height is
/// also read once after the first frame.
class MapWithBottomPanel extends StatefulWidget {
  const MapWithBottomPanel({
    required this.mapBuilder,
    required this.panel,
    this.overlays = const [],
    super.key,
  });

  /// Builds the map from the panel's height, 0 until it is measured.
  final Widget Function(BuildContext context, double panelHeight) mapBuilder;

  /// The panel itself, usually a `BottomPanel`.
  final Widget panel;

  /// Over the map, under the panel (a banner, a pill).
  final List<Widget> overlays;

  @override
  State<MapWithBottomPanel> createState() => _MapWithBottomPanelState();
}

class _MapWithBottomPanelState extends State<MapWithBottomPanel> {
  // Under this, a change is a rounding, not a new size.
  static const _minChange = 0.5;

  final GlobalKey _panelKey = GlobalKey();

  // A display measure, so it stays in the widget.
  double _panelHeight = 0;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    if (!mounted) return;
    final height = _panelKey.currentContext?.size?.height;
    if (height == null || (height - _panelHeight).abs() < _minChange) return;
    setState(() => _panelHeight = height);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: widget.mapBuilder(context, _panelHeight)),
        ...widget.overlays,
        Align(
          alignment: Alignment.bottomCenter,
          child: NotificationListener<SizeChangedLayoutNotification>(
            // Sent while laying out: measure after the frame.
            onNotification: (_) {
              SchedulerBinding.instance.addPostFrameCallback((_) => _measure());
              return false;
            },
            child: SizeChangedLayoutNotifier(
              child: KeyedSubtree(key: _panelKey, child: widget.panel),
            ),
          ),
        ),
      ],
    );
  }
}
