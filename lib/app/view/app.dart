import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/core/network/auth_interceptor.dart';
import 'package:mobile/env/app_config.dart';
import 'package:mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:mobile/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/authentication/domain/usecases/get_or_create_registration_flow_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/send_otp_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/verify_otp_usecase.dart';
import 'package:mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/authentication/presentation/navigator/auth_navigator.dart';
import 'package:mobile/features/registration/passenger/data/datasources/registration_remote_datasource_fake.dart';
import 'package:mobile/features/registration/passenger/data/repositories/notification_repository_impl.dart';
import 'package:mobile/features/registration/passenger/data/repositories/registration_repository_impl.dart';
import 'package:mobile/features/registration/passenger/domain/usecases/check_email_availability_usecase.dart';
import 'package:mobile/features/registration/passenger/domain/usecases/create_passenger_usecase.dart';
import 'package:mobile/features/registration/passenger/domain/usecases/request_notification_permission_usecase.dart';
import 'package:mobile/features/registration/passenger/domain/usecases/update_registration_flow_usecase.dart';
import 'package:mobile/l10n/l10n.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class App extends StatelessWidget {
  const App({super.key, required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final dio = Dio(BaseOptions(baseUrl: config.apiBaseUrl));
    dio.interceptors.add(
      AuthInterceptor(firebaseAuth: FirebaseAuth.instance, dio: dio),
    );
    final authDataSource = AuthRemoteDataSourceImpl(FirebaseAuth.instance, dio);
    final authRepo = AuthRepositoryImpl(authDataSource);

    final registrationDataSource = RegistrationRemoteDataSourceFake();
    final registrationRepo = RegistrationRepositoryImpl(registrationDataSource);
    final notifRepo = NotificationRepositoryImpl();

    return BlocProvider(
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
          updateRegistrationFlowUseCase: UpdateRegistrationFlowUseCase(registrationRepo),
          createPassengerUseCase: CreatePassengerUseCase(registrationRepo),
          requestNotificationPermissionUseCase:
              RequestNotificationPermissionUseCase(notifRepo),
          checkEmailAvailabilityUseCase: CheckEmailAvailabilityUseCase(registrationRepo),
        ),
      ),
    );
  }
}
