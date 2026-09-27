import 'package:shadcn_flutter/shadcn_flutter.dart';

/// A colored dot and a bold label, e.g. "Hors ligne" or "En ligne".
class StatusDot extends StatelessWidget {
  const StatusDot({
    required this.label,
    required this.color,
    this.textColor,
    super.key,
  });

  final String label;
  final Color color;

  // Defaults to the surrounding text color.
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
      ],
    );
  }
}
