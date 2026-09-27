import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/guidance.dart';
import 'package:mobile/core/widgets/ride_map.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// The driver's map while driving (mockup screens 5 and 7). It follows the
/// taxi along the road by default, like the Mapbox Navigation SDK's
/// following camera; the driver can switch to the whole route and back.
class DrivingMap extends StatefulWidget {
  const DrivingMap({
    required this.origin,
    required this.destination,
    required this.guidance,
    required this.bottomPadding,
    super.key,
  });

  final Coordinates origin;
  final Coordinates destination;

  // Null until the route and the first position are known.
  final Guidance? guidance;

  // Height of the bottom panel over the map.
  final double bottomPadding;

  @override
  State<DrivingMap> createState() => _DrivingMapState();
}

class _DrivingMapState extends State<DrivingMap> {
  // Keeps the taxi below the navigation banner.
  static const _bannerPadding = 170.0;

  // While following, keeps the taxi clearly above the bottom panel and the
  // overview button, instead of at the panel's edge.
  static const _followingMargin = 120.0;

  // The switch is a display choice only: it stays in the widget.
  bool _isFollowing = true;

  @override
  Widget build(BuildContext context) {
    final guidance = widget.guidance;
    return Stack(
      children: [
        Positioned.fill(
          child: RideMap(
            origin: widget.origin,
            bottomPadding: _isFollowing
                ? widget.bottomPadding + _followingMargin
                : widget.bottomPadding,
            topPadding: _bannerPadding,
            driverPosition: guidance?.position,
            destination: widget.destination,
            remainingRoute: guidance?.remainingPath,
            following: _isFollowing ? guidance : null,
            showsDevicePosition: false,
          ),
        ),
        Positioned(
          right: 16,
          bottom: widget.bottomPadding + 12,
          child: SecondaryButton(
            onPressed: () => setState(() => _isFollowing = !_isFollowing),
            leading: Icon(
              _isFollowing ? Icons.route_outlined : Icons.navigation_outlined,
              size: 18,
            ),
            child: Text(_isFollowing ? 'Vue d’ensemble' : 'Recentrer'),
          ),
        ),
      ],
    );
  }
}
