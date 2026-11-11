part of 'contact_us_bloc.dart';

sealed class ContactUsEvent extends Equatable {
  const ContactUsEvent();

  @override
  List<Object?> get props => [];
}

// The passenger or the driver taps "Nous contacter". [knownPhone]: the
// number already received with the driver's "Compte" tab, not asked again.
final class ContactUsCalled extends ContactUsEvent {
  const ContactUsCalled({this.knownPhone});

  final String? knownPhone;

  @override
  List<Object?> get props => [knownPhone];
}
