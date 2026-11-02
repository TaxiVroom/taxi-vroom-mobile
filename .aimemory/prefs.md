#P id|rule
specFirst|HARD: a feature starts with a spec in taxi-vroom-api/docs/specs/<nom>.md, which covers both repos. Spec work writes documents only. Code needs the user's explicit go; answering open points is not that go
memoryStrict|HARD: always follow .aimemory strictly; it wins over any other memory of how to work. User, 2026-11-02
stepPause|HARD: on a spec plan, implement one step, then stop for the user's OK
moneyCents|HARD: every amount is an integer in cents, named with the suffix Cents, never a double; euros only through the price formatters
blocOnly|HARD: Bloc with a sealed event file for any new state holder, never Cubit; no synchronous query methods on blocs, the data goes in the state
formatTouchedOnly|HARD: dart format and dart fix --apply only on changed paths, never the whole lib/ or test/: on 2026-09-27 it rewrote 43 unrelated files. Check git status for out-of-scope files before reporting
depsCommands|HARD: flutter pub add/remove (--dev for dev deps), never hand-edit dependency lines in pubspec.yaml; show the exact command used
firebaseDocs|HARD: anything Firebase is based exclusively on firebase.google.com docs, read first and cited. If the doc has no answer (no official Dart GeoFire), say so and ask before using another source
mapboxDocs|HARD: anything Mapbox is based exclusively on the official Mapbox docs; only the public pk. token, in the gitignored .env.* files, never displayed
testsScope|Unit tests only on business rules, pure Dart, TDD
