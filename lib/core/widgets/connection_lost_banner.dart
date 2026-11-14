import 'package:mobile/core/theme/app_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// "⚠ Connexion perdue." (or the [title] given) followed by what it means for
/// the user. Firebase reconnects by itself, so the banner goes away on its
/// own.
class ConnectionLostBanner extends StatelessWidget {
  const ConnectionLostBanner({
    required this.title,
    required this.consequence,
    super.key,
  });

  // E.g. "Connexion perdue." or "Votre chauffeur a perdu la connexion."
  final String title;

  // E.g. "Les informations affichées ne sont peut-être plus à jour."
  final String consequence;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$title ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: '$consequence Reconnexion automatique…'),
                ],
              ),
              style: const TextStyle(fontSize: 13, color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
