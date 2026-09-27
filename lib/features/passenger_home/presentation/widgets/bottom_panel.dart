import 'package:shadcn_flutter/shadcn_flutter.dart';

/// White panel docked at the bottom of a full-screen map.
class BottomPanel extends StatelessWidget {
  const BottomPanel({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Color(0x24000000), blurRadius: 24),
        ],
      ),
      child: child,
    );
  }
}
