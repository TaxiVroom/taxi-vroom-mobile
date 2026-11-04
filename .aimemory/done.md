#L YYYY-MM-DD|topic|paths|outcome
2026-11-04|advance-bookings|taxi-vroom-api/docs/specs/reservations-a-l-avance.md,lib/features/passenger_home,lib/features/driver_home,lib/core|shipped, uncommitted: real bookings both sides, refuse, loaders, pushes with rideId open the ride (WatchPushedRidesUseCase, PassengerFlowStarting loader), "Course annulée" state, maps camera fix, booking label on offers, "Je pars" in Acceptées; tested on two Android emulators; 89 tests green
2026-11-02|push-notifications|taxi-vroom-api/docs/specs/notifications-push.md,lib/core,lib/features/authentication,driver_home,passenger_home|push, background position, session and ride resume shipped, tested on two Android emulators, 89 tests green, uncommitted; iOS (step 7) remains
2026-11-02|rating-and-history|taxi-vroom-api/docs/specs/notation-et-historique.md,lib/features/passenger_home,lib/features/driver_home|rating, past rides, driver stats and pickup address real; end screen fixed for supplements (plugin bug); 85 tests green; two-emulator test validated by the user
2026-11-02|memory-fill|.aimemory|whole code read and recorded: arch, hyp and 4 new ltm nodes (passengerApp, driverApp, authRegistration, coreShared); code untouched
2026-11-02|ai-memory|.aimemory,.claude/skills/build-memory,CLAUDE.md,.github/cspell.json|memory system set up and versioned, same format in the API repo; INDEX and prefs imported in CLAUDE.md; domain gotchas and known issues moved to arch
2026-10-22|nearby-taxis-follow|watch_nearby_taxis_usecase|search moves after 500 m, commit f02fedb, 82 tests green
2026-10-22|price-estimate|lib/features/passenger_home,price_formatter|real estimate shipped, commits b20f833 8ccdddd, ride order tested on two emulators

#S older summaries
