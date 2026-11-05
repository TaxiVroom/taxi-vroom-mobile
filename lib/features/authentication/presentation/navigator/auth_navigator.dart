import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/domain/usecases/check_email_availability_usecase.dart';
import 'package:mobile/core/domain/usecases/ensure_notification_permission_usecase.dart';
import 'package:mobile/core/domain/usecases/watch_connection_usecase.dart';
import 'package:mobile/core/domain/usecases/watch_pushed_rides_usecase.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/authentication/domain/entities/user_role.dart';
import 'package:mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/authentication/presentation/pages/otp_verification_page.dart';
import 'package:mobile/features/authentication/presentation/pages/phone_number_page.dart';
import 'package:mobile/features/authentication/presentation/pages/welcome_page.dart';
import 'package:mobile/features/driver_home/domain/usecases/accept_booking_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/accept_ride_request_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/arrive_at_pickup_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/complete_ride_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/decline_ride_request_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/depart_for_booking_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_current_driver_ride_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_account_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_bookings_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_documents_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_home_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_ride_checkout_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_weekly_earnings_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/refuse_booking_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/report_no_show_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/set_online_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/set_receives_bookings_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/share_driver_position_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/start_ride_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/update_driver_notifications_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_guidance_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_passenger_cancellation_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_ride_requests_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/withdraw_from_booking_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/withdraw_from_ride_usecase.dart';
import 'package:mobile/features/driver_home/presentation/pages/driver_home_page.dart';
import 'package:mobile/features/passenger_home/domain/usecases/book_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/cancel_booking_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/cancel_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/get_pickup_days_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/get_pickup_for_arrival_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_account_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_current_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_passenger_home_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_ride_history_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_taxi_choice_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/rate_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/request_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/select_destination_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/suggest_destinations_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/update_notifications_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/watch_nearby_taxis_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/watch_ride_usecase.dart';
import 'package:mobile/features/passenger_home/presentation/pages/passenger_home_page.dart';
import 'package:mobile/features/registration/driver/domain/usecases/get_document_signed_url_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/get_document_types_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/get_uploaded_documents_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/upload_registration_document_usecase.dart';
import 'package:mobile/features/registration/driver/presentation/navigator/driver_registration_navigator.dart';
import 'package:mobile/features/registration/passenger/domain/usecases/complete_passenger_registration_usecase.dart';
import 'package:mobile/features/registration/passenger/presentation/navigator/passenger_registration_navigator.dart';
import 'package:mobile/features/registration/shared/domain/usecases/update_registration_flow_usecase.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    show Basic, ButtonSize, PrimaryButton, SurfaceCard, Text, showToast;

/// Sur [AuthOtpVerified], switch exhaustif sur [RegistrationFlowEntity] (sealed class)
/// pour router vers le bon navigator d'inscription — un nouveau flow driver
/// n'exige qu'un seul case supplémentaire ici.
class AuthNavigator extends StatelessWidget {
  const AuthNavigator({
    required this.passengerUpdateRegistrationFlowUseCase,
    required this.completePassengerRegistrationUseCase,
    required this.driverUpdateRegistrationFlowUseCase,
    required this.ensureNotificationPermissionUseCase,
    required this.checkEmailAvailabilityUseCase,
    required this.getDocumentTypesUseCase,
    required this.uploadRegistrationDocumentUseCase,
    required this.getUploadedDocumentsUseCase,
    required this.getDocumentSignedUrlUseCase,
    required this.loadPassengerHomeUseCase,
    required this.watchNearbyTaxisUseCase,
    required this.suggestDestinationsUseCase,
    required this.selectDestinationUseCase,
    required this.loadTaxiChoiceUseCase,
    required this.getPickupDaysUseCase,
    required this.requestRideUseCase,
    required this.loadCurrentRideUseCase,
    required this.watchPushedRidesUseCase,
    required this.loadCurrentDriverRideUseCase,
    required this.watchRideUseCase,
    required this.cancelRideUseCase,
    required this.rateRideUseCase,
    required this.bookRideUseCase,
    required this.getPickupForArrivalUseCase,
    required this.loadRideHistoryUseCase,
    required this.cancelBookingUseCase,
    required this.loadAccountUseCase,
    required this.updateNotificationsUseCase,
    required this.loadDriverDocumentsUseCase,
    required this.loadDriverHomeUseCase,
    required this.setOnlineUseCase,
    required this.setReceivesBookingsUseCase,
    required this.shareDriverPositionUseCase,
    required this.watchConnectionUseCase,
    required this.watchRideRequestsUseCase,
    required this.acceptRideRequestUseCase,
    required this.declineRideRequestUseCase,
    required this.watchGuidanceUseCase,
    required this.arriveAtPickupUseCase,
    required this.startRideUseCase,
    required this.reportNoShowUseCase,
    required this.withdrawFromRideUseCase,
    required this.watchPassengerCancellationUseCase,
    required this.loadRideCheckoutUseCase,
    required this.completeRideUseCase,
    required this.loadDriverBookingsUseCase,
    required this.acceptBookingUseCase,
    required this.withdrawFromBookingUseCase,
    required this.refuseBookingUseCase,
    required this.departForBookingUseCase,
    required this.loadWeeklyEarningsUseCase,
    required this.loadDriverAccountUseCase,
    required this.updateDriverNotificationsUseCase,
    super.key,
  });

