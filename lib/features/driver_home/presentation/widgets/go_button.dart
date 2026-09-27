import 'package:mobile/core/theme/app_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// The big button of the driver's main action, easy to hit with the phone on
/// its holder: green to start ("Passer en ligne", "Accepter la course"...),
/// or in the primary color for the other steps ("Je suis arrivé"...).
class GoButton extends StatelessWidget {
  const GoButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    super.key,
  }) : _color = AppColors.freeTaxi;

  const GoButton.primary({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    super.key,
  }) : _color = null;

  final String label;

  // Null disables the button.
  final VoidCallback? onPressed;

  final IconData? icon;
  final bool isLoading;

  // Null keeps the theme's primary color.
  final Color? _color;

  @override
  Widget build(BuildContext context) {
    const style = ButtonStyle.primary(size: ButtonSize.large);
    final color = _color;
    return SizedBox(
      height: 60,
      child: Button(
        style: color == null ? style : style.withBackgroundColor(color: color),
        onPressed: isLoading ? null : onPressed,
        alignment: Alignment.center,
        leading: isLoading
            ? const AspectRatio(
                aspectRatio: 1,
                child: CircularProgressIndicator(onSurface: true),
              )
            : (icon == null ? null : Icon(icon)),
        // A fixed size: the large button style would scale the text past
        // the button's height.
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
