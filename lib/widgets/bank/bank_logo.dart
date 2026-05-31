import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/bank_asset_resolver.dart';
import 'bank_logo_file_widget_stub.dart'
    if (dart.library.io) 'bank_logo_file_widget_io.dart'
    as bank_logo_file_widget;

class BankLogo extends StatelessWidget {
  final String bankCid;
  final double size;
  final double? width;
  final String? customLogoPath;
  final String? customLabel;
  final double? customLabelMaxWidth;

  const BankLogo({
    super.key,
    required this.bankCid,
    required this.size,
    this.width,
    this.customLogoPath,
    this.customLabel,
    this.customLabelMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final customPath = customLogoPath?.trim();
    if (customPath != null && customPath.isNotEmpty) {
      final customLogoWidget = bank_logo_file_widget.buildCustomBankLogoWidget(
        path: customPath,
        size: size,
        fallbackBuilder: (_) => _fallbackLogo(),
      );
      if (customLogoWidget != null) {
        return _logoFrame(
          customLogoWidget,
        );
      }
    }

    final logoPath = BankAssetResolver.logoPath(bankCid);

    if (logoPath != null) {
      if (logoPath.toLowerCase().endsWith('.svg')) {
        return _logoFrame(
          SvgPicture.asset(
            logoPath,
            height: size,
            fit: BoxFit.contain,
            colorFilter: null,
            errorBuilder: (_, __, ___) => _fallbackLogo(),
          ),
        );
      }

      return _logoFrame(
        Image.asset(
          logoPath,
          height: size,
          fit: BoxFit.contain,
          color: null,
          errorBuilder: (_, __, ___) => _fallbackLogo(),
        ),
      );
    }

    final label = customLabel?.trim();
    if (label != null && label.isNotEmpty) {
      final maxLabelWidth = customLabelMaxWidth ??
          width ??
          ((MediaQuery.sizeOf(context).width - 64) * 0.5)
              .clamp(size, 180.0)
              .toDouble();

      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxLabelWidth,
          minHeight: size,
          maxHeight: size,
        ),
        child: SizedBox(
          height: size,
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: 1,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: size,
                height: 1,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      );
    }

    return _fallbackLogo();
  }

  Widget _logoFrame(Widget child) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width ?? size,
        maxHeight: size,
      ),
      child: child,
    );
  }

  Widget _fallbackLogo() {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          _initialsFromLabel(customLabel),
          maxLines: 1,
          style: GoogleFonts.poppins(
            color: const Color(0xFF111827),
            fontSize: (size * 0.34).clamp(9, 14),
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  String _initialsFromLabel(String? label) {
    final cleanLabel = label?.trim();
    if (cleanLabel == null || cleanLabel.isEmpty) {
      return BankAssetResolver.initials(bankCid);
    }

    final words = cleanLabel
        .replaceAll(RegExp(r'[^A-Za-z0-9 ]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) {
      return BankAssetResolver.initials(bankCid);
    }

    if (words.length == 1) {
      final end = words.first.length >= 2 ? 2 : 1;
      return words.first.substring(0, end).toUpperCase();
    }

    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}
