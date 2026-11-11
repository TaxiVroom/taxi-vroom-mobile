import 'package:mobile/core/theme/app_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Short info floating over the map, e.g. "Arrivée vers 15:01". While its
/// value loads, a small spinner follows the text.
class MapPill extends StatelessWidget {
  const MapPill({required this.text, this.isLoading = false, super.key});

  final String text;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (isLoading) ...[
            const SizedBox(width: 8),
            const CircularProgressIndicator(size: 14, strokeWidth: 2),
          ],
        ],
      ),
    );
  }
}
