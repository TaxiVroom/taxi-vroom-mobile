# id: coreShared
# tags: core,widgets,formatters,location,route,connection,reuse
# sum: Shared code to reuse before writing anything new

#N id|kind|path|note
Location|repo|lib/core/data/repositories/location_repository_impl.dart|getCurrentPosition, watchPosition (3 s on Android); streams go through SharedPositionStream: never call Geolocator.getPositionStream elsewhere, the plugin keeps the first stream's settings
Route|repo|lib/core/data/repositories/route_repository_impl.dart|Mapbox Directions: driving-traffic, driving with arrive_by, navigation steps
Connection|uc|lib/core/domain/usecases/watch_connection_usecase.dart|.info/connected
RideRoute|ent|lib/core/domain/entities/ride_route.dart|distance, duration, path, pickupForArrival
NavigationRoute|ent|lib/core/domain/entities/navigation_route.dart|guidanceFrom
RideMap|wdg|lib/core/widgets/ride_map.dart|map with the taxi and the remaining road
DioFailure|mod|lib/core/errors/dio_exception_failure.dart|toFailure: no response is a network failure

#F durable facts
formatters in lib/core/utils: price (formatEuro, formatEuroRange, formatWholeEuro "50 €", parseEuroCents), distance (formatDistanceKm), time (formatClockTime, formatPickupTime), rating, email_validator
widgets in lib/core/widgets: BottomPanel, ChoiceButton, ConnectionLostBanner (the banner itself) and ConnectivityBanner (wraps the signed-in app, driven by ConnectivityBloc), DestinationMarker, LicensePlate, MapPill (isLoading: small spinner after the text), MapRoute, MessageToast, PlaceListTile (wrapsSubtitle: the whole detail line instead of "…"), ContactUsRow ("Contacter le développeur", ContactUsBloc), NotificationsRow ("Activer" asks the phone, "Désactiver" opens its settings), RecenterButton, RetryMessage (optional second button, e.g. "Ouvrir les réglages"), RideMap, DocumentCard (a driver's document card, the registration's look: badge and round "+", spinner, check; used by "Mes documents" and "Vos documents"), DocumentPhotoSlot and pickDocumentPhoto (a document side's photo, picked and cropped), ExpiryDateField (end of validity on shadcn DatePicker, days after today only), SearchTextField and SearchResults (a search field with its spinner in the field, previous results dimmed and out of reach while loading: use them for any search), SectionLabel, SwipeButton, TaxiMeter
colors in lib/core/theme/app_colors.dart; constants in lib/core/constants/app_constants.dart
repositories AND datasources that wrap a stream use StreamTransformer.fromHandlers (or Stream.fromFuture(...).asyncExpand), never an async* generator: cancelling it only takes effect at its next event, which may never come; broke twice, 2026-11-14 (passenger frozen on "arrive dans 0 min"; the driver's background stream reopened onto the plugin's cached stream, so no foreground service)
stream_transform gives switchMap, combineLatest, throttle, whereType
formatters: formatDateWithYear ("11 nov. 2026") in core/utils/time_formatter.dart; formatPhone ("+33700000007" → "+33 7 00 00 00 07", other numbers unchanged) in core/utils/phone_formatter.dart
location: DeviceLocationDataSourceImpl asks the permission once at a time for the whole app, gives up a position after 15 s (TimeoutException → "Position introuvable"), LocationSettingsFailure after a permanent refusal
