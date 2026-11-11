#N id|kind|path|note
AppWiring|cfg|lib/app/view/app.dart|builds everything; comments say how to swap a real source for its fake
AuthNavigator|nav|lib/features/authentication/presentation/navigator/auth_navigator.dart|root FlowBuilder: welcome, phone, OTP, registration, passenger or driver home
AuthBloc|bloc|lib/features/authentication/presentation/bloc/auth_bloc.dart|role choice, OTP, sign out, session restore through GET /v1/me, push registration
PassengerHome|page|lib/features/passenger_home/presentation/pages/passenger_home_page.dart|PassengerFlowBloc stack @ltm:passengerApp
DriverHome|page|lib/features/driver_home/presentation/pages/driver_home_page.dart|DriverFlowBloc stack @ltm:driverApp
Registration|mod|lib/features/registration/|shared pages + passenger and driver navigators @ltm:authRegistration
Core|mod|lib/core/|shared entities, location, routes, connection, widgets, formatters @ltm:coreShared
AuthInterceptor|svc|lib/core/network/auth_interceptor.dart|Firebase token on each call, one forced refresh on 401
Result|mod|lib/core/utils/result.dart|Ok or Error(Failure); Compass app's type
Failures|mod|lib/core/errors/failures.dart|Server, Network, Validation, EstimateExpired, Location
Coordinates|mod|lib/core/domain/entities/coordinates.dart|distanceTo, bearingTo
WatchNearbyTaxis|uc|lib/features/passenger_home/domain/usecases/watch_nearby_taxis_usecase.dart|5 km radius; search moves when the passenger is more than 500 m from the latest search
TaxiOfferSource|ds|lib/features/passenger_home/data/datasources/taxi_offer_remote_datasource.dart|POST /v1/rides, wraps the estimate into the single "Taxi" offer
RideSource|ds|lib/features/passenger_home/data/datasources/ride_remote_datasource.dart|rides/<id> + drivers/<uid> + boarding code from the API
RideFake|ds|lib/features/passenger_home/data/datasources/ride_remote_datasource_fake.dart|simulates bookings; can replace the real ride and offer sources
DriverPresence|ds|lib/features/driver_home/data/datasources/driver_presence_remote_datasource.dart|drivers/<uid> with onDisconnect
RideRequestSource|ds|lib/features/driver_home/data/datasources/ride_request_remote_datasource.dart|rideOffers/<uid>, answers through the API
DriverRideSource|ds|lib/features/driver_home/data/datasources/driver_ride_remote_datasource.dart|ride steps through the API, status from rides/<id>/status

#E from>rel>to
AppWiring>wires>AuthNavigator
AppWiring>wires>WatchNearbyTaxis
AppWiring>wires>TaxiOfferSource
AppWiring>wires>RideSource
AppWiring>wires>RideFake
AuthBloc>drives>AuthNavigator
AuthNavigator>opens>PassengerHome
AuthNavigator>opens>DriverHome
AuthNavigator>opens>Registration
PassengerHome>uses>RideSource
DriverHome>uses>DriverPresence
DriverHome>uses>RideRequestSource
DriverHome>uses>DriverRideSource

