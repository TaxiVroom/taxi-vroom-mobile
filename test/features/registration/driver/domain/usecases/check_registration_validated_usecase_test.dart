import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/registration/driver/domain/entities/registration_vehicle.dart';
import 'package:mobile/features/registration/driver/domain/repositories/driver_registration_repository.dart';
import 'package:mobile/features/registration/driver/domain/usecases/check_registration_validated_usecase.dart';
import 'package:mobile/features/registration/shared/domain/entities/registration_flow_update.dart';

// The registration as the API tells it now.
class _FakeDriverRegistrationRepository
    implements DriverRegistrationRepository {
  _FakeDriverRegistrationRepository(this.step);

  final Result<DriverRegistrationStep> step;

  @override
  Future<Result<DriverRegistrationStep>> getCurrentStep() async => step;

  @override
  Future<Result<void>> saveVehicle(RegistrationVehicle vehicle) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> confirmVehicle({required String userId}) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> savePushToken(String token) =>
      throw UnimplementedError();

  @override
  Future<void> updateRegistrationFlow({
    required String userId,
    required RegistrationFlowUpdate update,
  }) => throw UnimplementedError();
}

void main() {
  group('CheckRegistrationValidatedUseCase', () {
    test('every document validated: the registration is complete', () async {
      // Arrange
      final useCase = CheckRegistrationValidatedUseCase(
        _FakeDriverRegistrationRepository(
          const Result.ok(DriverRegistrationStep.complete),
        ),
      );

      // Act
      final isValidated = await useCase();

      // Assert
      expect(isValidated, isTrue);
    });

    test('still under review: not yet', () async {
      // Arrange
      final useCase = CheckRegistrationValidatedUseCase(
        _FakeDriverRegistrationRepository(
          const Result.ok(DriverRegistrationStep.pendingReview),
        ),
      );

      // Act
      final isValidated = await useCase();

      // Assert
      expect(isValidated, isFalse);
    });

    test('the API cannot be reached: not yet, asked again later', () async {
      // Arrange
      final useCase = CheckRegistrationValidatedUseCase(
        _FakeDriverRegistrationRepository(
          const Result.error(NetworkFailure('Connexion impossible')),
        ),
      );

      // Act
      final isValidated = await useCase();

      // Assert
      expect(isValidated, isFalse);
    });
  });
}
