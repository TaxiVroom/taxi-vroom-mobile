import 'package:mobile/core/theme/app_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// French plate, shown big so the passenger spots the right taxi, and in the
/// driver's account.
class LicensePlate extends StatelessWidget {
  const LicensePlate({
    required this.plate,
    required this.department,
    super.key,
  });

  // E.g. "GH-482-KZ".
  final String plate;

  // E.g. "67", on the right band.
  final String department;

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
          _buildBand('F'),
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
          _buildBand(department),
        ],
      ),
    );
  }

  Widget _buildBand(String text) {
    return Container(
      width: 22,
      color: AppColors.plateBlue,
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
