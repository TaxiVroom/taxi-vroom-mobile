import 'package:dio/dio.dart';
import 'package:mobile/features/registration/shared/domain/entities/registration_flow_update.dart';

abstract class DriverRegistrationRemoteDataSource {
  Future<void> updateRegistrationFlow({
    required String userId,
    required RegistrationFlowUpdate update,
  });

}

class DriverRegistrationRemoteDataSourceImpl
    implements DriverRegistrationRemoteDataSource {
  const DriverRegistrationRemoteDataSourceImpl(this._dio);

  final Dio _dio;

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
      DocumentsReadyForReviewUpdate(:final fromStep) => {
          'fromStep': fromStep.serialize(),
        },
    };
    await _dio.patch<void>('/v1/registration-flows/me', data: body);
  }

}
