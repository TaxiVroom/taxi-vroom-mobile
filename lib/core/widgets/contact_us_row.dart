import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/presentation/bloc/contact_us_bloc.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/message_toast.dart';
import 'package:mobile/core/widgets/place_list_tile.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// The account tab's "Contacter le développeur" line, for both roles: a
/// spinner while the API gives the number, then the phone app opens on it.
/// With [knownPhone] (the driver's tab got it when it opened), the phone app
/// opens at once. Spec taxi-vroom-api/docs/specs/aide-chauffeur.md.
class ContactUsRow extends StatelessWidget {
  const ContactUsRow({this.knownPhone, super.key});

  final String? knownPhone;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContactUsBloc, ContactUsState>(
      listenWhen: (previous, current) => current.failures > previous.failures,
      listener: (context, state) => showMessageToast(
        context,
        title: 'Contacter le développeur',
        message: state.failureMessage ?? 'Impossible d’ouvrir le téléphone.',
      ),
      builder: (context, state) => PlaceListTile(
        icon: Icons.phone_outlined,
        title: 'Contacter le développeur',
        subtitle: 'Intéressé(e) par mon profil ? N’hésitez pas à m’appeler 😊',
        wrapsSubtitle: true,
        onPressed: () => context.read<ContactUsBloc>().add(
          ContactUsCalled(knownPhone: knownPhone),
        ),
        trailing: state.isCalling
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right, color: AppColors.muted),
      ),
    );
  }
}
