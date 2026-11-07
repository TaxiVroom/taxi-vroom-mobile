import 'package:dio/dio.dart';
import 'package:mobile/features/authentication/data/models/user_model.dart';
import 'package:mobile/features/registration/shared/domain/entities/registration_flow_update.dart';

abstract class RegistrationRemoteDataSource {
  Future<UserModel> registerWithEmail({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  });

  Future<void> updateRegistrationFlow({
    required String userId,
    required RegistrationFlowUpdate update,
  });

  Future<void> completeRegistration();
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
  Future<void> updateRegistrationFlow({
    required String userId,
    required RegistrationFlowUpdate update,
  }) async {
    // fromStep tells the backend which step to advance FROM — it sets currentStep
    // to NEXT_STEP[fromStep], making PATCH idempotent on back-navigation.
    final body = switch (update) {
      EmailUpdate(:final email, :final fromStep) => {
        'email': email,
        'fromStep': fromStep.serialize(),
      },
      NameUpdate(:final firstName, :final lastName, :final fromStep) => {
        'firstName': firstName,
        'lastName': lastName,
        'fromStep': fromStep.serialize(),
      },
      VehicleConfirmedUpdate(:final fromStep) ||
      DocumentsReadyForReviewUpdate(:final fromStep) => {
        'fromStep': fromStep.serialize(),
      },
    };
    await _dio.patch<void>('/v1/registration-flows/me', data: body);
  }

  // Finalizes the registration: the backend sets the step to COMPLETE and creates the user.
  @override
  Future<void> completeRegistration() async {
    await _dio.post<void>('/v1/passengers');
  }
}
