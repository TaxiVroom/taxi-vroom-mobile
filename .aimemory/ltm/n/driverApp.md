# id: driverApp
# tags: driver,presence,offer,pickup,boarding,guidance,checkout,earnings,documents
# sum: Driver screens, flow states, presence, offers, ride steps

#N id|kind|path|note
FlowBloc|bloc|lib/features/driver_home/presentation/bloc/driver_flow_bloc.dart|states below, watches passenger cancellation
HomeBloc|bloc|lib/features/driver_home/presentation/bloc/driver_home_bloc.dart|online state, position sharing
RideRequestBloc|bloc|lib/features/driver_home/presentation/bloc/ride_request_bloc.dart|offer sheet and countdown
BoardingBloc|bloc|lib/features/driver_home/presentation/bloc/boarding_bloc.dart|code entry, no-show wait
GuidanceBloc|bloc|lib/features/driver_home/presentation/bloc/guidance_bloc.dart|turn-by-turn
CheckoutBloc|bloc|lib/features/driver_home/presentation/bloc/checkout_bloc.dart|meter amount, supplements
SharePosition|uc|lib/features/driver_home/domain/usecases/share_driver_position_usecase.dart|throttled writes
WatchRequests|uc|lib/features/driver_home/domain/usecases/watch_ride_requests_usecase.dart|adds roads, tells a cancelled offer from an expired one
RideCheckout|ent|lib/features/driver_home/domain/entities/ride_checkout.dart|total rule
DriverDocuments|ent|lib/features/driver_home/domain/entities/driver_documents.dart|needsAction, blocksDriving

#E from>rel>to
FlowBloc>opens>BoardingBloc
FlowBloc>opens>GuidanceBloc
FlowBloc>opens>CheckoutBloc
RideRequestBloc>uses>WatchRequests
HomeBloc>uses>SharePosition

#F durable facts
flow states: CheckingDocuments, DocumentsFailure, Documents, DocumentsReview, Home, Pickup, Boarding, InRide, Checkout
tabs: Conduire, Réservations, Gains, Compte
login: documents checked first; "Plus tard" only while nothing blocks driving; the source is fake with hasDocumentToRenew: true in app.dart
presence: drivers/<uid> with onDisconnect remove, re-armed after each reconnection through .info/connected; going offline is not awaited so it works offline
position: at most every 3 s, the latest kept, moves under 10 m ignored
offer: rideOffers/<uid>; null after an offer means cancelled, unless its 15 s ran out; road to the pickup and to the destination computed on the phone, optional
accept: POST then read rides/<id>, readable once the ride is theirs; 409 means no longer available
passenger cancellation is watched on rides/<id>/status during pickup and boarding, then "Le client a annulé la course."
start: 4-digit code, a 422 means refused; attemptsLeft 0 locks at once without another try
no-show: available after 5 min at the pickup
checkout: meterCents typed by the driver from the legal meter, supplements simulated; "Reprendre la course" undoes a mistaken end, nothing was sent yet; payment on board
guidance uses the device GPS; DrivingPositionDataSourceFake simulates a drive without moving
values the API does not send yet: customer rating 5.0, 1 passenger, 0 luggage
