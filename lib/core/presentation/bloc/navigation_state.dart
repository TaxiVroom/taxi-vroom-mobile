part of 'navigation_bloc.dart';

final class NavigationState extends Equatable {
  const NavigationState({this.failures = 0, this.failureMessage});

  // Counts the links that could not open: each one is told once.
  final int failures;
  final String? failureMessage;

  @override
  List<Object?> get props => [failures, failureMessage];
}
