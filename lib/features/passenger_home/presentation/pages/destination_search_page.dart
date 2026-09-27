import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/distance_formatter.dart';
import 'package:mobile/core/widgets/place_list_tile.dart';
import 'package:mobile/features/passenger_home/domain/entities/place_suggestion.dart';
import 'package:mobile/features/passenger_home/domain/entities/recent_destination.dart';
import 'package:mobile/features/passenger_home/domain/usecases/select_destination_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/suggest_destinations_usecase.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/destination_search_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/passenger_flow_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/pickup_time_chip.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 4: departure is the passenger's position, they type the
/// destination and pick a live suggestion.
class DestinationSearchPage extends StatelessWidget {
  const DestinationSearchPage({
    required this.origin,
    required this.recentDestinations,
    required this.suggestDestinationsUseCase,
    required this.selectDestinationUseCase,
    super.key,
  });

  final Coordinates origin;
  final List<RecentDestination> recentDestinations;
  final SuggestDestinationsUseCase suggestDestinationsUseCase;
  final SelectDestinationUseCase selectDestinationUseCase;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DestinationSearchBloc(
        origin: origin,
        suggestDestinationsUseCase: suggestDestinationsUseCase,
        selectDestinationUseCase: selectDestinationUseCase,
      ),
      child: _DestinationSearchView(recentDestinations: recentDestinations),
    );
  }
}

class _DestinationSearchView extends StatefulWidget {
  const _DestinationSearchView({required this.recentDestinations});

  final List<RecentDestination> recentDestinations;

  @override
  State<_DestinationSearchView> createState() => _DestinationSearchViewState();
}

class _DestinationSearchViewState extends State<_DestinationSearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DestinationSearchBloc, DestinationSearchState>(
      listenWhen: (previous, current) =>
          current.selectedDestination != null &&
          current.selectedDestination != previous.selectedDestination,
      listener: (context, state) => context.read<PassengerFlowBloc>().add(
        PassengerDestinationSelected(
          destination: state.selectedDestination!,
        ),
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildOrigin(),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  placeholder: const Text('Où allez-vous ?'),
                  autofocus: true,
                  onChanged: _onQueryChanged,
                ),
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

  Widget _buildOrigin() {
    return const Row(
      children: [
        Icon(Icons.my_location, size: 18, color: AppColors.muted),
        SizedBox(width: 8),
        Text('Ma position', style: TextStyle(color: AppColors.muted)),
      ],
    );
  }

  // Picking the destination on the map is not built yet.
  Widget _buildOptions() {
    return Row(
      children: [
        const PickupTimeChip(),
        const SizedBox(width: 8),
        OutlineButton(
          onPressed: () {},
          leading: const Icon(Icons.place_outlined, size: 16),
          child: const Text('Choisir sur la carte'),
        ),
      ],
    );
  }

  Widget _buildResults(DestinationSearchState state) {
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
    if (state.suggestions.isEmpty) {
      return state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMessage('Aucune adresse trouvée');
    }

    return ListView(
      children: [
        for (final suggestion in state.suggestions)
          PlaceListTile(
            icon: Icons.place_outlined,
            title: suggestion.name,
            subtitle: _suggestionDetail(suggestion),
            onPressed: state.isLoading
                ? null
                : () => context.read<DestinationSearchBloc>().add(
                    DestinationSuggestionSelected(suggestion: suggestion),
                  ),
          ),
      ],
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
    _controller.text = query;
    _onQueryChanged(query);
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
