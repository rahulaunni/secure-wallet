import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swallet/utils/security_store.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

class MiniPinPad extends StatefulWidget {
  final bool isDark;
  final VoidCallback onSuccess;

  const MiniPinPad({
    super.key,
    required this.isDark,
    required this.onSuccess,
  });

  @override
  State<MiniPinPad> createState() => _MiniPinPadState();
}

class _MiniPinPadState extends State<MiniPinPad>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 4;

  String _enteredPin = '';
  bool _isError = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 24)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reset();
          setState(() {
            _enteredPin = '';
            Timer(const Duration(milliseconds: 200), () {
              if (mounted) setState(() => _isError = false);
            });
          });
        }
      });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onNumTapped(String number) {
    if (_isError) {
      setState(() => _isError = false);
    }

    if (_enteredPin.length < _pinLength) {
      setState(() => _enteredPin += number);
      HapticFeedback.lightImpact();

      if (_enteredPin.length == _pinLength) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _verifyPin() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final savedPin = await SecurityStore.readPin();

    if (_enteredPin == savedPin) {
      HapticFeedback.mediumImpact();
      widget.onSuccess();
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() => _isError = true);
    _shakeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(widget.isDark);

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: tokens.containerRadius,
          border: Border.all(
            color: tokens.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter App PIN',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: tokens.onSurface,
              ),
            ),
            const SizedBox(height: 22),
            _buildDots(tokens),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildNumPad(tokens),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDots(AddCardMaterialTokens tokens) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final filled = index < _enteredPin.length;
        final color = _isError
            ? Colors.redAccent
            : (filled ? tokens.primary : tokens.outlineVariant);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 9),
          width: filled ? 12 : 10,
          height: filled ? 12 : 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : Colors.transparent,
            border: Border.all(color: color, width: 1.5),
          ),
        );
      }),
    );
  }

  Widget _buildNumPad(AddCardMaterialTokens tokens) {
    return Column(
      children: [
        _buildRow(['1', '2', '3'], tokens),
        const SizedBox(height: 14),
        _buildRow(['4', '5', '6'], tokens),
        const SizedBox(height: 14),
        _buildRow(['7', '8', '9'], tokens),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 68, height: 68),
            _buildNumButton('0', tokens),
            _buildBackspaceButton(tokens),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> numbers, AddCardMaterialTokens tokens) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: numbers.map((n) => _buildNumButton(n, tokens)).toList(),
    );
  }

  Widget _buildNumButton(String number, AddCardMaterialTokens tokens) {
    return Material(
      color: tokens.surfaceContainerHigh,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTapDown: (_) => HapticFeedback.selectionClick(),
        onTap: () => _onNumTapped(number),
        child: SizedBox(
          width: 68,
          height: 68,
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.roboto(
                fontSize: 26,
                fontWeight: FontWeight.w400,
                color: tokens.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(AddCardMaterialTokens tokens) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTapDown: (_) => HapticFeedback.selectionClick(),
        onTap: _onBackspace,
        child: SizedBox(
          width: 68,
          height: 68,
          child: Icon(
            CupertinoIcons.delete_left,
            color: tokens.onSurfaceVariant,
            size: 26,
          ),
        ),
      ),
    );
  }
}
