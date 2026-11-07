# aimemory
arch: confirmed hot modules/build
hyp: working hypotheses + concepts (revisable)
done: recent outcomes
prefs: feature workflow
ltm: durable cold graph, see ltm/CATALOG.md (do not bulk-load)
specs: decisions of a feature live in taxi-vroom-api/docs/specs/<nom>.md, read the one matching the task
entry: lib/main_<flavor>.dart → lib/app/view/app.dart (all wiring) → navigators → pages → blocs → use cases → repositories → datasources
product: Ride-hailing app for French licensed taxis, the backend is the authority @ltm:product
priceEstimate: price comes from POST /v1/rides, ordering only sends the ride id; details in the API repo memory
passenger: home, search, taxi choice, order, live tracking and receipt are real @ltm:passengerApp
driver: online, offers, pickup, boarding code, ride and completion are real @ltm:driverApp
fakes: list on the stillFake line of arch; app.dart comments say how to switch
reuse: check @ltm:coreShared before writing a widget, a formatter or a stream
push: shipped on Android, iOS waits for hardware, spec docs/specs/notifications-push.md in the API repo
bookings: advance bookings shipped, spec taxi-vroom-api/docs/specs/reservations-a-l-avance.md
pickupPlace: the passenger chooses and confirms the pickup, shipped, spec taxi-vroom-api/docs/specs/point-de-prise-en-charge.md
navigation: "Itinéraire" opens Google Maps or Waze, shipped, spec taxi-vroom-api/docs/specs/navigation-externe.md
next: to choose with the user; ideas noted for later in taxi-vroom-api/docs/a-faire.md
