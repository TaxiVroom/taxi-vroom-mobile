import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.phoneNumber,
    this.email,
    this.firstName,
    this.lastName,
  });

  final String id;
  final String phoneNumber;
  final String? email;
  final String? firstName;
  final String? lastName;

  @override
  List<Object?> get props => [id, phoneNumber, email, firstName, lastName];
}
