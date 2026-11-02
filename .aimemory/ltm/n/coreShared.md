# id: coreShared
# tags: core,widgets,formatters,location,route,connection,reuse
# sum: Shared code to reuse before writing anything new

#N id|kind|path|note
Location|repo|lib/core/data/repositories/location_repository_impl.dart|getCurrentPosition, watchPosition (3 s on Android)
Route|repo|lib/core/data/repositories/route_repository_impl.dart|Mapbox Directions: driving-traffic, driving with arrive_by, navigation steps
Connection|uc|lib/core/domain/usecases/watch_connection_usecase.dart|.info/connected
RideRoute|ent|lib/core/domain/entities/ride_route.dart|distance, duration, path, pickupForArrival
NavigationRoute|ent|lib/core/domain/entities/navigation_route.dart|guidanceFrom
RideMap|wdg|lib/core/widgets/ride_map.dart|map with the taxi and the remaining road
DioFailure|mod|lib/core/errors/dio_exception_failure.dart|toFailure: no response is a network failure

#F durable facts
formatters in lib/core/utils: price (formatEuro, formatEuroRange, parseEuroCents), distance (formatDistanceKm), time (formatClockTime, formatPickupTime), rating, email_validator
widgets in lib/core/widgets: BottomPanel, ChoiceButton, ConnectionLostBanner, DestinationMarker, LicensePlate, MapPill, MapRoute, MessageToast, PlaceListTile, RecenterButton, RetryMessage, RideMap, SectionLabel, SwipeButton, TaxiMeter
colors in lib/core/theme/app_colors.dart; constants in lib/core/constants/app_constants.dart
repositories that wrap a stream use StreamTransformer.fromHandlers, not async*: cancelling an await for would wait for the next event, which may never come
stream_transform gives switchMap, combineLatest, throttle, whereType
