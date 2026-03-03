import 'package:shadcn_flutter/shadcn_flutter.dart';

class AuthProviderButton extends StatelessWidget {
  const AuthProviderButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlineButton(
        onPressed: loading ? null : onPressed,
        alignment: Alignment.center,
        leading: icon,
        trailing: loading
            ? const AspectRatio(
                aspectRatio: 1,
                child: CircularProgressIndicator(
                  color: Color(0xFF0066FF),
                ),
              )
            : null,
        child: Text(label),
      ),
    );
  }
}
