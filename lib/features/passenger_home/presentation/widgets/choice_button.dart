import 'package:shadcn_flutter/shadcn_flutter.dart';

/// One option in a group of choices: filled when selected, outlined otherwise.
class ChoiceButton extends StatelessWidget {
  const ChoiceButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return isSelected
        ? PrimaryButton(
            onPressed: onPressed,
            alignment: Alignment.center,
            child: Text(label),
          )
        : OutlineButton(
            onPressed: onPressed,
            alignment: Alignment.center,
            child: Text(label),
          );
  }
}
