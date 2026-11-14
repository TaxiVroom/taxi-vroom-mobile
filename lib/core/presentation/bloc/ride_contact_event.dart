part of 'ride_contact_bloc.dart';

sealed class RideContactEvent extends Equatable {
  const RideContactEvent();

  @override
  List<Object?> get props => [];
}

// "Appeler": the phone app opens on [phone].
final class RideContactCalled extends RideContactEvent {
  const RideContactCalled({required this.phone});

  final String phone;

  @override
  List<Object?> get props => [phone];
}

// "Écrire": the messages app opens on a new message to [phone].
final class RideContactMessaged extends RideContactEvent {
  const RideContactMessaged({required this.phone});

  final String phone;

  @override
  List<Object?> get props => [phone];
}
