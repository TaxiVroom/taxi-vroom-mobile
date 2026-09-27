import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/passenger_home/domain/entities/vehicle.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// French plate, shown big so the passenger spots the right taxi.
class LicensePlate extends StatelessWidget {
  const LicensePlate({required this.vehicle, super.key});

  final Vehicle vehicle;

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
              vehicle.plate,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          _buildBand(vehicle.department),
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