#B key=value
stack=Flutter+Bloc+flow_builder+shadcn_flutter+Dio+Firebase(Auth,RTDB)+Mapbox(maps,Directions,SearchBox)+geolocator
size=about 385 dart files in lib, 20 test files, 85 tests
mapboxCalls=a second Dio pointed at api.mapbox.com, without the auth interceptor, so the Firebase token never leaves for Mapbox
addresses=all on Mapbox since 2026-11-11 (Géoplateforme removed, it was down): one FindPlaceAtUseCase on PlaceSearchRepositoryImpl (/reverse, billed per call) for every pin; the estimate sends originName (FindPlaceAtUseCase.knownAddress: the chosen place, or the address found where the phone is), none when unknown
stillFake=driver: checkout supplements, customer rating
pickupTime=PickupTimeChip only on the taxi choice (with "Arriver à"); RIDE.NO_DRIVER_AVAILABLE is NoDriverAvailableFailure, turned by LoadTaxiChoiceUseCase into a choice without offers (greyed card) so a booking stays possible; while that card is greyed and the time is "Maintenant", TaxiChoiceBloc follows WatchNearbyTaxisUseCase and estimates again at the first free taxi (its subscription is cancelled without await: searchCenters is an async* await for on the GPS, awaiting the cancel froze the loader on a still phone); the flow's _home() drops scheduledPickup on every return to the home, keeps pickupPlace; spec taxi-vroom-api/docs/specs/heure-de-prise-en-charge.md
recentDestinations=not on the home anymore; "Votre trajet" (destination field only) reads GET /v1/rides/recent-destinations each time it opens (RecentDestinationsBloc), 3 at most, a tap opens the taxi choice; spec taxi-vroom-api/docs/specs/destinations-recentes.md
savedPlaces="Maison" and "Travail" real (GET/POST/PATCH/DELETE /v1/me/saved-places): loaded with the home (PassengerHome.savedPlaces) and with "Compte" (LoadAccountUseCase, three calls at once); SavedPlacePage (flow state PassengerFlowSavedPlaceEdit, SavedPlaceBloc) adds, changes or deletes, then updates PassengerHomeBloc (PassengerSavedPlaceStored/Removed, no reload) and reloads AccountBloc; PlaceSuggestions is the suggestion list shared with "Votre trajet"; the address kept is Mapbox's (SavedPlace.fromPlace); "Choisir sur la carte" opens the sheet from the button's own context (Builder), else it opened in the home's drawer overlay below (same fix in "Votre trajet", 2026-11-12: any shadcn openSheet must get a context inside the page's own Scaffold, never the State's, which sits above it); the nearby taxis stream rebuilds PassengerHomeReady from the state's home, not the first load's
emulators=a wiped emulator starts in California and has about 5 GB free; run both with -d all, two flutter run at once fight over build/
rtdbListBug=firebase_database 12.6.0: .children on a list read through .child() crashes, the plugin numbers it from -1; read .value instead. A top-level snapshot of keyed entries is fine
blocLint=dart run bloc_tools:bloc lint . asks for an update: answer n on stdin; 6 pre-existing warnings in registration_bloc
passengerRegistration=the last screen is the notifications step; leaving it calls POST /v1/passengers, which finalizes the registration (COMPLETE) and creates the user. A finalized registration skips the registration screens: AuthBloc checks RegistrationFlowEntity.isComplete and goes home
ciFlutterMismatch=CI (.github/workflows/main.yaml) only runs on push or PR to main and pins Flutter 3.35.x, while pubspec.yaml requires flutter ^3.38.1
templateLeftover=lib/counter is the Very Good template, the only Cubit left; its tests still run
releaseTodo=before the first staging/prod build, create taxi-vroom-staging and taxi-vroom-prod public Mapbox tokens: the same dev token is in .env.dev, .env.stg and .env.prod
pushDisplay=FCM notification messages: the system shows them, none on screen while the app is in the foreground; no background handler; channel rides created in MainActivity.kt
bookings=passenger: TaxiChoiceStarted carries scheduledPickup, the estimate is priced for it and booked by ride id; foreground pushes (FirebaseMessaging.onMessage) re-run PassengerFlowStarted. Driver: LoadDriverBookingsUseCase needs the position; passenger and luggage counts are fixed in the model like for offers; "Je pars" (canDepart from the API) emits DriverBookingsDeparted, which driver_home_page turns into DriverRideAccepted, the same path as an accepted offer; "Mes courses" and "Réservations" reload on each pushed notification (WatchPushedRidesUseCase, listened by several blocs), not in real time
rideResume=passenger: PassengerFlowStarted waits for PassengerHomeReady, the ride page needs the position and FlowBuilder does not regenerate pages on an unchanged state; driver: DriverFlowStarted checks the ride before the documents and goes back online

# stub for LTM overflow
#N product|@ltm|ltm:product|Ride-hailing for French taxis; realtime and supply decisions
#N passengerMockup|@ltm|ltm:passengerMockup|HTML mockup of the passenger workflow
#N passengerApp|@ltm|ltm:passengerApp|passenger screens, flow states, ride tracking, booking rules
#N driverApp|@ltm|ltm:driverApp|driver screens, flow states, presence, offers, ride steps
#N authRegistration|@ltm|ltm:authRegistration|login and registration flows
#N coreShared|@ltm|ltm:coreShared|shared code to reuse before writing anything new
