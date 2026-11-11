import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/widgets/message_toast.dart';
import 'package:mobile/core/widgets/search_text_field.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';
import 'package:mobile/features/passenger_home/domain/usecases/add_saved_place_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/change_saved_place_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/delete_saved_place_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/find_place_at_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/select_destination_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/suggest_destinations_usecase.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/account_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/destination_search_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/passenger_flow_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/passenger_home_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/saved_place_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/place_picker_sheet.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/place_suggestions.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// "Ajouter votre domicile", "Modifier votre lieu de travail"...: the search
/// of "Où allez-vous ?" with "Choisir sur la carte"; the point chosen is
/// saved, with a loader meanwhile. Spec
/// taxi-vroom-api/docs/specs/maison-et-travail.md.
class SavedPlacePage extends StatelessWidget {
  const SavedPlacePage({
    required this.kind,
    required this.current,
    required this.origin,
    required this.suggestDestinationsUseCase,
    required this.selectDestinationUseCase,
    required this.findPlaceAtUseCase,
    required this.addSavedPlaceUseCase,
    required this.changeSavedPlaceUseCase,
    required this.deleteSavedPlaceUseCase,
    super.key,
  });

  final SavedPlaceKind kind;

  // Null to add it.
  final SavedPlace? current;

  // Where the phone is: the suggestions come from around it.
  final Coordinates origin;
  final SuggestDestinationsUseCase suggestDestinationsUseCase;
  final SelectDestinationUseCase selectDestinationUseCase;
  final FindPlaceAtUseCase findPlaceAtUseCase;
  final AddSavedPlaceUseCase addSavedPlaceUseCase;
  final ChangeSavedPlaceUseCase changeSavedPlaceUseCase;
  final DeleteSavedPlaceUseCase deleteSavedPlaceUseCase;

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
        BlocProvider(
          create: (_) => SavedPlaceBloc(
            kind: kind,
            isSaved: current != null,
            addSavedPlaceUseCase: addSavedPlaceUseCase,
            changeSavedPlaceUseCase: changeSavedPlaceUseCase,
            deleteSavedPlaceUseCase: deleteSavedPlaceUseCase,
          ),
        ),
      ],
      child: _SavedPlaceView(
        kind: kind,
        current: current,
        origin: origin,
        findPlaceAtUseCase: findPlaceAtUseCase,
      ),
    );
  }
}

class _SavedPlaceView extends StatefulWidget {
  const _SavedPlaceView({
    required this.kind,
    required this.current,
    required this.origin,
    required this.findPlaceAtUseCase,
  });

  final SavedPlaceKind kind;
  final SavedPlace? current;
  final Coordinates origin;
  final FindPlaceAtUseCase findPlaceAtUseCase;

  @override
  State<_SavedPlaceView> createState() => _SavedPlaceViewState();
}

class _SavedPlaceViewState extends State<_SavedPlaceView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DestinationSearchBloc, DestinationSearchState>(
          listenWhen: (previous, current) =>
              current.selectedDestination != null &&
              current.selectedDestination != previous.selectedDestination,
          listener: (context, state) =>
              _onPlaceChosen(state.selectedDestination!),
        ),
        BlocListener<SavedPlaceBloc, SavedPlaceState>(
          listener: _onSavedPlaceChanged,
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
              title: Text(_title),
              backgroundColor: Colors.white,
            ),
          ],
          child: BlocBuilder<SavedPlaceBloc, SavedPlaceState>(
            builder: (context, state) => switch (state) {
              SavedPlaceEditing() => _buildSearch(),
              // Saving, deleting, or leaving the screen: nothing to tap.
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ),
      ),
    );
  }

  String get _title {
    final action = widget.current == null ? 'Ajouter' : 'Modifier';
    return switch (widget.kind) {
      SavedPlaceKind.home => '$action votre domicile',
      SavedPlaceKind.work => '$action votre lieu de travail',
    };
  }

  Widget _buildSearch() {
    final current = widget.current;
    return Padding(
      // Room above for the focus ring of the field.
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (current != null) ...[
            Text(
              current.address,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
          ],
          BlocBuilder<DestinationSearchBloc, DestinationSearchState>(
            buildWhen: (previous, current) =>
                previous.isLoading != current.isLoading,
            builder: (context, state) => SearchTextField(
              controller: _controller,
              placeholder: 'Rechercher une adresse',
              isLoading: state.isLoading,
              autofocus: true,
              onChanged: (query) => context.read<DestinationSearchBloc>().add(
                DestinationQueryChanged(query: query),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Its own context, inside this page's Scaffold: the sheet opens
              // in this page's drawer overlay, not in the home's below.
              Builder(
                builder: (buttonContext) => OutlineButton(
                  onPressed: () => _onMapPressed(buttonContext),
                  leading: const Icon(Icons.place_outlined, size: 16),
                  child: const Text('Choisir sur la carte'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<DestinationSearchBloc, DestinationSearchState>(
              builder: (context, state) => state.query.trim().isEmpty
                  ? const SizedBox.shrink()
                  : PlaceSuggestions(state: state),
            ),
          ),
          if (current != null)
            DestructiveButton(
              onPressed: () => context.read<SavedPlaceBloc>().add(
                const SavedPlaceDeleteRequested(),
              ),
              alignment: Alignment.center,
              child: const Text('Supprimer'),
            ),
        ],
      ),
    );
  }

  Future<void> _onMapPressed(BuildContext buttonContext) async {
    final place = await openPlacePickerSheet(
      buttonContext,
      initial: widget.current?.coordinates ?? widget.origin,
      title: widget.kind.label,
      confirmLabel: 'Confirmer',
      findPlaceAtUseCase: widget.findPlaceAtUseCase,
    );
    if (place == null || !mounted) return;
    _onPlaceChosen(place);
  }

  void _onPlaceChosen(Place place) {
    context.read<SavedPlaceBloc>().add(SavedPlaceChosen(place: place));
  }

  // The home's shortcut and the "Compte" tab show the change, then the flow
  // moves on.
  void _onSavedPlaceChanged(BuildContext context, SavedPlaceState state) {
    final flowBloc = context.read<PassengerFlowBloc>();
    switch (state) {
      case SavedPlaceEditing(:final failureMessage?):
        showMessageToast(
          context,
          title: 'Adresse non enregistrée',
          message: failureMessage,
        );
      case SavedPlaceSaved(:final place):
        context.read<PassengerHomeBloc>().add(
          PassengerSavedPlaceStored(place: place),
        );
        context.read<AccountBloc>().add(const AccountRequested());
        flowBloc.add(PassengerSavedPlaceSaved(place: place));
      case SavedPlaceDeleted(:final kind):
        context.read<PassengerHomeBloc>().add(
          PassengerSavedPlaceRemoved(kind: kind),
        );
        context.read<AccountBloc>().add(const AccountRequested());
        flowBloc.add(const PassengerSavedPlaceDeleted());
      case SavedPlaceEditing() || SavedPlaceSaving() || SavedPlaceDeleting():
        break;
    }
  }

  void _onBackPressed() {
    context.read<PassengerFlowBloc>().add(const PassengerFlowBackPressed());
  }
}
