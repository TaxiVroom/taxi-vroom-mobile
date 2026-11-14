import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/presentation/bloc/connectivity_bloc.dart';
import 'package:mobile/core/widgets/connection_lost_banner.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Around the signed-in app (passenger and driver): a banner at the top of
/// every screen while the device has no connection to Firebase. The first
/// time it is built, it starts watching the connection.
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isConnected = context.select<ConnectivityBloc, bool>(
      (bloc) => bloc.state.isConnected,
    );
    // The banner's slot is always there, so the screens below keep their
    // state when the connection comes and goes.
    return Column(
      children: [
        if (isConnected)
          const SizedBox.shrink()
        else
          const SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: ConnectionLostBanner(
                title: 'Connexion perdue.',
                consequence:
                    'Les informations affichées ne sont peut-être '
                    'plus à jour.',
              ),
            ),
          ),
        Expanded(
          // The banner already covers the status bar.
          child: MediaQuery.removePadding(
            context: context,
            removeTop: !isConnected,
            child: child,
          ),
        ),
      ],
    );
  }
}
