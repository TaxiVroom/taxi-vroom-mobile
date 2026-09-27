import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/license_plate.dart';
import 'package:mobile/core/widgets/place_list_tile.dart';
import 'package:mobile/core/widgets/retry_message.dart';
import 'package:mobile/core/widgets/section_label.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_account.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_documents.dart';
import 'package:mobile/features/driver_home/presentation/bloc/driver_account_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// The driver's profile, vehicle, documents, preferences and sign out: the
/// same layout as the passenger's "Compte" tab.
class DriverAccountTab extends StatelessWidget {
  const DriverAccountTab({
    required this.onDocumentsPressed,
    required this.onSignOutRequested,
    super.key,
  });

  final ValueChanged<DriverDocuments> onDocumentsPressed;
  final VoidCallback onSignOutRequested;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<DriverAccountBloc, DriverAccountState>(
        builder: (context, state) => switch (state) {
          DriverAccountLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          DriverAccountFailure(:final message) => RetryMessage(
            message: message,
            onRetry: () => context.read<DriverAccountBloc>().add(
              const DriverAccountRequested(),
            ),
          ),
          DriverAccountReady(:final account, :final documents) => _buildAccount(
            context,
            account,
            documents,
          ),
        },
      ),
    );
  }

  Widget _buildAccount(
    BuildContext context,
    DriverAccount account,
    DriverDocuments documents,
  ) {
    final documentsSummary = documents.needsAction
        ? '${documents.validatedCount} sur ${documents.documents.length} '
              'validés, une action attendue'
        : 'Tous vos documents sont à jour';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfile(account),
          const SizedBox(height: 24),
          const SectionLabel('Véhicule'),
          Row(
            children: [
              Expanded(
                child: Text(
                  account.vehicleModel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              LicensePlate(
                plate: account.plate,
                department: account.plateDepartment,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SectionLabel('Documents'),
          PlaceListTile(
            icon: Icons.badge_outlined,
            title: 'Vos documents',
            subtitle: documentsSummary,
            onPressed: () => onDocumentsPressed(documents),
            trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          const SectionLabel('Préférences'),
          _buildNotifications(context, account),
          const SizedBox(height: 16),
          const SectionLabel('Assistance'),
          // Help and terms pages are not built yet.
          PlaceListTile(
            icon: Icons.help_outline,
            title: 'Aide',
            subtitle: 'Questions fréquentes, nous contacter',
            onPressed: () {},
            trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
          ),
          PlaceListTile(
            icon: Icons.description_outlined,
            title: "Conditions d'utilisation",
            subtitle: 'Vos droits et nos engagements',
            onPressed: () {},
            trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
          ),
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

  Widget _buildProfile(DriverAccount account) {
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
                account.phone,
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

  Widget _buildNotifications(BuildContext context, DriverAccount account) {
    return Row(
      children: [
        const Icon(Icons.notifications_outlined, color: AppColors.muted),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Notifications',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Switch(
          value: account.notificationsEnabled,
          onChanged: (enabled) => context.read<DriverAccountBloc>().add(
            DriverAccountNotificationsToggled(enabled: enabled),
          ),
        ),
      ],
    );
  }
}
