import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/core/data/datasources/email_availability_remote_datasource.dart';
import 'package:mobile/core/data/repositories/email_availability_repository_impl.dart';
import 'package:mobile/core/domain/usecases/check_email_availability_usecase.dart';
import 'package:mobile/core/network/auth_interceptor.dart';
import 'package:mobile/env/app_config.dart';
import 'package:mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:mobile/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/authentication/domain/usecases/get_or_create_registration_flow_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/send_otp_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/verify_otp_usecase.dart';
import 'package:mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/authentication/presentation/navigator/auth_navigator.dart';
import 'package:mobile/features/registration/driver/data/datasources/driver_registration_remote_datasource.dart';
import 'package:mobile/features/registration/driver/data/datasources/registration_document_remote_datasource.dart';
import 'package:mobile/features/registration/driver/data/repositories/driver_notification_repository_impl.dart';
import 'package:mobile/features/registration/driver/data/repositories/driver_registration_repository_impl.dart';
import 'package:mobile/features/registration/driver/data/repositories/registration_document_repository_impl.dart';
import 'package:mobile/features/registration/driver/domain/usecases/get_document_signed_url_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/get_document_types_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/get_uploaded_documents_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/request_driver_notification_permission_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/upload_registration_document_usecase.dart';
import 'package:mobile/features/registration/passenger/data/datasources/registration_remote_datasource.dart';
import 'package:mobile/features/registration/passenger/data/repositories/notification_repository_impl.dart';
import 'package:mobile/features/registration/passenger/data/repositories/registration_repository_impl.dart';
import 'package:mobile/features/registration/passenger/domain/usecases/request_notification_permission_usecase.dart';
import 'package:mobile/features/registration/shared/domain/usecases/update_registration_flow_usecase.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/l10n/l10n.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class App extends StatelessWidget {
  const App({required this.config, super.key});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final dio = Dio(BaseOptions(baseUrl: config.apiBaseUrl));
    dio.interceptors.add(
      AuthInterceptor(firebaseAuth: FirebaseAuth.instance, dio: dio),
    );
    final authDataSource = AuthRemoteDataSourceImpl(FirebaseAuth.instance, dio);
    final authRepo = AuthRepositoryImpl(authDataSource);

    final emailAvailabilityDataSource =
        EmailAvailabilityRemoteDataSourceImpl(dio);
    final emailAvailabilityRepo =
        EmailAvailabilityRepositoryImpl(emailAvailabilityDataSource);
    final checkEmailAvailabilityUseCase =
        CheckEmailAvailabilityUseCase(emailAvailabilityRepo);

    // Passager.
    final registrationDataSource = RegistrationRemoteDataSourceImpl(dio);
    final registrationRepo = RegistrationRepositoryImpl(registrationDataSource);
    final passengerNotifRepo = NotificationRepositoryImpl();

    // Chauffeur.
    final driverRegistrationDataSource =
        DriverRegistrationRemoteDataSourceImpl(dio);
    final driverRegistrationRepo =
        DriverRegistrationRepositoryImpl(driverRegistrationDataSource);
    final driverNotifRepo = DriverNotificationRepositoryImpl();

    final registrationDocumentDataSource =
        RegistrationDocumentRemoteDataSourceImpl(dio);
    final registrationDocumentRepo =
        RegistrationDocumentRepositoryImpl(registrationDocumentDataSource);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      child: BlocProvider(
        create: (_) => AuthBloc(
          sendOtpUseCase: SendOtpUseCase(authRepo),
          verifyOtpUseCase: VerifyOtpUseCase(authRepo),
          getOrCreateRegistrationFlowUseCase:
              GetOrCreateRegistrationFlowUseCase(authRepo),
        ),
        child: ShadcnApp(
        debugShowCheckedModeBanner: false,
        title: 'TaxiApp',
        theme: ThemeData(
          colorScheme: ColorSchemes.lightZinc.copyWith(
            primary: () => const Color(0xFF0066FF),
            primaryForeground: () => const Color(0xFFFFFFFF),
            ring: () => const Color(0xFF0066FF),
          ),
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
          home: AuthNavigator(
            passengerUpdateRegistrationFlowUseCase:
                UpdateRegistrationFlowUseCase(registrationRepo),
            requestNotificationPermissionUseCase:
                RequestNotificationPermissionUseCase(passengerNotifRepo),
            driverUpdateRegistrationFlowUseCase:
                UpdateRegistrationFlowUseCase(driverRegistrationRepo),
            requestDriverNotificationPermissionUseCase:
                RequestDriverNotificationPermissionUseCase(driverNotifRepo),
            checkEmailAvailabilityUseCase: checkEmailAvailabilityUseCase,
            getDocumentTypesUseCase:
                GetDocumentTypesUseCase(registrationDocumentRepo),
            uploadRegistrationDocumentUseCase:
                UploadRegistrationDocumentUseCase(registrationDocumentRepo),
            getUploadedDocumentsUseCase:
                GetUploadedDocumentsUseCase(registrationDocumentRepo),
            getDocumentSignedUrlUseCase:
                GetDocumentSignedUrlUseCase(registrationDocumentRepo),
          ),
        ),
      ),
    );
  }
}
