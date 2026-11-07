import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/distance_formatter.dart';
import 'package:mobile/core/widgets/place_list_tile.dart';
import 'package:mobile/core/widgets/search_text_field.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/place_suggestion.dart';
import 'package:mobile/features/passenger_home/domain/entities/recent_destination.dart';
import 'package:mobile/features/passenger_home/domain/usecases/find_place_at_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/select_destination_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/suggest_destinations_usecase.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/destination_search_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/passenger_flow_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/pickup_time_chip.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/place_picker_sheet.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 4: the pickup, "Position actuelle" until another is chosen,
/// then the destination; each field picks a live suggestion. Spec
/// point-de-prise-en-charge.md.
class DestinationSearchPage extends StatelessWidget {
  const DestinationSearchPage({
    required this.origin,
    required this.pickupPlace,
    required this.recentDestinations,
    required this.suggestDestinationsUseCase,
    required this.selectDestinationUseCase,
    required this.findPlaceAtUseCase,
    super.key,
  });

  // Where the phone is: the suggestions come from around it.
  final Coordinates origin;

  // Null means "Position actuelle".
  final Place? pickupPlace;
  final List<RecentDestination> recentDestinations;
  final SuggestDestinationsUseCase suggestDestinationsUseCase;
  final SelectDestinationUseCase selectDestinationUseCase;
  final FindPlaceAtUseCase findPlaceAtUseCase;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DestinationSearchBloc(
        origin: origin,
        suggestDestinationsUseCase: suggestDestinationsUseCase,
        selectDestinationUseCase: selectDestinationUseCase,
      ),
      child: _DestinationSearchView(
        origin: origin,
        pickupPlace: pickupPlace,
        recentDestinations: recentDestinations,
        findPlaceAtUseCase: findPlaceAtUseCase,
      ),
    );
  }
}

class _DestinationSearchView extends StatefulWidget {
  const _DestinationSearchView({
    required this.origin,
    required this.pickupPlace,
    required this.recentDestinations,
    required this.findPlaceAtUseCase,
  });

  final Coordinates origin;
  final Place? pickupPlace;
  final List<RecentDestination> recentDestinations;
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

  Widget _buildOptions() {
    return Row(
      children: [
        const PickupTimeChip(),
        const SizedBox(width: 8),
        OutlineButton(
          onPressed: _onMapPressed,
          leading: const Icon(Icons.place_outlined, size: 16),
          child: const Text('Choisir sur la carte'),
        ),
      ],
    );
  }

  // For the field being typed in: the pickup, or the destination.
  Future<void> _onMapPressed() async {
    final flowBloc = context.read<PassengerFlowBloc>();
    final isPickup =
        context.read<DestinationSearchBloc>().state.activeField ==
        SearchField.pickup;
    final place = await openPlacePickerSheet(
      context,
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
    if (state.query.trim().isEmpty) {
      return ListView(
        children: [
          for (final destination in widget.recentDestinations)
            PlaceListTile(
              icon: Icons.history,
              title: destination.name,
              subtitle:
                  '${destination.address}, '
                  '${formatDistanceKm(destination.distanceKm)}',
              onPressed: () => _searchFor(destination.name),
            ),
        ],
      );
    }

    final failureMessage = state.failureMessage;
    if (failureMessage != null) return _buildMessage(failureMessage);
    // Nothing yet: the spinner is in the field.
    if (state.suggestions.isEmpty) {
      return state.isLoading
          ? const SizedBox.shrink()
          : _buildMessage('Aucune adresse trouvée');
    }

    return SearchResults(
      isLoading: state.isLoading,
      child: ListView(
        children: [
          for (final suggestion in state.suggestions)
            PlaceListTile(
              icon: Icons.place_outlined,
              title: suggestion.name,
              subtitle: _suggestionDetail(suggestion),
              onPressed: () => context.read<DestinationSearchBloc>().add(
                DestinationSuggestionSelected(suggestion: suggestion),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(message, style: const TextStyle(color: AppColors.muted)),
    );
  }

  String _suggestionDetail(PlaceSuggestion suggestion) {
    final distanceKm = suggestion.distanceKm;
    return distanceKm == null
        ? suggestion.address
        : '${suggestion.address}, ${formatDistanceKm(distanceKm)}';
  }

  void _searchFor(String query) {
    final activeField = context.read<DestinationSearchBloc>().state.activeField;
    (activeField == SearchField.pickup
                ? _pickupController
                : _destinationController)
            .text =
        query;
    _onQueryChanged(query);
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
