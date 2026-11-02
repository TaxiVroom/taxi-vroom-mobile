# aimemory
arch: confirmed hot modules/build
hyp: working hypotheses + concepts (revisable)
done: recent outcomes
prefs: feature workflow
ltm: durable cold graph, see ltm/CATALOG.md (do not bulk-load)
entry: lib/main_<flavor>.dart → lib/app/view/app.dart (all wiring) → navigators → pages → blocs → use cases → repositories → datasources
product: Uber-like app for French licensed taxis, the backend is the authority @ltm:product
priceEstimate: price comes from POST /v1/rides, ordering only sends the ride id; details in the API repo memory
next: real rating and ride history, then push notifications, then advance bookings
