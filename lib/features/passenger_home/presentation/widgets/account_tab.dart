import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/phone_formatter.dart';
import 'package:mobile/core/widgets/contact_us_row.dart';
import 'package:mobile/core/widgets/notifications_row.dart';
import 'package:mobile/core/widgets/place_list_tile.dart';
import 'package:mobile/core/widgets/retry_message.dart';
import 'package:mobile/core/widgets/section_label.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_account.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/account_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// The passenger's profile, saved addresses, preferences and sign out.
class AccountTab extends StatelessWidget {
  const AccountTab({required this.onSignOutRequested, super.key});

  final VoidCallback onSignOutRequested;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) => switch (state) {
          AccountLoading() => const Center(child: CircularProgressIndicator()),
          AccountFailure(:final message) => RetryMessage(
            message: message,
            onRetry: () =>
                context.read<AccountBloc>().add(const AccountRequested()),
          ),
          AccountReady(:final account) => _buildAccount(context, account),
        },
      ),
    );
  }

  Widget _buildAccount(BuildContext context, PassengerAccount account) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfile(account),
          const SizedBox(height: 24),
          const SectionLabel('Adresses enregistrées'),
          for (final place in account.savedPlaces)
            PlaceListTile(
              icon: switch (place.label) {
                'Maison' => Icons.home_outlined,
                'Travail' => Icons.work_outline,
                _ => Icons.place_outlined,
              },
              title: place.label,
              subtitle: place.address,
            ),
          // No payment means to set: every ride is paid on board, by card or
          // cash.
          const SizedBox(height: 16),
          const SectionLabel('Préférences'),
          const NotificationsRow(),
          const SizedBox(height: 16),
          const SectionLabel('Assistance'),
          // The number came with the account: the phone app opens at once.
          ContactUsRow(knownPhone: account.contactPhone),
          const SizedBox(height: 24),
          DestructiveButton(
            onPressed: onSignOutRequested,
            alignment: Alignment.center,
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(PassengerAccount account) {
    return Row(
      children: [
        Avatar(initials: Avatar.getInitials(account.fullName), size: 56),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.fullName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formatPhone(account.phone),
                style: const TextStyle(color: AppColors.muted),
              ),
              Text(
                account.email,
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
