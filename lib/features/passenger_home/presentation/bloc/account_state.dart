part of 'account_bloc.dart';

sealed class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

final class AccountLoading extends AccountState {
  const AccountLoading();
}

final class AccountReady extends AccountState {
  const AccountReady({
    required this.account,
    this.deletingKind,
    this.deletedKind,
    this.failureMessage,
  });

  final PassengerAccount account;

  // Its trash shows the loader until the API answers.
  final SavedPlaceKind? deletingKind;

  // Just deleted: the home's shortcut is emptied too.
  final SavedPlaceKind? deletedKind;

  // The deletion failed: told once, the place stays.
  final String? failureMessage;

  @override
  List<Object?> get props => [
    account,
    deletingKind,
    deletedKind,
    failureMessage,
  ];
}

final class AccountFailure extends AccountState {
  const AccountFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
