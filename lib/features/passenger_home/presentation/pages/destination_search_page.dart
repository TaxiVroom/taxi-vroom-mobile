import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/distance_formatter.dart';
import 'package:mobile/core/widgets/place_list_tile.dart';
import 'package:mobile/core/widgets/search_text_field.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/usecases/find_place_at_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_recent_destinations_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/select_destination_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/suggest_destinations_usecase.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/destination_search_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/passenger_flow_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/recent_destinations_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/place_picker_sheet.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/place_suggestions.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 4: the pickup, "Position actuelle" until another is chosen,
/// then the destination; each field picks a live suggestion. Spec
/// point-de-prise-en-charge.md.
class DestinationSearchPage extends StatelessWidget {
  const DestinationSearchPage({
    required this.origin,
    required this.pickupPlace,
    required this.loadRecentDestinationsUseCase,
    required this.suggestDestinationsUseCase,
    required this.selectDestinationUseCase,
    required this.findPlaceAtUseCase,
    super.key,
  });

  // Where the phone is: the suggestions come from around it.
  final Coordinates origin;

  // Null means "Position actuelle".
  final Place? pickupPlace;
  final LoadRecentDestinationsUseCase loadRecentDestinationsUseCase;
  final SuggestDestinationsUseCase suggestDestinationsUseCase;
  final SelectDestinationUseCase selectDestinationUseCase;
  final FindPlaceAtUseCase findPlaceAtUseCase;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DestinationSearchBloc(
            origin: origin,
            suggestDestinationsUseCase: suggestDestinationsUseCase,
            selectDestinationUseCase: selectDestinationUseCase,
          ),
        ),
        // Read each time the screen opens: the ride just completed shows.
        BlocProvider(
          create: (_) => RecentDestinationsBloc(
            loadRecentDestinationsUseCase: loadRecentDestinationsUseCase,
          )..add(const RecentDestinationsRequested()),
        ),
      ],
      child: _DestinationSearchView(
        origin: origin,
        pickupPlace: pickupPlace,
        findPlaceAtUseCase: findPlaceAtUseCase,
      ),
    );
  }
}

class _DestinationSearchView extends StatefulWidget {
  const _DestinationSearchView({
    required this.origin,
    required this.pickupPlace,
    required this.findPlaceAtUseCase,
  });

  final Coordinates origin;
  final Place? pickupPlace;
  final FindPlaceAtUseCase findPlaceAtUseCase;

  @override
  State<_DestinationSearchView> createState() => _DestinationSearchViewState();
}

class _DestinationSearchViewState extends State<_DestinationSearchView> {
  static const _currentPosition = 'Position actuelle';

