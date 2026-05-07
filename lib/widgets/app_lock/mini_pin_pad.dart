import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/utils/security_store.dart';
import 'package:swallet/utils/size_config.dart';
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
  static const double _keySize = 74;
  static const double _rowGap = 16;
  static const double _columnGap = 20;

  String _enteredPin = '';
  bool _isError = false;

  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeController.addStatusListener((status) {
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
    final contentWidth = (w(_keySize) * 3) + (w(_columnGap) * 2);

    return Padding(
      padding: EdgeInsets.fromLTRB(w(16), 0, w(16), w(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.surface,
                borderRadius: BorderRadius.circular(r(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: widget.isDark ? 0.28 : 0.08,
                    ),
                    blurRadius: w(24),
                    offset: Offset(0, w(14)),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  w(16),
                  w(24),
                  w(16),
                  w(16),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: contentWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Enter App PIN',
                          textAlign: TextAlign.center,
                          style: SwalletText.title.copyWith(
                            color: tokens.onSurface,
                            fontSize: sp(16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: w(24)),
                        _buildDots(tokens),
                        SizedBox(height: w(10)),
                        SizedBox(
                          height: w(18),
                          child: AnimatedOpacity(
                            opacity: _isError ? 1 : 0,
                            duration: const Duration(milliseconds: 160),
                            child: Text(
                              'Wrong PIN',
                              textAlign: TextAlign.center,
                              style: SwalletText.caption.copyWith(
                                color: SwalletColors.destructive,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: w(12)),
                        _buildNumPad(tokens),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots(AddCardMaterialTokens tokens) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final filled = index < _enteredPin.length;
        final activeColor =
            _isError ? SwalletColors.destructive : tokens.primary;
        final borderColor = _isError
            ? SwalletColors.destructive.withValues(alpha: filled ? 1 : 0.34)
            : (filled
                ? tokens.primary
                : tokens.primary
                    .withValues(alpha: widget.isDark ? 0.32 : 0.24));
        final fillColor = filled
            ? activeColor.withValues(alpha: widget.isDark ? 0.20 : 0.16)
            : tokens.primary.withValues(alpha: widget.isDark ? 0.12 : 0.10);

        return TweenAnimationBuilder<double>(
          key: ValueKey<int>(_isError ? index + 10 : index),
          tween: Tween<double>(begin: 0, end: _isError ? 1 : 0),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            final shake = _isError
                ? math.sin(value * math.pi * 8) * (6 * (1 - value))
                : 0.0;
            return Transform.translate(offset: Offset(shake, 0), child: child);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(
              right: index == _pinLength - 1 ? 0 : w(8),
            ),
            width: w(18),
            height: w(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fillColor,
              border: Border.all(
                color: borderColor,
                width: filled ? w(1.5) : w(1.1),
              ),
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.18),
                        blurRadius: w(8),
                        spreadRadius: w(1.2),
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Container(
                width: filled ? w(7) : w(6),
                height: filled ? w(7) : w(6),
                decoration: BoxDecoration(
                  color: filled ? activeColor : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumPad(AddCardMaterialTokens tokens) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['1', '2', '3'], tokens),
        SizedBox(height: w(_rowGap)),
        _buildRow(['4', '5', '6'], tokens),
        SizedBox(height: w(_rowGap)),
        _buildRow(['7', '8', '9'], tokens),
        SizedBox(height: w(_rowGap)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: w(_keySize), height: w(_keySize)),
            SizedBox(width: w(_columnGap)),
            _buildNumButton('0', tokens),
            SizedBox(width: w(_columnGap)),
            _buildBackspaceButton(tokens),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> numbers, AddCardMaterialTokens tokens) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: numbers
          .map(
            (n) => Padding(
              padding: EdgeInsets.only(
                right: n == numbers.last ? 0 : w(_columnGap),
              ),
              child: _buildNumButton(n, tokens),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildNumButton(String number, AddCardMaterialTokens tokens) {
    return _buildKeySurface(
      tokens,
      onTap: () => _onNumTapped(number),
      child: Text(
        number,
        style: SwalletText.title.copyWith(
          fontSize: sp(18),
          fontWeight: FontWeight.w500,
          height: 1,
          color: tokens.onSurface,
        ),
      ),
    );
  }

  Widget _buildKeySurface(
    AddCardMaterialTokens tokens, {
    required Widget child,
    required VoidCallback onTap,
    bool lowEmphasis = false,
  }) {
    return SizedBox(
      width: w(_keySize),
      height: w(_keySize),
      child: Material(
        color: lowEmphasis ? Colors.transparent : tokens.surfaceContainerHigh,
        shape: lowEmphasis ? null : const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTapDown: (_) => HapticFeedback.selectionClick(),
          onTap: onTap,
          customBorder: lowEmphasis ? null : const CircleBorder(),
          borderRadius: lowEmphasis ? BorderRadius.circular(r(12)) : null,
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(AddCardMaterialTokens tokens) {
    return _buildKeySurface(
      tokens,
      onTap: _onBackspace,
      lowEmphasis: true,
      child: Text(
        'Delete',
        style: SwalletText.body.copyWith(
          color: tokens.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
