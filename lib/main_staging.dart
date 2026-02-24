import 'package:mobile/app/app.dart';
import 'package:mobile/bootstrap.dart';
// TODO(firebase): Replace with firebase_options_staging.dart once the staging Firebase app is created.
import 'package:mobile/firebase_options_production.dart';

Future<void> main() async {
  await bootstrap(
    () => const App(),
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}