  // The pickup kept by the flow: "Position actuelle", or a place's name.
  late bool _isCurrentPosition = widget.pickupPlace == null;
  late String _pickupName = widget.pickupPlace?.name ?? _currentPosition;
  late final _pickupController = TextEditingController(text: _pickupName);
  final _destinationController = TextEditingController();
  final _pickupFocus = FocusNode();
  final _destinationFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _pickupFocus.addListener(_onPickupFocusChanged);
    _destinationFocus.addListener(_onDestinationFocusChanged);
  }

  @override
  void dispose() {
    // First: leaving the screen takes the focus away, and must not write in
    // a disposed field.
    _pickupFocus.removeListener(_onPickupFocusChanged);
    _destinationFocus.removeListener(_onDestinationFocusChanged);
    _pickupController.dispose();
    _destinationController.dispose();
    _pickupFocus.dispose();
    _destinationFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DestinationSearchBloc, DestinationSearchState>(
          listenWhen: (previous, current) =>
              current.selectedPickup != null &&
              current.selectedPickup != previous.selectedPickup,
          listener: (context, state) => _onPickupChosen(state.selectedPickup),
        ),
        BlocListener<DestinationSearchBloc, DestinationSearchState>(
          listenWhen: (previous, current) =>
              current.selectedDestination != null &&
              current.selectedDestination != previous.selectedDestination,
          listener: (context, state) => context.read<PassengerFlowBloc>().add(
            PassengerDestinationSelected(
              destination: state.selectedDestination!,
            ),
          ),
        ),
      ],
      child: PopScope(
        canPop: false,
        // The hardware back goes through the flow bloc, not the Navigator.
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _onBackPressed();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          headers: [
            AppBar(
              leading: [
                GhostButton(
                  density: ButtonDensity.icon,
                  onPressed: _onBackPressed,
                  child: const Icon(Icons.arrow_back),
                ),
              ],
              title: const Text('Votre trajet'),
              backgroundColor: Colors.white,
            ),
          ],
          child: Padding(
            // Room above for the focus ring of the first field.
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTrip(),
                const SizedBox(height: 12),
                _buildOptions(),
                const SizedBox(height: 8),
                Expanded(
                  child:
                      BlocBuilder<
                        DestinationSearchBloc,
                        DestinationSearchState
                      >(
                        builder: (context, state) => _buildResults(state),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // The usual trip block: a dot for the pickup and a square for the
  // destination, joined by a line, so it reads "from here to there".
  Widget _buildTrip() {
    final showsCurrentPosition =
        _isCurrentPosition && _pickupController.text == _currentPosition;
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.ink,
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 2, height: 42, color: AppColors.border),
            Container(width: 8, height: 8, color: AppColors.ink),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          // The spinner of the field being searched only.
          child: BlocBuilder<DestinationSearchBloc, DestinationSearchState>(
            buildWhen: (previous, current) =>
                previous.isLoading != current.isLoading ||
                previous.activeField != current.activeField,
            builder: (context, state) => Column(
              children: [
                SearchTextField(
                  controller: _pickupController,
                  focusNode: _pickupFocus,
                  placeholder: 'Adresse de départ',
                  isLoading:
                      state.isLoading &&
                      state.activeField == SearchField.pickup,
                  // A value, not a hint: the pickup is chosen.
                  style: showsCurrentPosition
                      ? const TextStyle(
                          color: AppColors.plateBlue,
                          fontWeight: FontWeight.w600,
                        )
                      : null,
                  onChanged: (query) {
                    setState(() {});
                    _onQueryChanged(query);
                  },
                ),
                const SizedBox(height: 8),
                SearchTextField(
                  controller: _destinationController,
                  focusNode: _destinationFocus,
                  placeholder: 'Où allez-vous ?',
                  isLoading:
                      state.isLoading &&
                      state.activeField == SearchField.destination,
                  autofocus: true,
                  onChanged: _onQueryChanged,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // The pickup time is chosen on the taxi choice only (spec
  // heure-de-prise-en-charge.md).
  Widget _buildOptions() {
    return Row(
      children: [
        // Its own context, inside this page's Scaffold: the sheet opens in
        // this page's drawer overlay, not in the home's below (the same fix
        // as SavedPlacePage).
        Builder(
          builder: (buttonContext) => OutlineButton(
            onPressed: () => _onMapPressed(buttonContext),
            leading: const Icon(Icons.place_outlined, size: 16),
            child: const Text('Choisir sur la carte'),
          ),
        ),
      ],
    );
  }

  // For the field being typed in: the pickup, or the destination.
  Future<void> _onMapPressed(BuildContext buttonContext) async {
    final flowBloc = context.read<PassengerFlowBloc>();
    final isPickup =
        context.read<DestinationSearchBloc>().state.activeField ==
        SearchField.pickup;
    final place = await openPlacePickerSheet(
      buttonContext,
      initial: flowBloc.state.pickupPlace?.coordinates ?? widget.origin,
      title: isPickup ? 'Choisir le départ' : 'Choisir la destination',
      confirmLabel: 'Confirmer',
      findPlaceAtUseCase: widget.findPlaceAtUseCase,
    );
    if (place == null || !mounted) return;
    if (isPickup) {
      _onPickupChosen(place);
      return;
    }
    flowBloc.add(PassengerDestinationSelected(destination: place));
  }

  // For the pickup, "Position actuelle" always comes first.
  Widget _buildResults(DestinationSearchState state) {
    final suggestions = _buildSuggestions(state);
    if (state.activeField == SearchField.destination) return suggestions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlaceListTile(
          icon: Icons.my_location,
          title: _currentPosition,
          subtitle: 'Là où vous êtes',
          onPressed: () => _onPickupChosen(null),
          // The pickup kept: the passenger sees which one is chosen.
          trailing: _isCurrentPosition
              ? const Icon(Icons.check, color: AppColors.plateBlue)
              : null,
        ),
        Expanded(child: suggestions),
      ],
    );
  }

  Widget _buildSuggestions(DestinationSearchState state) {
    if (state.query.trim().isNotEmpty) return PlaceSuggestions(state: state);
    // A past destination is not a pickup: shown for the destination only.
    if (state.activeField == SearchField.pickup) return const SizedBox.shrink();
    return BlocBuilder<RecentDestinationsBloc, RecentDestinationsState>(
      builder: (context, recentState) => switch (recentState) {
        RecentDestinationsLoading() => const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        RecentDestinationsReady(:final destinations) => ListView(
          children: [
            for (final destination in destinations)
              PlaceListTile(
                icon: Icons.history,
                title: destination.name,
                subtitle: formatDistanceKm(
                  widget.origin.distanceTo(destination.coordinates) / 1000,
                ),
                // Straight to the taxi choice, like a suggestion chosen.
                onPressed: () => context.read<PassengerFlowBloc>().add(
                  PassengerDestinationSelected(
                    destination: destination.toDestination(),
                  ),
                ),
              ),
          ],
        ),
      },
    );
  }

  void _onPickupFocusChanged() {
    if (_pickupFocus.hasFocus) {
      // All selected: typing replaces the pickup kept.
      _pickupController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _pickupController.text.length,
      );
      context.read<DestinationSearchBloc>().add(
        const DestinationSearchFieldFocused(field: SearchField.pickup),
      );
      // "Position actuelle" is not something to search for.
      _onQueryChanged(_isCurrentPosition ? '' : _pickupController.text);
      return;
    }
    // Typed but not chosen: the field shows the pickup kept again.
    setState(() => _pickupController.text = _pickupName);
  }

  // Its own text is searched again: the suggestions shown were the
  // pickup's.
  void _onDestinationFocusChanged() {
    if (!_destinationFocus.hasFocus) return;
    context.read<DestinationSearchBloc>().add(
      const DestinationSearchFieldFocused(field: SearchField.destination),
    );
    _onQueryChanged(_destinationController.text);
  }

  // Null means "Position actuelle". The destination is asked next.
  void _onPickupChosen(Place? pickupPlace) {
    context.read<PassengerFlowBloc>().add(
      PassengerPickupPlaceChanged(pickupPlace: pickupPlace),
    );
    setState(() {
      _isCurrentPosition = pickupPlace == null;
      _pickupName = pickupPlace?.name ?? _currentPosition;
      _pickupController.text = _pickupName;
    });
    _destinationFocus.requestFocus();
  }

  void _onQueryChanged(String query) {
    context.read<DestinationSearchBloc>().add(
      DestinationQueryChanged(query: query),
    );
  }

  void _onBackPressed() {
    context.read<PassengerFlowBloc>().add(const PassengerFlowBackPressed());
  }
}
