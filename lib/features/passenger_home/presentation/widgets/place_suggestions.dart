import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/distance_formatter.dart';
import 'package:mobile/core/widgets/place_list_tile.dart';
import 'package:mobile/core/widgets/search_text_field.dart';
import 'package:mobile/features/passenger_home/domain/entities/place_suggestion.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/destination_search_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// The places found for what was typed, from [DestinationSearchBloc]: a
/// message when none or on failure; tapping one selects it. Used by "Votre
/// trajet" and the saved places' screen.
class PlaceSuggestions extends StatelessWidget {
  const PlaceSuggestions({required this.state, super.key});

  final DestinationSearchState state;

  @override
  Widget build(BuildContext context) {
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
}
