import 'package:flutter/material.dart';

class DeletingListItemWrapper extends StatelessWidget {
  final bool isDeleting;
  final Widget child;

  const DeletingListItemWrapper({
    super.key,
    required this.isDeleting,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      // 1. Slow down the shrink (500ms)
      duration: const Duration(milliseconds: 700),
      // 2. Use a standard smooth curve to prevent "bouncing" flickering
      curve: Curves.easeInOut, 
      alignment: Alignment.topCenter,
      
      child: AnimatedOpacity(
        // 3. Fade out slightly faster than the shrink so it's gone before it collapses
        opacity: isDeleting ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        
        // Ensure width is maintained while height shrinks to prevent layout shifts
        child: isDeleting
            ? const SizedBox(width: double.infinity, height: 0) 
            : child,
      ),
    );
  }
}