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
import 'package:mobile/core/data/datasources/enterprise_contact_remote_datasource.dart';
import 'package:mobile/core/data/datasources/push_registration_remote_datasource.dart';
import 'package:mobile/core/data/datasources/route_remote_datasource.dart';
import 'package:mobile/core/data/repositories/connection_repository_impl.dart';
import 'package:mobile/core/data/repositories/email_availability_repository_impl.dart';
import 'package:mobile/core/data/repositories/enterprise_contact_repository_impl.dart';
import 'package:mobile/core/data/repositories/location_repository_impl.dart';
import 'package:mobile/core/data/repositories/navigation_repository_impl.dart';
import 'package:mobile/core/data/repositories/notification_permission_repository_impl.dart';
import 'package:mobile/core/data/repositories/push_registration_repository_impl.dart';
import 'package:mobile/core/data/repositories/route_repository_impl.dart';
import 'package:mobile/core/domain/usecases/call_enterprise_usecase.dart';
import 'package:mobile/core/domain/usecases/call_phone_usecase.dart';
import 'package:mobile/core/domain/usecases/check_email_availability_usecase.dart';
import 'package:mobile/core/domain/usecases/enable_notifications_usecase.dart';
import 'package:mobile/core/domain/usecases/ensure_notification_permission_usecase.dart';
import 'package:mobile/core/domain/usecases/load_notification_permission_usecase.dart';
import 'package:mobile/core/domain/usecases/message_phone_usecase.dart';
import 'package:mobile/core/domain/usecases/open_navigation_usecase.dart';
import 'package:mobile/core/domain/usecases/open_notification_settings_usecase.dart';
import 'package:mobile/core/domain/usecases/register_push_token_usecase.dart';
import 'package:mobile/core/domain/usecases/unregister_push_token_usecase.dart';
import 'package:mobile/core/domain/usecases/watch_connection_usecase.dart';
import 'package:mobile/core/domain/usecases/watch_push_token_refresh_usecase.dart';
import 'package:mobile/core/domain/usecases/watch_pushed_rides_usecase.dart';
import 'package:mobile/core/network/auth_interceptor.dart';
import 'package:mobile/core/presentation/bloc/connectivity_bloc.dart';
import 'package:mobile/core/presentation/bloc/contact_us_bloc.dart';
import 'package:mobile/core/presentation/bloc/navigation_bloc.dart';
import 'package:mobile/core/presentation/bloc/notification_permission_bloc.dart';
import 'package:mobile/core/presentation/bloc/ride_contact_bloc.dart';
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
import 'package:mobile/features/driver_home/data/datasources/driver_account_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_activity_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_booking_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_document_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_document_remote_datasource_fake.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_presence_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_ride_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/datasources/earnings_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/datasources/ride_checkout_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/datasources/ride_request_remote_datasource.dart';
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
import 'package:mobile/features/driver_home/domain/usecases/go_offline_to_sign_out_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_accepted_bookings_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_available_bookings_page_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_available_bookings_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_current_driver_ride_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_account_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_documents_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/submit_driver_document_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_document_notifications_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_online_allowed_usecase.dart';
import 'package:mobile/core/domain/usecases/open_location_settings_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_activity_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_home_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_ride_checkout_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_earnings_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/refuse_booking_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/report_no_show_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/restore_driver_presence_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/set_online_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/share_driver_position_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/start_ride_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_guidance_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_passenger_cancellation_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_ride_requests_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/withdraw_from_booking_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/withdraw_from_ride_usecase.dart';
import 'package:mobile/features/passenger_home/data/datasources/account_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/datasources/nearby_taxi_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/datasources/place_search_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/datasources/recent_destination_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/datasources/ride_booking_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/datasources/ride_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/datasources/saved_place_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/datasources/taxi_offer_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/repositories/account_repository_impl.dart';
import 'package:mobile/features/passenger_home/data/repositories/nearby_taxi_repository_impl.dart';
import 'package:mobile/features/passenger_home/data/repositories/place_search_repository_impl.dart';
import 'package:mobile/features/passenger_home/data/repositories/recent_destination_repository_impl.dart';
import 'package:mobile/features/passenger_home/data/repositories/ride_repository_impl.dart';
import 'package:mobile/features/passenger_home/data/repositories/saved_place_repository_impl.dart';
import 'package:mobile/features/passenger_home/data/repositories/taxi_offer_repository_impl.dart';
import 'package:mobile/features/passenger_home/domain/usecases/add_saved_place_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/book_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/cancel_booking_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/cancel_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/change_saved_place_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/delete_saved_place_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/find_place_at_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/get_pickup_days_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/get_pickup_for_arrival_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_account_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_bookings_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_current_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_passenger_home_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_past_rides_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_recent_destinations_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_taxi_choice_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/offer_from_pickup_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/rate_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/refresh_pickup_position_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/request_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/select_destination_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/suggest_destinations_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/watch_nearby_taxis_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/watch_ride_usecase.dart';
import 'package:mobile/features/registration/driver/data/datasources/commune_remote_datasource.dart';
import 'package:mobile/features/registration/driver/data/datasources/driver_registration_remote_datasource.dart';
import 'package:mobile/features/registration/driver/data/datasources/registration_document_remote_datasource.dart';
import 'package:mobile/features/registration/driver/data/repositories/commune_repository_impl.dart';
import 'package:mobile/features/registration/driver/data/repositories/driver_registration_repository_impl.dart';
import 'package:mobile/features/registration/driver/data/repositories/registration_document_repository_impl.dart';
import 'package:mobile/features/registration/driver/domain/usecases/check_registration_validated_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/watch_validation_notification_opened_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/get_document_signed_url_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/get_document_types_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/get_uploaded_documents_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/search_communes_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/send_registration_push_token_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/submit_registration_vehicle_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/upload_registration_document_usecase.dart';
import 'package:mobile/features/registration/passenger/data/datasources/registration_remote_datasource.dart';
import 'package:mobile/features/registration/passenger/data/repositories/registration_repository_impl.dart';
import 'package:mobile/features/registration/passenger/domain/usecases/complete_passenger_registration_usecase.dart';
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
    // La permission des notifications : à l'inscription, puis aux actions qui
    // en dépendent et dans l'onglet Compte. Spec permission-notifications.md.
    const notificationPermissionRepo = NotificationPermissionRepositoryImpl();
    const ensureNotificationPermissionUseCase =
        EnsureNotificationPermissionUseCase(notificationPermissionRepo);

    // Recherche d'adresses : appel direct à Mapbox, sans l'intercepteur Firebase
    // (le token d'auth de l'app ne doit pas partir chez Mapbox).
    final mapboxDio = Dio(BaseOptions(baseUrl: 'https://api.mapbox.com'));
    final placeSearchRepo = PlaceSearchRepositoryImpl(
      PlaceSearchRemoteDataSourceImpl(
        mapboxDio,
        accessToken: config.mapboxAccessToken,
      ),
    );

    // L'adresse sous chaque épingle (départ, « Maison », « Travail ») et le
    // nom du départ envoyé à l'estimation : Mapbox, comme la recherche
    // (choix du user, spec point-de-prise-en-charge.md, « Tout sur Mapbox »).
    final findPlaceAtUseCase = FindPlaceAtUseCase(placeSearchRepo);

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
    final taxiOfferRepo = TaxiOfferRepositoryImpl(
      TaxiOfferRemoteDataSourceImpl(dio),
    );
    final loadTaxiChoiceUseCase = LoadTaxiChoiceUseCase(
      routeRepository: routeRepo,
      taxiOfferRepository: taxiOfferRepo,
      findPlaceAtUseCase: findPlaceAtUseCase,
    );

    // Compte passager : profil réel (GET /v1/me), spec
    // taxi-vroom-api/docs/specs/compte-a-jour.md.
    final accountRepo = AccountRepositoryImpl(AccountRemoteDataSourceImpl(dio));
    // « Maison » et « Travail » via l'API, partagés par l'accueil et le
    // compte du passager, spec taxi-vroom-api/docs/specs/maison-et-travail.md.
    final savedPlaceRepo = SavedPlaceRepositoryImpl(
      SavedPlaceRemoteDataSourceImpl(dio),
    );

    // Position GPS, partagée par les accueils passager et chauffeur.
    final locationRepo = LocationRepositoryImpl(DeviceLocationDataSourceImpl());

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
    final connectionRepo = ConnectionRepositoryImpl(
      ConnectionRemoteDataSourceImpl(realtimeDatabase),
    );
    final watchConnectionUseCase = WatchConnectionUseCase(connectionRepo);

    // Accueil passager : position, « Maison » et « Travail ».
    final loadPassengerHomeUseCase = LoadPassengerHomeUseCase(
      locationRepository: locationRepo,
      savedPlaceRepository: savedPlaceRepo,
    );
    // « Position actuelle » relue quand le passager quitte l'accueil pour
    // commander.
    final refreshPickupPositionUseCase = RefreshPickupPositionUseCase(
      locationRepo,
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

    // Accueil chauffeur : la pastille et les trois cases, GET
    // /v1/drivers/me/activity, spec taxi-vroom-api/docs/specs/gains-reels.md.
    final driverActivityRepo = DriverActivityRepositoryImpl(
      DriverActivityRemoteDataSourceImpl(dio),
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
    // Étapes de la course par l'API ; « 5e passager et plus » par l'API aussi
    // (spec taxi-vroom-api/docs/specs/nombre-de-passagers.md), les autres
    // suppléments et la note du client encore simulés. Le paiement se fait à
    // bord, hors de l'app. Pour tout simuler (code de montée « 4817 »),
    // passer DriverRideRemoteDataSourceFake() aux deux arguments.
    final driverRideRepo = DriverRideRepositoryImpl(
      DriverRideRemoteDataSourceImpl(realtimeDatabase, dio),
      RideCheckoutRemoteDataSourceImpl(dio),
    );
    // Réservations chauffeur, via l'API : une seule instance, partagée par
    // l'accueil (prochaine réservation) et l'onglet Réservations. Pour
    // simuler, passer DriverBookingRemoteDataSourceFake().
    final driverBookingRepo = DriverBookingRepositoryImpl(
      DriverBookingRemoteDataSourceImpl(dio, realtimeDatabase),
    );
    // Documents du chauffeur, lus depuis l'API (spec
    // taxi-vroom-api/docs/specs/documents-du-chauffeur.md). Pour simuler :
    // DriverDocumentRemoteDataSourceFake(hasDocumentToRenew: true).
    final driverDocumentRepo = DriverDocumentRepositoryImpl(
      DriverDocumentRemoteDataSourceImpl(dio),
    );

    // Compte chauffeur : profil, véhicule et documents en un appel (spec
    // taxi-vroom-api/docs/specs/compte-a-jour.md).
    final driverAccountRepo = DriverAccountRepositoryImpl(
      DriverAccountRemoteDataSourceImpl(dio),
    );
    // Le numéro de « Contacter le développeur » : demandé à chaque ouverture
    // du « Compte », passager et chauffeur, en même temps que le compte.
    final enterpriseContactRepo = EnterpriseContactRepositoryImpl(
      EnterpriseContactRemoteDataSourceImpl(dio),
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
    );
    // « Passer en ligne », et la remise en ligne au démarrage par le même
    // chemin.
    final setOnlineUseCase = SetOnlineUseCase(
      locationRepository: locationRepo,
      driverPresenceRepository: driverPresenceRepo,
      driverDocumentRepository: driverDocumentRepo,
    );

    // Chauffeur.
    final driverRegistrationDataSource = DriverRegistrationRemoteDataSourceImpl(
      dio,
      FirebaseAuth.instance,
    );
    final driverRegistrationRepo = DriverRegistrationRepositoryImpl(
      driverRegistrationDataSource,
    );

    final registrationDocumentDataSource =
        RegistrationDocumentRemoteDataSourceImpl(dio);
    final registrationDocumentRepo = RegistrationDocumentRepositoryImpl(
      registrationDocumentDataSource,
    );

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      child: MultiBlocProvider(
        providers: [
          // "Itinéraire" on the driver's pickup and ride screens. Spec
          // navigation-externe.md.
          BlocProvider(
            create: (_) => NavigationBloc(
              openNavigationUseCase: const OpenNavigationUseCase(
                NavigationRepositoryImpl(),
              ),
            ),
          ),
          // The connection to Firebase, for the banner of the signed-in app:
          // it starts watching when the banner is first built.
          BlocProvider(
            create: (_) => ConnectivityBloc(
              watchConnectionUseCase: watchConnectionUseCase,
            )..add(const ConnectivityWatchStarted()),
          ),
          // "Appeler" and "Écrire" during a ride, on both sides: the other
          // person's number comes with the ride.
          BlocProvider(
            create: (_) => RideContactBloc(
              callPhoneUseCase: const CallPhoneUseCase(
                NavigationRepositoryImpl(),
              ),
              messagePhoneUseCase: const MessagePhoneUseCase(
                NavigationRepositoryImpl(),
              ),
            ),
          ),
          // "Nous contacter" in both "Compte" tabs: the number comes from
          // the API. Spec taxi-vroom-api/docs/specs/aide-chauffeur.md.
          BlocProvider(
            create: (_) => ContactUsBloc(
              callEnterpriseUseCase: CallEnterpriseUseCase(
                enterpriseContactRepository: enterpriseContactRepo,
                navigationRepository: const NavigationRepositoryImpl(),
              ),
            ),
          ),
          // Above the app: the pages of both roles tell it after an action,
          // and its dialogs open over any screen.
          BlocProvider(
            create: (_) => NotificationPermissionBloc(
              ensureNotificationPermissionUseCase:
                  ensureNotificationPermissionUseCase,
              loadNotificationPermissionUseCase:
                  const LoadNotificationPermissionUseCase(
                    notificationPermissionRepo,
                  ),
              enableNotificationsUseCase: const EnableNotificationsUseCase(
                notificationPermissionRepo,
              ),
              openNotificationSettingsUseCase:
                  const OpenNotificationSettingsUseCase(
                    notificationPermissionRepo,
                  ),
            ),
          ),
          BlocProvider(
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
          ),
        ],
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
            completePassengerRegistrationUseCase:
                CompletePassengerRegistrationUseCase(registrationRepo),
            loadPassengerHomeUseCase: loadPassengerHomeUseCase,
            refreshPickupPositionUseCase: refreshPickupPositionUseCase,
            watchNearbyTaxisUseCase: watchNearbyTaxisUseCase,
            suggestDestinationsUseCase: SuggestDestinationsUseCase(
              placeSearchRepo,
            ),
            selectDestinationUseCase: SelectDestinationUseCase(placeSearchRepo),
            findPlaceAtUseCase: findPlaceAtUseCase,
            offerFromPickupUseCase: OfferFromPickupUseCase(taxiOfferRepo),
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
            loadBookingsUseCase: LoadBookingsUseCase(rideRepo),
            loadPastRidesUseCase: LoadPastRidesUseCase(rideRepo),
            cancelBookingUseCase: CancelBookingUseCase(rideRepo),
            loadAccountUseCase: LoadAccountUseCase(
              accountRepository: accountRepo,
              savedPlaceRepository: savedPlaceRepo,
              enterpriseContactRepository: enterpriseContactRepo,
            ),
            addSavedPlaceUseCase: AddSavedPlaceUseCase(savedPlaceRepo),
            changeSavedPlaceUseCase: ChangeSavedPlaceUseCase(savedPlaceRepo),
            deleteSavedPlaceUseCase: DeleteSavedPlaceUseCase(savedPlaceRepo),
            // Les 3 dernières destinations, dans « Votre trajet » (spec
            // destinations-recentes.md).
            loadRecentDestinationsUseCase: LoadRecentDestinationsUseCase(
              RecentDestinationRepositoryImpl(
                RecentDestinationRemoteDataSourceImpl(dio),
              ),
            ),
            loadDriverDocumentsUseCase: LoadDriverDocumentsUseCase(
              driverDocumentRepo,
            ),
            submitDriverDocumentUseCase: SubmitDriverDocumentUseCase(
              driverDocumentRepo,
            ),
            watchDocumentNotificationsUseCase:
                WatchDocumentNotificationsUseCase(pushRegistrationRepo),
            watchOnlineAllowedUseCase: WatchOnlineAllowedUseCase(
              driverPresenceRepo,
            ),
            openLocationSettingsUseCase: OpenLocationSettingsUseCase(
              locationRepo,
            ),
            loadDriverHomeUseCase: loadDriverHomeUseCase,
            loadDriverActivityUseCase: LoadDriverActivityUseCase(
              driverActivityRepo,
            ),
            setOnlineUseCase: setOnlineUseCase,
            shareDriverPositionUseCase: ShareDriverPositionUseCase(
              locationRepository: locationRepo,
              driverPresenceRepository: driverPresenceRepo,
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
              drivingPositionRepository: DeviceDrivingPositionRepository(
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
            loadAvailableBookingsUseCase: LoadAvailableBookingsUseCase(
              driverBookingRepository: driverBookingRepo,
              locationRepository: locationRepo,
            ),
            loadAvailableBookingsPageUseCase: LoadAvailableBookingsPageUseCase(
              driverBookingRepo,
            ),
            loadAcceptedBookingsUseCase: LoadAcceptedBookingsUseCase(
              driverBookingRepo,
            ),
            acceptBookingUseCase: AcceptBookingUseCase(driverBookingRepo),
            withdrawFromBookingUseCase: WithdrawFromBookingUseCase(
              driverBookingRepo,
            ),
            refuseBookingUseCase: RefuseBookingUseCase(driverBookingRepo),
            departForBookingUseCase: DepartForBookingUseCase(
              driverBookingRepo,
            ),
            // Gains : GET /v1/drivers/me/earnings, spec
            // taxi-vroom-api/docs/specs/gains-reels.md.
            loadEarningsUseCase: LoadEarningsUseCase(
              EarningsRepositoryImpl(EarningsRemoteDataSourceImpl(dio)),
            ),
            loadDriverAccountUseCase: LoadDriverAccountUseCase(
              driverAccountRepository: driverAccountRepo,
              enterpriseContactRepository: enterpriseContactRepo,
            ),
            // Présence au démarrage et à la déconnexion : spec
            // presence-du-chauffeur-au-demarrage.md.
            restoreDriverPresenceUseCase: RestoreDriverPresenceUseCase(
              driverRideRepository: driverRideRepo,
              driverPresenceRepository: driverPresenceRepo,
              setOnlineUseCase: setOnlineUseCase,
            ),
            goOfflineToSignOutUseCase: GoOfflineToSignOutUseCase(
              connectionRepository: connectionRepo,
              driverPresenceRepository: driverPresenceRepo,
            ),
            driverUpdateRegistrationFlowUseCase: UpdateRegistrationFlowUseCase(
              driverRegistrationRepo,
            ),
            ensureNotificationPermissionUseCase:
                ensureNotificationPermissionUseCase,
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
            submitRegistrationVehicleUseCase: SubmitRegistrationVehicleUseCase(
              driverRegistrationRepo,
            ),
            // "Dossier en cours de vérification": told when it is validated.
            checkRegistrationValidatedUseCase:
                CheckRegistrationValidatedUseCase(
                  driverRegistrationRepo,
                ),
            watchValidationNotificationOpenedUseCase:
                WatchValidationNotificationOpenedUseCase(pushRegistrationRepo),
            sendRegistrationPushTokenUseCase: SendRegistrationPushTokenUseCase(
              pushRegistrationRepository: pushRegistrationRepo,
              driverRegistrationRepository: driverRegistrationRepo,
            ),
            // "Votre taxi": the State's communes, without the Firebase
            // interceptor.
            searchCommunesUseCase: SearchCommunesUseCase(
              CommuneRepositoryImpl(
                CommuneRemoteDataSourceImpl(
                  Dio(BaseOptions(baseUrl: 'https://geo.api.gouv.fr')),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
