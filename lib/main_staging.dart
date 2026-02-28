import 'package:mobile/app/app.dart';
import 'package:mobile/bootstrap.dart';
import 'package:mobile/env/env_stg.dart';
import 'package:mobile/firebase_options_production.dart';

// TODO(firebase): Replace with firebase_options_staging.dart once the staging Firebase app is created.
Future<void> main() async {
  final config = EnvStg();

  await bootstrap(
    () => App(config: config),
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}
