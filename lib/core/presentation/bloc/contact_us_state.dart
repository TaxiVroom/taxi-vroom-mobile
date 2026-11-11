part of 'contact_us_bloc.dart';

final class ContactUsState extends Equatable {
  const ContactUsState({
    this.isCalling = false,
    this.failures = 0,
    this.failureMessage,
  });

  // The phone app is being opened (after asking the API for the number when
  // the tab did not give it): the row shows its spinner.
  final bool isCalling;

  // Counts the calls that could not open: each one is told once.
  final int failures;
  final String? failureMessage;

  @override
  List<Object?> get props => [isCalling, failures, failureMessage];
}
