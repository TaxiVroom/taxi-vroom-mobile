import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    show CameraViewportState, MapIdleEventData, MapWidget, MapboxMap;
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/bottom_panel.dart';
import 'package:mobile/core/widgets/coordinates_mapbox.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/usecases/find_place_at_usecase.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/place_picker_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// A full map with a pin fixed at its center: the passenger moves the map
/// under it, the address shows once the map stops. The place confirmed, or
/// null when closed. Used by "Choisir sur la carte" and "Confirmer le point
/// de prise en charge". shadcn_flutter 0.0.51: openSheet, not draggable so
/// the map can be moved, closed by closeDrawer with its result.
Future<Place?> openPlacePickerSheet(
  BuildContext context, {
  required Coordinates initial,
  required String title,
  required String confirmLabel,
  required FindPlaceAtUseCase findPlaceAtUseCase,
}) => openSheet<Place>(
  context: context,
  position: OverlayPosition.bottom,
  builder: (_) => BlocProvider(
    create: (_) =>
        PlacePickerBloc(findPlaceAtUseCase: findPlaceAtUseCase)
          ..add(PlacePickerCenterChanged(center: initial)),
    child: _PlacePickerSheet(
      initial: initial,
      title: title,
      confirmLabel: confirmLabel,
    ),
  ),
);

class _PlacePickerSheet extends StatefulWidget {
  const _PlacePickerSheet({
    required this.initial,
    required this.title,
    required this.confirmLabel,
  });

  final Coordinates initial;
  final String title;
  final String confirmLabel;

  @override
  State<_PlacePickerSheet> createState() => _PlacePickerSheetState();
}

class _PlacePickerSheetState extends State<_PlacePickerSheet> {
  // Close enough to tell the street and the building.
  static const _zoom = 17.0;
  static const _pinSize = 44.0;

  // Created once: MapWidget moves the camera back to a new viewport on
  // every rebuild, which would undo the passenger's moves.
  late final _viewport = CameraViewportState(
    center: widget.initial.toPoint(),
    zoom: _zoom,
  );

  MapboxMap? _map;

  // The map also goes idle once its tiles are drawn, without moving: the
  // same center is not looked up again.
  late Coordinates _lastCenter = widget.initial;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.9,
      child: Stack(
        children: [
          Positioned.fill(
            child: MapWidget(
              viewport: _viewport,
              onMapCreated: (map) => _map = map,
              onMapIdleListener: _onMapIdle,
            ),
          ),
          // The tip of the pin on the center of the map.
          IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -_pinSize / 2),
                child: const Icon(
                  Icons.location_on,
                  size: _pinSize,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: SecondaryButton(
              density: ButtonDensity.icon,
              onPressed: () => closeDrawer<Place>(context),
              child: const Icon(Icons.close),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomPanel(
              child: BlocBuilder<PlacePickerBloc, PlacePickerState>(
                builder: _buildPanel,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel(BuildContext context, PlacePickerState state) {
    final place = state.place;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            place?.name ?? 'Recherche de l’adresse…',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            place?.address ?? '',
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            onPressed: place == null || state.isLoading
                ? null
                : () => closeDrawer<Place>(context, place),
            alignment: Alignment.center,
            child: Text(widget.confirmLabel),
          ),
        ],
      ),
    );
  }

  // Not on each frame of the move: only once the map stopped.
  void _onMapIdle(MapIdleEventData _) => unawaited(_findCenter());

  Future<void> _findCenter() async {
    final map = _map;
    if (map == null) return;
    final position = (await map.getCameraState()).center.coordinates;
    final center = Coordinates(
      latitude: position.lat.toDouble(),
      longitude: position.lng.toDouble(),
    );
    if (!mounted || center == _lastCenter) return;
    _lastCenter = center;
    context.read<PlacePickerBloc>().add(
      PlacePickerCenterChanged(center: center),
    );
  }
}