  // Use cases passager transmis au PassengerRegistrationNavigator.
  // AuthBloc n'en a plus besoin — ils appartiennent au flow d'inscription.
  final UpdateRegistrationFlowUseCase passengerUpdateRegistrationFlowUseCase;
  final CompletePassengerRegistrationUseCase
  completePassengerRegistrationUseCase;

  // Use cases chauffeur transmis au DriverRegistrationNavigator.
  final UpdateRegistrationFlowUseCase driverUpdateRegistrationFlowUseCase;

  // Passager et chauffeur : l'écran des notifications de l'inscription.
  final EnsureNotificationPermissionUseCase ensureNotificationPermissionUseCase;

  // Partagé entre passager et chauffeur — même endpoint de vérification.
  final CheckEmailAvailabilityUseCase checkEmailAvailabilityUseCase;

  // Use cases documents chauffeur transmis au DriverRegistrationNavigator.
  final GetDocumentTypesUseCase getDocumentTypesUseCase;
  final UploadRegistrationDocumentUseCase uploadRegistrationDocumentUseCase;
  final GetUploadedDocumentsUseCase getUploadedDocumentsUseCase;
  final GetDocumentSignedUrlUseCase getDocumentSignedUrlUseCase;

  // Use cases de l'accueil passager, transmis à PassengerHomePage.
  final LoadPassengerHomeUseCase loadPassengerHomeUseCase;
  final WatchNearbyTaxisUseCase watchNearbyTaxisUseCase;
  final SuggestDestinationsUseCase suggestDestinationsUseCase;
  final SelectDestinationUseCase selectDestinationUseCase;
  final LoadTaxiChoiceUseCase loadTaxiChoiceUseCase;
  final GetPickupDaysUseCase getPickupDaysUseCase;
  final RequestRideUseCase requestRideUseCase;
  final LoadCurrentRideUseCase loadCurrentRideUseCase;
  final WatchPushedRidesUseCase watchPushedRidesUseCase;
  final LoadCurrentDriverRideUseCase loadCurrentDriverRideUseCase;
  final WatchRideUseCase watchRideUseCase;
  final CancelRideUseCase cancelRideUseCase;
  final RateRideUseCase rateRideUseCase;
  final BookRideUseCase bookRideUseCase;
  final GetPickupForArrivalUseCase getPickupForArrivalUseCase;
  final LoadRideHistoryUseCase loadRideHistoryUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  final LoadAccountUseCase loadAccountUseCase;
  final UpdateNotificationsUseCase updateNotificationsUseCase;

  // Use cases de l'accueil chauffeur, transmis à DriverHomePage.
  final LoadDriverDocumentsUseCase loadDriverDocumentsUseCase;
  final LoadDriverHomeUseCase loadDriverHomeUseCase;
  final SetOnlineUseCase setOnlineUseCase;
  final SetReceivesBookingsUseCase setReceivesBookingsUseCase;
  final ShareDriverPositionUseCase shareDriverPositionUseCase;

