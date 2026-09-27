part of 'account_bloc.dart';

sealed class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

// The "Compte" tab is shown, or the passenger taps "Réessayer".
final class AccountRequested extends AccountEvent {
  const AccountRequested();
}

final class AccountNotificationsToggled extends AccountEvent {
  const AccountNotificationsToggled({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}
