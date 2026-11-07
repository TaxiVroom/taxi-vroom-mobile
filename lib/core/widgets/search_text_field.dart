import 'package:shadcn_flutter/shadcn_flutter.dart';

/// A field whose suggestions come from a search, e.g. the communes of "Votre
/// taxi" or the places of "Votre trajet": while the answer comes, a spinner
/// shows in the field, on the right, so nothing below it moves. Goes with
/// [SearchResults]. shadcn_flutter 0.0.51: TextField with
/// InputFeature.trailing.
class SearchTextField extends StatelessWidget {
  const SearchTextField({
    required this.controller,
    required this.placeholder,
    required this.isLoading,
    required this.onChanged,
    this.focusNode,
    this.style,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final String placeholder;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;
  final TextStyle? style;
  final bool autofocus;

  static const _spinnerSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      placeholder: Text(placeholder),
      style: style,
      autofocus: autofocus,
      onChanged: onChanged,
      features: [
        if (isLoading)
          const InputFeature.trailing(
            SizedBox(
              width: _spinnerSize,
              height: _spinnerSize,
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}

/// The suggestions of a [SearchTextField]. While the new answer comes, the
/// previous ones stay, dimmed and out of reach: they may not match what is
/// typed anymore, and emptying the list at each letter would make it flicker.
class SearchResults extends StatelessWidget {
  const SearchResults({
    required this.isLoading,
    required this.child,
    super.key,
  });

  final bool isLoading;
  final Widget child;

  static const _staleOpacity = 0.4;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLoading ? _staleOpacity : 1,
      child: IgnorePointer(ignoring: isLoading, child: child),
    );
  }
}
