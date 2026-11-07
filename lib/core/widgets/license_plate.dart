import 'package:mobile/core/theme/app_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// French plate, shown big so the passenger spots the right taxi, and in the
/// driver's account. Without the département of the right band: the owner
/// chooses it, nothing links it to the plate.
class LicensePlate extends StatelessWidget {
  const LicensePlate({required this.plate, super.key});

  // E.g. "AB-123-CD".
  final String plate;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBand(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              plate,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // The blue band of the left, with the country.
  Widget _buildBand() {
    return Container(
      width: 22,
      color: AppColors.plateBlue,
      alignment: Alignment.center,
      child: const Text(
        'F',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
