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

// The trash of a "Maison" or "Travail" row.
final class AccountSavedPlaceDeleteRequested extends AccountEvent {
  const AccountSavedPlaceDeleteRequested({required this.kind});

  final SavedPlaceKind kind;

  @override
  List<Object?> get props => [kind];
}
