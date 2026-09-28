import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    show
        FollowPuckViewportState,
        FollowPuckViewportStateBearingConstant,
        MbxEdgeInsets,
        ViewportState,
        WidgetViewportAnimation;
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Round button over a map that brings it back to the device's position.
/// Mapbox has no built-in one: the map's state animates its viewport with
/// [RecenterOnDevice.recenterOnDevice].
class RecenterButton extends StatelessWidget {
  const RecenterButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SecondaryButton(
      density: ButtonDensity.icon,
      shape: ButtonShape.circle,
      onPressed: onPressed,
      child: const Icon(Icons.my_location),
    );
  }
}

extension RecenterOnDevice on State {
  /// Mapbox's "Animate to User" example, from the ViewportState
  /// documentation, kept flat with the north up like the home maps: the
  /// device's position is centered above a bottom panel of [bottomPadding].
  /// [setViewport] must store the viewport given to MapWidget.
  void recenterOnDevice(
    void Function(ViewportState viewport) setViewport, {
    required double zoom,
    required double bottomPadding,
  }) {
    // ignore: experimental_member_use, the documented way to animate to the user.
    setStateWithViewportAnimation(() {
      setViewport(
        FollowPuckViewportState(
          zoom: zoom,
          bearing: const FollowPuckViewportStateBearingConstant(0),
          pitch: 0,
          padding: MbxEdgeInsets(
            top: 0,
            left: 0,
            bottom: bottomPadding,
            right: 0,
          ),
        ),
      );
    });
  }
}
