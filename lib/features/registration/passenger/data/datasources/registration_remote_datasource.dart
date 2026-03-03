import 'package:dio/dio.dart';
import 'package:mobile/features/authentication/data/models/user_model.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/registration/passenger/domain/entities/registration_flow_update.dart';

// TODO: Scinder en deux datasources si un flow Driver est ajouté (ISP).
abstract class RegistrationRemoteDataSource {
  Future<UserModel> registerWithEmail({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  });

  Future<bool> checkEmailAvailability({required String email});

  Future<void> updateRegistrationFlow({
    required String userId,
    required RegistrationFlowUpdate update,
  });

  Future<void> createPassenger({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
  });
}

class RegistrationRemoteDataSourceImpl implements RegistrationRemoteDataSource {
  const RegistrationRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<UserModel> registerWithEmail({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return UserModel(
      id: 'mock-email-id',
      phoneNumber: phoneNumber,
      email: email,
      firstName: firstName,
      lastName: lastName,
    );
  }

  @override
  Future<bool> checkEmailAvailability({required String email}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/registration-flows/me/email-availability',
      queryParameters: {'email': email},
    );
    return response.data!['isAvailable'] as bool;
  }

  @override
  Future<void> updateRegistrationFlow({
    required String userId,
    required RegistrationFlowUpdate update,
  }) async {
    // fromStep tells the backend which step to advance FROM — it sets currentStep
    // to NEXT_STEP[fromStep], making PATCH idempotent on back-navigation.
    final body = switch (update) {
      EmailUpdate(:final email, :final fromStep) => {
          'email': email,
          'fromStep': _serializeStep(fromStep),
        },
      NameUpdate(:final firstName, :final lastName, :final fromStep) => {
          'firstName': firstName,
          'lastName': lastName,
          'fromStep': _serializeStep(fromStep),
        },
    };
    await _dio.patch<void>('/v1/registration-flows/me', data: body);
  }

  // Domain enum → backend UPPER_SNAKE_CASE string.
  static String _serializeStep(PassengerRegistrationStep step) => switch (step) {
        PassengerRegistrationStep.socialLink => 'SOCIAL_LINK',
        PassengerRegistrationStep.email      => 'EMAIL',
        PassengerRegistrationStep.name       => 'NAME',
        PassengerRegistrationStep.complete   => 'COMPLETE',
      };

  @override
  Future<void> createPassenger({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    // All registration data is already stored via previous PATCH calls — no body needed.
    await _dio.post<void>('/v1/passengers');
  }
}
