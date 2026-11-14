import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/presentation/bloc/ride_contact_bloc.dart';
import 'package:mobile/core/widgets/message_toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Around the "Appeler" and "Écrire" buttons of a ride: tells when the phone
/// or messages app could not open.
class RideContactListener extends StatelessWidget {
  const RideContactListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<RideContactBloc, RideContactState>(
      listenWhen: (previous, current) => current.failures > previous.failures,
      listener: (context, state) => showMessageToast(
        context,
        title: 'Contact',
        message: state.failureMessage ?? 'Impossible d’ouvrir le téléphone.',
      ),
      child: child,
    );
  }
}
