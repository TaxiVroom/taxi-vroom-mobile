import 'package:mobile/core/domain/repositories/navigation_repository.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:url_launcher/url_launcher.dart';

// url_launcher hands the link to another app (externalApplication).
// Docs: https://pub.dev/documentation/url_launcher/latest/url_launcher/launchUrl.html
//
// Every failure becomes a Result, not only a PlatformException: a missing
// native library throws an Error (seen on 2026-11-05 with an app not rebuilt
// after adding a package), and the driver must still be told.
class NavigationRepositoryImpl implements NavigationRepository {
  const NavigationRepositoryImpl();

  static const _notOpened = DeviceFailure('Impossible d’ouvrir la navigation.');

  // "Returns true if the URL was launched successfully"; otherwise false, or
  // a PlatformException.
  @override
  Future<Result<void>> open(Uri link) async {
    try {
      final opened = await launchUrl(
        link,
        mode: LaunchMode.externalApplication,
      );
      return opened ? const Result.ok(null) : const Result.error(_notOpened);
    } on Object {
      return const Result.error(_notOpened);
    }
  }
}
