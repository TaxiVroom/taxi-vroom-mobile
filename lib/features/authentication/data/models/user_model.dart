import 'package:mobile/features/authentication/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.phoneNumber,
    super.email,
    super.firstName,
    super.lastName,
  });
}
