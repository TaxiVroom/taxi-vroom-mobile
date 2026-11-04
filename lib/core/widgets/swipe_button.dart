import 'package:mobile/core/theme/app_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// An action confirmed by sliding the thumb to the end: a deliberate
/// gesture, which a tap by mistake cannot trigger.
/// shadcn has no such button, and its [Slider] is fixed at 16 pixels high:
/// built here with a drag on the thumb only.
class SwipeButton extends StatefulWidget {
  const SwipeButton({
    required this.label,
    required this.onSwiped,
    this.color = AppColors.freeTaxi,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback onSwiped;
  final Color color;
  final bool isLoading;

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton> {
  static const _height = 60.0;
  static const _thumbMargin = 4.0;
  static const double _thumbSize = _height - 2 * _thumbMargin;

  // Close enough to the end: the last pixels are hard to reach.
  static const _endShare = 0.9;

  // How far the thumb was slid, in pixels.
  double _offset = 0;
  bool _dragging = false;

  void _onDragUpdate(DragUpdateDetails details, double travel) {
    setState(() {
      _dragging = true;
      _offset = (_offset + details.delta.dx).clamp(0, travel);
    });
  }

  void _onDragEnd(double travel) {
    final swiped = _offset >= travel * _endShare;
    // Back to the start, for the next time or after a short slide.
    setState(() {
      _dragging = false;
      _offset = 0;
    });
    if (swiped) widget.onSwiped();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final travel = constraints.maxWidth - _thumbSize - 2 * _thumbMargin;
          return DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(_height / 2),
            ),
            child: Stack(
              children: [
                Center(child: _buildLabel()),
                AnimatedPositioned(
                  duration: _dragging
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  left: _thumbMargin + _offset,
                  top: _thumbMargin,
                  child: GestureDetector(
                    onHorizontalDragUpdate: widget.isLoading
                        ? null
                        : (details) => _onDragUpdate(details, travel),
                    onHorizontalDragEnd: widget.isLoading
                        ? null
                        : (_) => _onDragEnd(travel),
                    child: _buildThumb(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel() {
    if (widget.isLoading) {
      return SizedBox.square(
        dimension: 24,
        child: CircularProgressIndicator(color: widget.color),
      );
    }
    return Padding(
      // Clear of the thumb at rest.
      padding: const EdgeInsets.only(left: _thumbSize),
      child: Text(
        widget.label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: widget.color,
        ),
      ),
    );
  }

  Widget _buildThumb() {
    return Container(
      width: _thumbSize,
      height: _thumbSize,
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      child: const Icon(Icons.chevron_right, color: Colors.white, size: 32),
    );
  }
}
