import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/presentation/bloc/navigation_bloc.dart';
import 'package:mobile/core/widgets/message_toast.dart';
import 'package:mobile/core/widgets/navigation_app_sheet.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// "Itinéraire": the app chosen in the sheet, asked at each tap, opens
/// already guiding to [target].
class ItineraryButton extends StatelessWidget {
  const ItineraryButton({required this.target, super.key});

  final Coordinates target;

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, NavigationState>(
      listenWhen: (previous, current) => current.failures > previous.failures,
      listener: (context, state) => showMessageToast(
        context,
        title: 'Itinéraire',
        message: state.failureMessage ?? 'Impossible d’ouvrir la navigation.',
      ),
      child: SecondaryButton(
        density: ButtonDensity.icon,
        shape: ButtonShape.circle,
        onPressed: () => _onPressed(context),
        child: const Icon(Icons.navigation_outlined),
      ),
    );
  }

  Future<void> _onPressed(BuildContext context) async {
    final bloc = context.read<NavigationBloc>();
    final app = await openNavigationAppSheet(context);
    if (app != null) bloc.add(NavigationOpened(app: app, target: target));
  }
}
