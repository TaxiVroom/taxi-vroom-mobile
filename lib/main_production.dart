import 'package:mobile/app/app.dart';
import 'package:mobile/bootstrap.dart';
import 'package:mobile/env/env_prod.dart';
import 'package:mobile/firebase_options_production.dart';

Future<void> main() async {
  final config = EnvProd();

  await bootstrap(
    () => App(config: config),
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}
