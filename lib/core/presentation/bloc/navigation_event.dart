part of 'navigation_bloc.dart';

sealed class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

// The app chosen in the sheet opens towards [target].
final class NavigationOpened extends NavigationEvent {
  const NavigationOpened({required this.app, required this.target});

  final NavigationApp app;
  final Coordinates target;

  @override
  List<Object?> get props => [app, target];
}
