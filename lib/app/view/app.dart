import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    show MapboxOptions;
import 'package:mobile/core/data/datasources/connection_remote_datasource.dart';
import 'package:mobile/core/data/datasources/device_location_datasource.dart';
import 'package:mobile/core/data/datasources/email_availability_remote_datasource.dart';
import 'package:mobile/core/data/datasources/push_registration_remote_datasource.dart';
import 'package:mobile/core/data/datasources/route_remote_datasource.dart';
import 'package:mobile/core/data/repositories/connection_repository_impl.dart';
import 'package:mobile/core/data/repositories/email_availability_repository_impl.dart';
import 'package:mobile/core/data/repositories/location_repository_impl.dart';
import 'package:mobile/core/data/repositories/push_registration_repository_impl.dart';
import 'package:mobile/core/data/repositories/route_repository_impl.dart';
import 'package:mobile/core/domain/usecases/check_email_availability_usecase.dart';
import 'package:mobile/core/domain/usecases/register_push_token_usecase.dart';
import 'package:mobile/core/domain/usecases/unregister_push_token_usecase.dart';
import 'package:mobile/core/domain/usecases/watch_connection_usecase.dart';
import 'package:mobile/core/domain/usecases/watch_push_token_refresh_usecase.dart';
import 'package:mobile/core/domain/usecases/watch_pushed_rides_usecase.dart';
import 'package:mobile/core/network/auth_interceptor.dart';
import 'package:mobile/env/app_config.dart';
import 'package:mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:mobile/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/authentication/domain/usecases/get_or_create_registration_flow_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/restore_session_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/send_otp_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/sign_out_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/verify_otp_usecase.dart';
import 'package:mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/authentication/presentation/navigator/auth_navigator.dart';
import 'package:mobile/features/driver_home/data/datasources/demand_remote_datasource_fake.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_account_remote_datasource_fake.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_activity_remote_datasource_fake.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_booking_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_document_remote_datasource_fake.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_presence_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_ride_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_ride_remote_datasource_fake.dart';
import 'package:mobile/features/driver_home/data/datasources/earnings_remote_datasource_fake.dart';
import 'package:mobile/features/driver_home/data/datasources/ride_request_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/repositories/demand_repository_impl.dart';
import 'package:mobile/features/driver_home/data/repositories/device_driving_position_repository.dart';
import 'package:mobile/features/driver_home/data/repositories/driver_account_repository_impl.dart';
import 'package:mobile/features/driver_home/data/repositories/driver_activity_repository_impl.dart';
import 'package:mobile/features/driver_home/data/repositories/driver_booking_repository_impl.dart';
import 'package:mobile/features/driver_home/data/repositories/driver_document_repository_impl.dart';
import 'package:mobile/features/driver_home/data/repositories/driver_presence_repository_impl.dart';
import 'package:mobile/features/driver_home/data/repositories/driver_ride_repository_impl.dart';
import 'package:mobile/features/driver_home/data/repositories/earnings_repository_impl.dart';
import 'package:mobile/features/driver_home/data/repositories/ride_request_repository_impl.dart';
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
import 'package:mobile/features/passenger_home/data/datasources/account_remote_datasource_fake.dart';
import 'package:mobile/features/passenger_home/data/datasources/nearby_taxi_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/datasources/place_search_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/datasources/recent_destination_remote_datasource_fake.dart';
import 'package:mobile/features/passenger_home/data/datasources/ride_booking_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/datasources/ride_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/datasources/taxi_offer_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/repositories/account_repository_impl.dart';
import 'package:mobile/features/passenger_home/data/repositories/nearby_taxi_repository_impl.dart';
import 'package:mobile/features/passenger_home/data/repositories/place_search_repository_impl.dart';
import 'package:mobile/features/passenger_home/data/repositories/recent_destination_repository_impl.dart';
import 'package:mobile/features/passenger_home/data/repositories/ride_repository_impl.dart';
import 'package:mobile/features/passenger_home/data/repositories/taxi_offer_repository_impl.dart';
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
import 'package:mobile/features/registration/passenger/domain/usecases/complete_passenger_registration_usecase.dart';
import 'package:mobile/features/registration/passenger/domain/usecases/request_notification_permission_usecase.dart';
import 'package:mobile/features/registration/shared/domain/usecases/update_registration_flow_usecase.dart';
import 'package:mobile/l10n/l10n.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class App extends StatelessWidget {
  const App({required this.config, super.key});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    MapboxOptions.setAccessToken(config.mapboxAccessToken);

    final dio = Dio(BaseOptions(baseUrl: config.apiBaseUrl));
    dio.interceptors.add(
      AuthInterceptor(firebaseAuth: FirebaseAuth.instance, dio: dio),
    );
    final authDataSource = AuthRemoteDataSourceImpl(FirebaseAuth.instance, dio);
    final authRepo = AuthRepositoryImpl(authDataSource);

    // Téléphone de l'utilisateur, pour lui envoyer des notifications.
    final pushRegistrationRepo = PushRegistrationRepositoryImpl(
      PushRegistrationRemoteDataSourceImpl(FirebaseMessaging.instance, dio),
    );

    final emailAvailabilityDataSource = EmailAvailabilityRemoteDataSourceImpl(
      dio,
    );
    final emailAvailabilityRepo = EmailAvailabilityRepositoryImpl(
      emailAvailabilityDataSource,
    );
    final checkEmailAvailabilityUseCase = CheckEmailAvailabilityUseCase(
      emailAvailabilityRepo,
    );

    // Passager.
    final registrationDataSource = RegistrationRemoteDataSourceImpl(dio);
    final registrationRepo = RegistrationRepositoryImpl(registrationDataSource);
    final passengerNotifRepo = NotificationRepositoryImpl();

    // Recherche d'adresses : appel direct à Mapbox, sans l'intercepteur Firebase
    // (le token d'auth de l'app ne doit pas partir chez Mapbox).
    final mapboxDio = Dio(BaseOptions(baseUrl: 'https://api.mapbox.com'));
    final placeSearchRepo = PlaceSearchRepositoryImpl(
      PlaceSearchRemoteDataSourceImpl(
        mapboxDio,
        accessToken: config.mapboxAccessToken,
      ),
    );

    // Itinéraires réels via Mapbox : choix du taxi et suivi de la course.
    final routeRepo = RouteRepositoryImpl(
      RouteRemoteDataSourceImpl(
        mapboxDio,
        accessToken: config.mapboxAccessToken,
      ),
    );

    // Pour tout simuler (estimation, suivi, notation, réservations et
    // historique) : une seule instance de RideRemoteDataSourceFake(), qui garde
    // l'estimation pour la commande, passée au choix du taxi et à la course.

    // Choix du taxi : prix estimé par le backend, qui crée la course.
    final loadTaxiChoiceUseCase = LoadTaxiChoiceUseCase(
      routeRepository: routeRepo,
      taxiOfferRepository: TaxiOfferRepositoryImpl(
        TaxiOfferRemoteDataSourceImpl(dio),
      ),
    );

    // Compte passager : pas encore d'endpoint backend, profil fake.
    final accountRepo = AccountRepositoryImpl(AccountRemoteDataSourceFake());

    // Position GPS, partagée par les accueils passager et chauffeur.
    const locationRepo = LocationRepositoryImpl(DeviceLocationDataSourceImpl());

    // Firebase Realtime Database, hors États-Unis, donc ouverte avec son URL.
    // Partagée par la présence des chauffeurs, les taxis autour du passager et
    // le suivi des courses.
    // https://firebase.google.com/docs/database/flutter/start
    final realtimeDatabase = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: config.firebaseDatabaseUrl,
    );

    // Course : commandée, réservée, annulée et notée via l'API, suivie dans
    // Firebase. Une seule instance, partagée par la commande, le suivi et
    // l'annulation.
    final rideRepo = RideRepositoryImpl(
      RideRemoteDataSourceImpl(realtimeDatabase, dio),
      RideBookingRemoteDataSourceImpl(dio),
    );
    // Connexion à Firebase, pour prévenir chauffeur et passager quand elle est
    // perdue.
    final watchConnectionUseCase = WatchConnectionUseCase(
      ConnectionRepositoryImpl(
        ConnectionRemoteDataSourceImpl(realtimeDatabase),
      ),
    );

    // Accueil passager. Pas encore d'endpoint backend : destinations fake.
    final loadPassengerHomeUseCase = LoadPassengerHomeUseCase(
      locationRepository: locationRepo,
      recentDestinationRepository: RecentDestinationRepositoryImpl(
        RecentDestinationRemoteDataSourceFake(),
      ),
    );
    // Taxis autour du passager : les chauffeurs en ligne dans Firebase. Pour
    // voir 6 taxis fake même sans chauffeur en ligne, remplacer la source par
    // NearbyTaxiRemoteDataSourceFake().
    final watchNearbyTaxisUseCase = WatchNearbyTaxisUseCase(
      nearbyTaxiRepository: NearbyTaxiRepositoryImpl(
        NearbyTaxiRemoteDataSourceImpl(realtimeDatabase),
      ),
      locationRepository: locationRepo,
    );

    // Accueil chauffeur. Pas encore d'endpoint backend : disponibilité, demande
    // et réservations sont fake. Une seule instance de disponibilité, partagée
    // par le chargement et les changements d'état.
    final driverActivityRepo = DriverActivityRepositoryImpl(
      DriverActivityRemoteDataSourceFake(),
    );
    // Demandes de course : proposées par le backend dans Firebase, réponses
    // via l'API. Une seule instance, partagée par le suivi, l'acceptation et
    // le refus. Pour tester sans passager, remplacer la source par
    // RideRequestRemoteDataSourceFake(sendsRideRequests: true).
    final rideRequestRepo = RideRequestRepositoryImpl(
      RideRequestRemoteDataSourceImpl(
        realtimeDatabase,
        FirebaseAuth.instance,
        dio,
      ),
    );
    // Étapes de la course par l'API ; suppléments et note du client encore
    // simulés. Le paiement se fait à bord, hors de l'app. Pour tout simuler (code de montée « 4817 »), passer
    // driverRideFake en premier argument aussi.
    final driverRideFake = DriverRideRemoteDataSourceFake();
    final driverRideRepo = DriverRideRepositoryImpl(
      DriverRideRemoteDataSourceImpl(realtimeDatabase, dio),
      driverRideFake,
    );
    // Réservations chauffeur, via l'API : une seule instance, partagée par
    // l'accueil (prochaine réservation) et l'onglet Réservations. Pour
    // simuler, passer DriverBookingRemoteDataSourceFake().
    final driverBookingRepo = DriverBookingRepositoryImpl(
      DriverBookingRemoteDataSourceImpl(dio, realtimeDatabase),
    );
    // Documents du chauffeur : une seule instance, pour le contrôle à la
    // connexion et l'onglet Compte. Pour voir l'écran « Vos documents » à la
    // connexion, avec un document à renouveler : hasDocumentToRenew: true.
    final driverDocumentRepo = DriverDocumentRepositoryImpl(
      DriverDocumentRemoteDataSourceFake(hasDocumentToRenew: true),
    );

    // Compte chauffeur : pas encore d'endpoint backend, profil fake.
    final driverAccountRepo = DriverAccountRepositoryImpl(
      DriverAccountRemoteDataSourceFake(),
    );
    // Présence des chauffeurs en ligne, dans Firebase Realtime Database.
    final driverPresenceRepo = DriverPresenceRepositoryImpl(
      DriverPresenceRemoteDataSourceImpl(
        realtimeDatabase,
        FirebaseAuth.instance,
      ),
    );
    final loadDriverHomeUseCase = LoadDriverHomeUseCase(
      locationRepository: locationRepo,
      driverActivityRepository: driverActivityRepo,
      demandRepository: DemandRepositoryImpl(DemandRemoteDataSourceFake()),
      driverBookingRepository: driverBookingRepo,
    );

    // Chauffeur.
    final driverRegistrationDataSource = DriverRegistrationRemoteDataSourceImpl(
      dio,
    );
    final driverRegistrationRepo = DriverRegistrationRepositoryImpl(
      driverRegistrationDataSource,
    );
    final driverNotifRepo = DriverNotificationRepositoryImpl();

    final registrationDocumentDataSource =
        RegistrationDocumentRemoteDataSourceImpl(dio);
    final registrationDocumentRepo = RegistrationDocumentRepositoryImpl(
      registrationDocumentDataSource,
    );

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      child: BlocProvider(
        create: (_) => AuthBloc(
          sendOtpUseCase: SendOtpUseCase(authRepo),
          verifyOtpUseCase: VerifyOtpUseCase(authRepo),
          getOrCreateRegistrationFlowUseCase:
              GetOrCreateRegistrationFlowUseCase(authRepo),
          signOutUseCase: SignOutUseCase(authRepo),
          registerPushTokenUseCase: RegisterPushTokenUseCase(
            pushRegistrationRepo,
          ),
          unregisterPushTokenUseCase: UnregisterPushTokenUseCase(
            pushRegistrationRepo,
          ),
          watchPushTokenRefreshUseCase: WatchPushTokenRefreshUseCase(
            pushRegistrationRepo,
          ),
          restoreSessionUseCase: RestoreSessionUseCase(authRepo),
        )..add(const AuthSessionRestoreRequested()),
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
            completePassengerRegistrationUseCase:
                CompletePassengerRegistrationUseCase(registrationRepo),
            loadPassengerHomeUseCase: loadPassengerHomeUseCase,
            watchNearbyTaxisUseCase: watchNearbyTaxisUseCase,
            watchConnectionUseCase: watchConnectionUseCase,
            suggestDestinationsUseCase: SuggestDestinationsUseCase(
              placeSearchRepo,
            ),
            selectDestinationUseCase: SelectDestinationUseCase(placeSearchRepo),
            loadTaxiChoiceUseCase: loadTaxiChoiceUseCase,
            getPickupDaysUseCase: const GetPickupDaysUseCase(),
            requestRideUseCase: RequestRideUseCase(rideRepo),
            loadCurrentRideUseCase: LoadCurrentRideUseCase(
              rideRepository: rideRepo,
              pushRegistrationRepository: pushRegistrationRepo,
            ),
            watchPushedRidesUseCase: WatchPushedRidesUseCase(
              pushRegistrationRepo,
            ),
            loadCurrentDriverRideUseCase: LoadCurrentDriverRideUseCase(
              driverRideRepo,
            ),
            watchRideUseCase: WatchRideUseCase(
              rideRepository: rideRepo,
              routeRepository: routeRepo,
            ),
            cancelRideUseCase: CancelRideUseCase(rideRepo),
            rateRideUseCase: RateRideUseCase(rideRepo),
            bookRideUseCase: BookRideUseCase(rideRepo),
            getPickupForArrivalUseCase: GetPickupForArrivalUseCase(routeRepo),
            loadRideHistoryUseCase: LoadRideHistoryUseCase(rideRepo),
            cancelBookingUseCase: CancelBookingUseCase(rideRepo),
            loadAccountUseCase: LoadAccountUseCase(accountRepo),
            updateNotificationsUseCase: UpdateNotificationsUseCase(accountRepo),
            loadDriverDocumentsUseCase: LoadDriverDocumentsUseCase(
              driverDocumentRepo,
            ),
            loadDriverHomeUseCase: loadDriverHomeUseCase,
            setOnlineUseCase: SetOnlineUseCase(
              locationRepository: locationRepo,
              driverPresenceRepository: driverPresenceRepo,
              driverActivityRepository: driverActivityRepo,
            ),
            shareDriverPositionUseCase: ShareDriverPositionUseCase(
              locationRepository: locationRepo,
              driverPresenceRepository: driverPresenceRepo,
            ),
            setReceivesBookingsUseCase: SetReceivesBookingsUseCase(
              driverActivityRepo,
            ),
            watchRideRequestsUseCase: WatchRideRequestsUseCase(
              rideRequestRepository: rideRequestRepo,
              routeRepository: routeRepo,
            ),
            acceptRideRequestUseCase: AcceptRideRequestUseCase(
              rideRequestRepo,
            ),
            declineRideRequestUseCase: DeclineRideRequestUseCase(
              rideRequestRepo,
            ),
            // Guidage : vrais itinéraires Mapbox, mais trajet simulé en
            // accéléré en attendant le GPS en conduite.
            watchGuidanceUseCase: WatchGuidanceUseCase(
              locationRepository: locationRepo,
              routeRepository: routeRepo,
              // Position réelle du téléphone. Pour simuler un trajet sans
              // rouler : DrivingPositionRepositoryImpl(
              // DrivingPositionDataSourceFake()).
              drivingPositionRepository: const DeviceDrivingPositionRepository(
                locationRepo,
              ),
            ),
            arriveAtPickupUseCase: ArriveAtPickupUseCase(driverRideRepo),
            startRideUseCase: StartRideUseCase(driverRideRepo),
            reportNoShowUseCase: ReportNoShowUseCase(driverRideRepo),
            withdrawFromRideUseCase: WithdrawFromRideUseCase(driverRideRepo),
            watchPassengerCancellationUseCase:
                WatchPassengerCancellationUseCase(driverRideRepo),
            loadRideCheckoutUseCase: LoadRideCheckoutUseCase(driverRideRepo),
            completeRideUseCase: CompleteRideUseCase(driverRideRepo),
            loadDriverBookingsUseCase: LoadDriverBookingsUseCase(
              driverBookingRepository: driverBookingRepo,
              locationRepository: locationRepo,
            ),
            acceptBookingUseCase: AcceptBookingUseCase(driverBookingRepo),
            withdrawFromBookingUseCase: WithdrawFromBookingUseCase(
              driverBookingRepo,
            ),
            refuseBookingUseCase: RefuseBookingUseCase(driverBookingRepo),
            departForBookingUseCase: DepartForBookingUseCase(
              driverBookingRepo,
            ),
            // Gains : pas encore d'endpoint backend, semaine fake.
            loadWeeklyEarningsUseCase: LoadWeeklyEarningsUseCase(
              EarningsRepositoryImpl(EarningsRemoteDataSourceFake()),
            ),
            loadDriverAccountUseCase: LoadDriverAccountUseCase(
              driverAccountRepository: driverAccountRepo,
              driverDocumentRepository: driverDocumentRepo,
            ),
            updateDriverNotificationsUseCase: UpdateDriverNotificationsUseCase(
              driverAccountRepo,
            ),
            driverUpdateRegistrationFlowUseCase: UpdateRegistrationFlowUseCase(
              driverRegistrationRepo,
            ),
            requestDriverNotificationPermissionUseCase:
                RequestDriverNotificationPermissionUseCase(driverNotifRepo),
            checkEmailAvailabilityUseCase: checkEmailAvailabilityUseCase,
            getDocumentTypesUseCase: GetDocumentTypesUseCase(
              registrationDocumentRepo,
            ),
            uploadRegistrationDocumentUseCase:
                UploadRegistrationDocumentUseCase(registrationDocumentRepo),
            getUploadedDocumentsUseCase: GetUploadedDocumentsUseCase(
              registrationDocumentRepo,
            ),
            getDocumentSignedUrlUseCase: GetDocumentSignedUrlUseCase(
              registrationDocumentRepo,
            ),
          ),
        ),
      ),
    );
  }
}
