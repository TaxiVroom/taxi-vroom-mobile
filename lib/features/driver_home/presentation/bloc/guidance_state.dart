part of 'guidance_bloc.dart';

sealed class GuidanceState extends Equatable {
  const GuidanceState();

  @override
  List<Object?> get props => [];
}

final class GuidanceLoading extends GuidanceState {
  const GuidanceLoading();
}

final class GuidanceReady extends GuidanceState {
  const GuidanceReady({required this.guidance});

  final Guidance guidance;

  @override
  List<Object?> get props => [guidance];
}

final class GuidanceFailure extends GuidanceState {
  const GuidanceFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