  // Partagé entre passager et chauffeur : prévient quand la connexion est
  // perdue.
  final WatchConnectionUseCase watchConnectionUseCase;
  final WatchRideRequestsUseCase watchRideRequestsUseCase;
  final AcceptRideRequestUseCase acceptRideRequestUseCase;
  final DeclineRideRequestUseCase declineRideRequestUseCase;
  final WatchGuidanceUseCase watchGuidanceUseCase;
  final ArriveAtPickupUseCase arriveAtPickupUseCase;
  final StartRideUseCase startRideUseCase;
  final ReportNoShowUseCase reportNoShowUseCase;
  final WithdrawFromRideUseCase withdrawFromRideUseCase;
  final WatchPassengerCancellationUseCase watchPassengerCancellationUseCase;
  final LoadRideCheckoutUseCase loadRideCheckoutUseCase;
  final CompleteRideUseCase completeRideUseCase;
  final LoadDriverBookingsUseCase loadDriverBookingsUseCase;
  final AcceptBookingUseCase acceptBookingUseCase;
  final WithdrawFromBookingUseCase withdrawFromBookingUseCase;
  final RefuseBookingUseCase refuseBookingUseCase;
  final DepartForBookingUseCase departForBookingUseCase;
  final LoadWeeklyEarningsUseCase loadWeeklyEarningsUseCase;
  final LoadDriverAccountUseCase loadDriverAccountUseCase;
  final UpdateDriverNotificationsUseCase updateDriverNotificationsUseCase;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, current) => current is AuthError,
      listener: (context, state) {
        if (state is AuthError) _onAuthError(context, state);
      },
      // BlocBuilder passe le dernier état au FlowBuilder à chaque émission.
      // FlowBuilder diffe les deux listes et joue push ou pop automatiquement.
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return FlowBuilder<AuthState>(
            state: state,
            onGeneratePages: (state, pages) =>
                _onGeneratePages(context, state, pages),
          );
        },
      ),
    );
  }

  /// [pages] est utilisé uniquement pour [AuthError] : erreur transitoire —
  /// le [BlocListener] affiche le toast sans changer la stack.
  List<Page<void>> _onGeneratePages(
    BuildContext context,
    AuthState state,
    List<Page<void>> pages,
  ) {
    const welcomePage = MaterialPage<void>(
      key: ValueKey('welcome'),
      child: WelcomePage(),
    );
    const phonePage = MaterialPage<void>(
      key: ValueKey('phone'),
      child: PhoneNumberPage(),
    );
    const otpPage = MaterialPage<void>(
      key: ValueKey('otp'),
      child: OtpVerificationPage(),
    );

    // AuthError ne change pas la stack : le BlocListener se charge du toast.
    if (state is AuthError) return pages.isNotEmpty ? pages : [welcomePage];

    return switch (state) {
      AuthRestoring() => [
        const MaterialPage<void>(
          key: ValueKey('restoring'),
          child: Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
      ],
      AuthInitial() || AuthGoogleSignInLoading() => [welcomePage],
      AuthPhoneNumberInputReady() || AuthPhoneNumberLoading() => [
        welcomePage,
        phonePage,
      ],
      AuthOtpSent() || AuthOtpCountdown() || AuthOtpVerifying() => [
        welcomePage,
        phonePage,
        otpPage,
      ],
      AuthOtpVerified(:final registrationFlow) => [
        switch (registrationFlow) {
          PassengerRegistrationFlowEntity() => MaterialPage<void>(
            key: const ValueKey('passenger-registration'),
            child: PassengerRegistrationNavigator(
              registrationFlow: registrationFlow,
              updateRegistrationFlowUseCase:
                  passengerUpdateRegistrationFlowUseCase,
              ensureNotificationPermissionUseCase:
                  ensureNotificationPermissionUseCase,
              checkEmailAvailabilityUseCase: checkEmailAvailabilityUseCase,
              completePassengerRegistrationUseCase:
                  completePassengerRegistrationUseCase,
              onAuthenticated: () => _onRegistrationCompleted(context),
            ),
          ),
          DriverRegistrationFlowEntity() => MaterialPage<void>(
            key: const ValueKey('driver-registration'),
            child: DriverRegistrationNavigator(
              registrationFlow: registrationFlow,
              updateRegistrationFlowUseCase:
                  driverUpdateRegistrationFlowUseCase,
              ensureNotificationPermissionUseCase:
                  ensureNotificationPermissionUseCase,
              checkEmailAvailabilityUseCase: checkEmailAvailabilityUseCase,
              getDocumentTypesUseCase: getDocumentTypesUseCase,
              uploadRegistrationDocumentUseCase:
                  uploadRegistrationDocumentUseCase,
              getUploadedDocumentsUseCase: getUploadedDocumentsUseCase,
              getDocumentSignedUrlUseCase: getDocumentSignedUrlUseCase,
              onAuthenticated: () => _onRegistrationCompleted(context),
            ),
          ),
        },
      ],
      AuthAuthenticated(role: UserRole.passenger) => [
        MaterialPage<void>(
          key: const ValueKey('passenger-home'),
          child: PassengerHomePage(
            loadPassengerHomeUseCase: loadPassengerHomeUseCase,
            watchNearbyTaxisUseCase: watchNearbyTaxisUseCase,
            watchConnectionUseCase: watchConnectionUseCase,
            suggestDestinationsUseCase: suggestDestinationsUseCase,
            selectDestinationUseCase: selectDestinationUseCase,
            loadTaxiChoiceUseCase: loadTaxiChoiceUseCase,
            getPickupDaysUseCase: getPickupDaysUseCase,
            requestRideUseCase: requestRideUseCase,
            loadCurrentRideUseCase: loadCurrentRideUseCase,
            watchPushedRidesUseCase: watchPushedRidesUseCase,
            watchRideUseCase: watchRideUseCase,
            cancelRideUseCase: cancelRideUseCase,
            rateRideUseCase: rateRideUseCase,
            bookRideUseCase: bookRideUseCase,
            getPickupForArrivalUseCase: getPickupForArrivalUseCase,
            loadRideHistoryUseCase: loadRideHistoryUseCase,
            cancelBookingUseCase: cancelBookingUseCase,
            loadAccountUseCase: loadAccountUseCase,
            updateNotificationsUseCase: updateNotificationsUseCase,
            onSignOutRequested: () =>
                context.read<AuthBloc>().add(const AuthSignOutRequested()),
          ),
        ),
      ],
      AuthAuthenticated(role: UserRole.driver) => [
        MaterialPage<void>(
          key: const ValueKey('driver-home'),
          child: DriverHomePage(
            loadCurrentDriverRideUseCase: loadCurrentDriverRideUseCase,
            loadDriverDocumentsUseCase: loadDriverDocumentsUseCase,
            loadDriverHomeUseCase: loadDriverHomeUseCase,
            setOnlineUseCase: setOnlineUseCase,
            setReceivesBookingsUseCase: setReceivesBookingsUseCase,
            shareDriverPositionUseCase: shareDriverPositionUseCase,
            watchConnectionUseCase: watchConnectionUseCase,
            watchRideRequestsUseCase: watchRideRequestsUseCase,
            acceptRideRequestUseCase: acceptRideRequestUseCase,
            declineRideRequestUseCase: declineRideRequestUseCase,
            watchGuidanceUseCase: watchGuidanceUseCase,
            arriveAtPickupUseCase: arriveAtPickupUseCase,
            startRideUseCase: startRideUseCase,
            reportNoShowUseCase: reportNoShowUseCase,
            withdrawFromRideUseCase: withdrawFromRideUseCase,
            watchPassengerCancellationUseCase:
                watchPassengerCancellationUseCase,
            loadRideCheckoutUseCase: loadRideCheckoutUseCase,
            completeRideUseCase: completeRideUseCase,
            loadDriverBookingsUseCase: loadDriverBookingsUseCase,
            acceptBookingUseCase: acceptBookingUseCase,
            withdrawFromBookingUseCase: withdrawFromBookingUseCase,
            refuseBookingUseCase: refuseBookingUseCase,
            departForBookingUseCase: departForBookingUseCase,
            watchPushedRidesUseCase: watchPushedRidesUseCase,
            loadWeeklyEarningsUseCase: loadWeeklyEarningsUseCase,
            loadDriverAccountUseCase: loadDriverAccountUseCase,
            updateDriverNotificationsUseCase: updateDriverNotificationsUseCase,
            onSignOutRequested: () =>
                context.read<AuthBloc>().add(const AuthSignOutRequested()),
          ),
        ),
      ],
      _ => [welcomePage],
    };
  }

  void _onRegistrationCompleted(BuildContext context) {
    context.read<AuthBloc>().add(const AuthRegistrationCompleted());
  }

  void _onAuthError(BuildContext context, AuthError error) {
    showToast(
      context: context,
      builder: (ctx, overlay) => SurfaceCard(
        child: Basic(
          title: const Text('Erreur'),
          subtitle: Text(error.message),
          trailing: PrimaryButton(
            size: ButtonSize.small,
            onPressed: overlay.close,
            child: const Text('OK'),
          ),
        ),
      ),
    );
  }
}
