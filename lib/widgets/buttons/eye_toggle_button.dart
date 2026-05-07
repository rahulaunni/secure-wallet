import 'package:flutter/material.dart';

class EyeToggleButton extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onTap;

  const EyeToggleButton({
    super.key,
    required this.isVisible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black26,
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              isVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              key: ValueKey(isVisible),
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
