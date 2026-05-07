import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyWalletView extends StatefulWidget {
  final bool isDark;

  const EmptyWalletView({
    super.key,
    required this.isDark,
  });

  @override
  State<EmptyWalletView> createState() => _EmptyWalletViewState();
}

class _EmptyWalletViewState extends State<EmptyWalletView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 🌊 Floating Animation (Breathing effect)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isDark ? Colors.white : Colors.black;
    final subColor = widget.isDark ? Colors.grey[500] : Colors.grey[600];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✨ Animated Icon
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -10 * _animation.value), // Floats up/down
                child: child,
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.credit_card_off_outlined,
                size: 32,
                color: color.withValues(alpha: 0.5),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 📝 Title
          Text(
            "No Cards Yet",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.9),
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 📝 Subtitle
          Text(
            "Add your first card to get started",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: subColor,
            ),
          ),

          // Space for the FAB at the bottom
          const SizedBox(height: 100), 
        ],
      ),
    );
  }
}