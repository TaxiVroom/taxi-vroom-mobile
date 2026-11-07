import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/features/registration/driver/data/models/driver_registration_flow_model.dart';
import 'package:mobile/features/registration/driver/data/models/registration_vehicle_model.dart';
import 'package:mobile/features/registration/shared/domain/entities/registration_flow_update.dart';

abstract class DriverRegistrationRemoteDataSource {
  Future<void> updateRegistrationFlow({
    required String userId,
    required RegistrationFlowUpdate update,
  });

  // "Votre taxi": replaces the vehicle given before, if any.
  Future<void> saveVehicle(RegistrationVehicleModel vehicle);

  // The registration as the API has it now.
  Future<DriverRegistrationFlowModel> getRegistrationFlow();

  // The phone's notification token while waiting for the admin.
  Future<void> savePushToken(String token);
}

class DriverRegistrationRemoteDataSourceImpl
    implements DriverRegistrationRemoteDataSource {
  const DriverRegistrationRemoteDataSourceImpl(this._dio, this._firebaseAuth);

  final Dio _dio;
  final FirebaseAuth _firebaseAuth;

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

  @override
  Future<void> saveVehicle(RegistrationVehicleModel vehicle) => _dio.put<void>(
    '/v1/registration-flows/me/vehicle',
    data: vehicle.toJson(),
  );

  // The same route as at sign-in: it gets the registration, which already
  // exists. It asks for the role and the phone, to create one otherwise.
  @override
  Future<DriverRegistrationFlowModel> getRegistrationFlow() async {
    final user = _firebaseAuth.currentUser;
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/registration-flows/me',
      queryParameters: {'role': 'DRIVER', 'phone': user?.phoneNumber},
    );
    return DriverRegistrationFlowModel.fromJson(
      response.data!,
      userId: user?.uid ?? '',
    );
  }

  @override
  Future<void> savePushToken(String token) => _dio.put<void>(
    '/v1/registration-flows/me/push-token',
    data: {'token': token},
  );
}
