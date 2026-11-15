# aimemory
arch: confirmed hot modules/build
hyp: working hypotheses + concepts (revisable)
done: recent outcomes
prefs: feature workflow
ltm: durable cold graph, see ltm/CATALOG.md (do not bulk-load)
lifecycleStart: HARD, at the start of non-trivial work (planning, and again when executing an accepted plan): 1) load the other hot shards arch.md, hyp.md, done.md; 2) scan ltm/CATALOG.md for the task's tags and paths, then fetch the matching ltm/n/<id>.md and the relevant ltm/edges.md lines only, never bulk-load ltm/n/; 3) code wins over memory: on a conflict trust the code and correct the memory at the end
lifecycleEnd: HARD, before declaring a plan or feature done: arch = confirmed structure learned on the way; hyp = confirm or falsify the working models; done = one #L line per meaningful change; prefs = if the user stated or corrected a build preference, update prefs.md; ltm = promote only cold durable facts, never open hypotheses or prefs. Skip both steps for a trivial one-file edit with no architectural learning
lifecycleSpec: HARD, every decision or correction of the user about a feature goes into its spec right away, unasked (prefs specSync)
lifecycleSecrets: HARD, never store a secret in .aimemory; formats are in .claude/skills/build-memory/SKILL.md
lifecycleLoad: INDEX.md and prefs.md are loaded at the start of every session by the two @imports of CLAUDE.md, which holds nothing else since 2026-11-13 (the user's choice): never delete that file, or nothing loads this memory; never put a rule in it, rules go in .aimemory
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
pickupPlace: the passenger chooses and confirms the pickup, shipped; "Position actuelle" is read again on each tap leaving the home to order (since 2026-11-15, validated by the user), spec taxi-vroom-api/docs/specs/point-de-prise-en-charge.md
navigation: "Itinéraire" opens Google Maps or Waze, shipped, spec taxi-vroom-api/docs/specs/navigation-externe.md
documents: "Vos documents" real, opens on arrival when a document needs action, spec taxi-vroom-api/docs/specs/documents-du-chauffeur.md
account: both "Compte" tabs real, one API call with a loader on each arrival, spec taxi-vroom-api/docs/specs/compte-a-jour.md
contact: "Contacter le développeur" in both Compte tabs calls the number from GET /v1/enterprise-contact, spec taxi-vroom-api/docs/specs/aide-chauffeur.md
earnings: "Gains" by day, week or month and the "Conduire" pill and three cards are real, a loader on every API call, spec taxi-vroom-api/docs/specs/gains-reels.md (screen: gains-du-chauffeur.md)
homeWork: "Maison" and "Travail" shortcuts and "Compte" rows real, "Gare" removed, spec taxi-vroom-api/docs/specs/maison-et-travail.md
recentDestinations: real, in "Votre trajet" only (3 last), spec taxi-vroom-api/docs/specs/destinations-recentes.md
pickupTime: chosen on the taxi choice only, reset when back to the home, spec taxi-vroom-api/docs/specs/heure-de-prise-en-charge.md
passengerCount: the passenger chooses 1 to 8 on the taxi choice, the driver gives the seats at registration, the end of ride has a "5e passager et plus" line, coded not tested, spec taxi-vroom-api/docs/specs/nombre-de-passagers.md
ridesByPages: "Mes courses" loads 20 cards at a time, infinite scroll with a loader under the last card, coded not tested, spec taxi-vroom-api/docs/specs/mes-courses-par-pages.md
driverBookingsByPages: the driver's "Réservations" the same way, one fetch per tap on "Disponibles" or "Acceptées", coded not tested, spec taxi-vroom-api/docs/specs/reservations-chauffeur-par-pages.md
next: to choose with the user; ideas noted for later in taxi-vroom-api/docs/a-faire.md
