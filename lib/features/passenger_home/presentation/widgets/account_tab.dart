import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/phone_formatter.dart';
import 'package:mobile/core/widgets/contact_us_row.dart';
import 'package:mobile/core/widgets/message_toast.dart';
import 'package:mobile/core/widgets/notifications_row.dart';
import 'package:mobile/core/widgets/place_list_tile.dart';
import 'package:mobile/core/widgets/retry_message.dart';
import 'package:mobile/core/widgets/section_label.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_account.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/account_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/passenger_flow_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/passenger_home_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// The passenger's profile, saved addresses, preferences and sign out.
class AccountTab extends StatelessWidget {
  const AccountTab({required this.onSignOutRequested, super.key});

  final VoidCallback onSignOutRequested;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<AccountBloc, AccountState>(
        listener: _onDeletionAnswered,
        builder: (context, state) => switch (state) {
          AccountLoading() => const Center(child: CircularProgressIndicator()),
          AccountFailure(:final message) => RetryMessage(
            message: message,
            onRetry: () =>
                context.read<AccountBloc>().add(const AccountRequested()),
          ),
          AccountReady(:final account, :final deletingKind) => _buildAccount(
            context,
            account,
            deletingKind,
          ),
        },
      ),
    );
  }

  // Deleted: the home's shortcut is emptied too. Failed: told, it stays.
  void _onDeletionAnswered(BuildContext context, AccountState state) {
    if (state is! AccountReady) return;
    if (state.deletedKind case final kind?) {
      context.read<PassengerHomeBloc>().add(
        PassengerSavedPlaceRemoved(kind: kind),
      );
    }
    if (state.failureMessage case final message?) {
      showMessageToast(
        context,
        title: 'Adresse non supprimée',
        message: message,
      );
    }
  }

  Widget _buildAccount(
    BuildContext context,
    PassengerAccount account,
    SavedPlaceKind? deletingKind,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfile(account),
          const SizedBox(height: 24),
          const SectionLabel('Adresses enregistrées'),
          for (final kind in SavedPlaceKind.values)
            _buildSavedPlace(context, account, kind, deletingKind),
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

  // Its address, or "Ajouter"; a tap opens the search to add or change it.
  // Spec taxi-vroom-api/docs/specs/maison-et-travail.md.
  Widget _buildSavedPlace(
    BuildContext context,
    PassengerAccount account,
    SavedPlaceKind kind,
    SavedPlaceKind? deletingKind,
  ) {
    final saved = account.savedPlaces
        .where((place) => place.kind == kind)
        .firstOrNull;
    final tile = PlaceListTile(
      icon: switch (kind) {
        SavedPlaceKind.home => Icons.home_outlined,
        SavedPlaceKind.work => Icons.work_outline,
      },
      title: kind.label,
      subtitle: saved?.address ?? 'Ajouter',
      // The loader in its place while the API deletes it.
      trailing: deletingKind == kind
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(),
            )
          : const Icon(Icons.chevron_right, color: AppColors.muted),
      onPressed: () => context.read<PassengerFlowBloc>().add(
        PassengerSavedPlaceEditOpened(
          kind: kind,
          current: saved,
          fromAccount: true,
        ),
      ),
    );
    if (saved == null || deletingKind != null) return tile;
    return _buildSwipeToDelete(context, saved, tile);
  }

  // Slid to the left, as in the market's apps: "Supprimer" shows behind,
  // then the row is deleted. Flutter's Dismissible: once dismissed it must
  // leave the tree, which the deleting state does (a plain row with its
  // loader). Spec taxi-vroom-api/docs/specs/maison-et-travail.md.
  Widget _buildSwipeToDelete(
    BuildContext context,
    SavedPlace saved,
    Widget tile,
  ) {
    return Dismissible(
      key: ValueKey('saved-place-${saved.kind.name}-${saved.address}'),
      direction: DismissDirection.endToStart,
      resizeDuration: null,
      background: Container(
        color: AppColors.danger,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Supprimer',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) => context.read<AccountBloc>().add(
        AccountSavedPlaceDeleteRequested(kind: saved.kind),
      ),
      child: ColoredBox(color: Colors.white, child: tile),
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
