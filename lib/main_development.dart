import 'package:mobile/app/app.dart';
import 'package:mobile/bootstrap.dart';
import 'package:mobile/env/env_dev.dart';
import 'package:mobile/firebase_options_development.dart';

Future<void> main() async {
  final config = EnvDev();

  await bootstrap(
    () => App(config: config),
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}
