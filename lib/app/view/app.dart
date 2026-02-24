import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:mobile/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/authentication/data/repositories/notification_repository_impl.dart';
import 'package:mobile/features/authentication/domain/usecases/check_email_availability_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/register_user_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/request_notification_permission_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/send_otp_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/verify_otp_usecase.dart';
import 'package:mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/authentication/presentation/navigator/auth_navigator.dart';
import 'package:mobile/l10n/l10n.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final dataSource = AuthRemoteDataSourceImpl(FirebaseAuth.instance);
    final authRepo = AuthRepositoryImpl(dataSource);
    final notifRepo = NotificationRepositoryImpl();

    return BlocProvider(
      create: (_) => AuthBloc(
        sendOtpUseCase: SendOtpUseCase(authRepo),
        verifyOtpUseCase: VerifyOtpUseCase(authRepo),
        registerUserUseCase: RegisterUserUseCase(authRepo),
        requestNotificationPermissionUseCase:
            RequestNotificationPermissionUseCase(notifRepo),
        checkEmailAvailabilityUseCase:
            CheckEmailAvailabilityUseCase(authRepo),
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
        home: const AuthNavigator(),
      ),
    );
  }
}
