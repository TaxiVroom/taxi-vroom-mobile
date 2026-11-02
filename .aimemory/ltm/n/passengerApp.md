# id: passengerApp
# tags: passenger,home,search,taxi-choice,ride,booking,rating,history,account
# sum: Passenger screens, flow states, ride tracking, booking rules

#N id|kind|path|note
FlowBloc|bloc|lib/features/passenger_home/presentation/bloc/passenger_flow_bloc.dart|states Home, DestinationSearch, TaxiChoice, Ride
HomeBloc|bloc|lib/features/passenger_home/presentation/bloc/passenger_home_bloc.dart|position, nearby taxis, connection banner
TaxiChoiceBloc|bloc|lib/features/passenger_home/presentation/bloc/taxi_choice_bloc.dart|loads the choice, orders, reloads on an expired estimate
RideBloc|bloc|lib/features/passenger_home/presentation/bloc/ride_bloc.dart|follows the ride, cancel, rating
WatchRide|uc|lib/features/passenger_home/domain/usecases/watch_ride_usecase.dart|adds the road and the times to each update
RideEntity|ent|lib/features/passenger_home/domain/entities/ride.dart|sealed, one subtype per status
RideModel|mod|lib/features/passenger_home/data/models/ride_model.dart|same statuses, fromJson per status
SimulatedDriver|mod|lib/features/passenger_home/data/models/simulated_driver_and_vehicle_json.dart|vehicle and rating the API does not know yet
PlaceSearch|ds|lib/features/passenger_home/data/datasources/place_search_remote_datasource.dart|Mapbox Search Box, France, French
PriceSheet|wdg|lib/features/passenger_home/presentation/widgets/price_explanation_sheet.dart|"Comment est calculé le prix ?"

#E from>rel>to
FlowBloc>opens>TaxiChoiceBloc
FlowBloc>opens>RideBloc
RideBloc>uses>WatchRide
WatchRide>reads>RideEntity
RideModel>mapsTo>RideEntity

#F durable facts
tabs: Accueil, Courses, Compte; screens above them come from the FlowBuilder stack
ride subtypes: SearchingDriver, NoDriverFound, PassengerNoShow, DriverApproaching, DriverArrived, InProgress, Completed
watchRide uses switchMap on status: DRIVER_EN_ROUTE is exposed as DRIVER_APPROACHING
the driver name comes from the API as "Prénom N."; rating, vehicle and plate are simulated
the boarding code is read once from the API per status, it never goes through Firebase
while the driver comes, each position asks Mapbox for the road and the ETA; in ride, the road to the destination and the arrival time; a failed route only removes the line
in ride the passenger sees the estimated range: the meter is not connected
receipt: Compteur line, then each supplement, total from rides/<id>/completion
order: requestRide sends only offer.rideId; a 422 gives EstimateExpiredFailure and reloads the price with a message
cancel: a 409 means too late to cancel
bookings (simulated): pickup from now + 30 min, today + 30 days, slots of 15 min; "Arriver à" uses the driving profile with arrive_by
taxi choice text: "Estimation, trajet du taxi jusqu'à vous inclus. Le prix final est celui du taximètre."
legal copy of the range: formatEuroRange floors the low end and ceils the high end, never narrowing it
home map shows free taxis within 5 km, closest first; a connection banner warns when they are no longer live
