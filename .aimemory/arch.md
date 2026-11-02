#N id|kind|path|note
AppWiring|cfg|lib/app/view/app.dart|builds everything; comments say how to swap a real source for its fake
WatchNearbyTaxis|uc|lib/features/passenger_home/domain/usecases/watch_nearby_taxis_usecase.dart|5 km radius; search moves when the passenger is more than 500 m from the latest search
TaxiOfferSource|ds|lib/features/passenger_home/data/datasources/taxi_offer_remote_datasource.dart|POST /v1/rides, wraps the estimate into the single "Taxi" offer
RideFake|ds|lib/features/passenger_home/data/datasources/ride_remote_datasource_fake.dart|simulates rating, bookings, history; also implements TaxiOfferRemoteDataSource

#E from>rel>to
AppWiring>wires>WatchNearbyTaxis
AppWiring>wires>TaxiOfferSource
AppWiring>wires>RideFake

#B key=value
stack=Flutter+Bloc+shadcn_flutter+Firebase+Mapbox
stillFake=passenger: rating, history, bookings, account, recent destinations; driver: activity, bookings, account, earnings, zone demand
emulators=a wiped emulator starts in California and has about 5 GB free; run both with -d all, two flutter run at once fight over build/
blocLint=dart run bloc_tools:bloc lint . asks for an update: answer n on stdin; 6 pre-existing warnings in registration_bloc
passengerRegistration=the last screen is the notifications step; leaving it calls POST /v1/passengers, which finalizes the registration (COMPLETE) and creates the user. A finalized registration skips the registration screens: AuthBloc checks RegistrationFlowEntity.isComplete and goes home
ciFlutterMismatch=CI (.github/workflows/main.yaml) only runs on push or PR to main and pins Flutter 3.35.x, while pubspec.yaml requires flutter ^3.38.1
releaseTodo=before the first staging/prod build, create taxi-vroom-staging and taxi-vroom-prod public Mapbox tokens: the same dev token is in .env.dev, .env.stg and .env.prod

# stub for LTM overflow
#N product|@ltm|ltm:product|Uber-like for French taxis; realtime and supply decisions
#N passengerMockup|@ltm|ltm:passengerMockup|HTML mockup of the passenger workflow
