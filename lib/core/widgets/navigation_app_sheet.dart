import 'package:mobile/core/domain/entities/navigation_app.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// "Ouvrir avec": the app chosen, or null when the sheet is closed without
/// a choice. shadcn_flutter 0.0.51: openSheet, closed by closeDrawer with
/// its result.
Future<NavigationApp?> openNavigationAppSheet(BuildContext context) =>
    openSheet<NavigationApp>(
      context: context,
      position: OverlayPosition.bottom,
      builder: (_) => const _NavigationAppSheet(),
    );

class _NavigationAppSheet extends StatelessWidget {
  const _NavigationAppSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ouvrir avec',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            for (final app in NavigationApp.values) ...[
              OutlineButton(
                onPressed: () => closeDrawer<NavigationApp>(context, app),
                alignment: Alignment.center,
                child: Text(app.label),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}
