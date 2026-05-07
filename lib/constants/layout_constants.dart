import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ================= LIST SPACING =================
const double bankCardVerticalSpacing = 8;

// ================= CARD CONTAINER =================
const double cardAspectRatioWidth = 29;
const double cardAspectRatioHeight = 17;

const double cardPadding = 16;
const double cardBorderRadius = 32;

// ================= TOP LEFT (BANK INFO) =================
const double bankLogoHeight = 24;
const double bankLogoWidth = 58;
const double bankLogoMaxWidthRatio = 1 / 3;
const double bankDividerWidth = 2;
const double bankDividerHeight = 20;
const double bankHeaderSpacing = 8;

double bankLogoMaxWidthForCard(
  double cardWidth, {
  double padding = cardPadding,
}) {
  final innerWidth = cardWidth - (padding * 2);
  return (innerWidth * bankLogoMaxWidthRatio)
      .clamp(bankLogoHeight, 132.0)
      .toDouble();
}

// ================= TOP RIGHT (NETWORK LOGO) =================
const double networkLogoHeight = 28;

// ================= CHIP IMAGE =================
const double chipTopOffset = 44;
const double chipWidth = 42;

// ================= DETAILS POSITION =================
const double detailsBottomOffset = 4;

// ================= CARD NUMBER =================
const double cardNumberFontSize = 21;
const double cardNumberLetterSpacing = 3;
const FontWeight cardNumberFontWeight = FontWeight.w600;

// ================= VALID THRU / CVV =================
const double labelFontSize = 10;
const double valueFontSize = 14;
const double valueLetterSpacing = 1.5;
const FontWeight valueFontWeight = FontWeight.w500;

// 📉 TWEAKED: Keep label close to value
const double detailsLabelSpacing = 4;
const double detailsGroupSpacing = 16;

// ================= NAME =================
const double holderNameFontSize = 15;
const double holderNameLetterSpacing = 1.2;
const FontWeight holderNameFontWeight = FontWeight.w500;

// ================= VERTICAL SPACING =================
// 📉 TWEAKED: Reduced 12->8 to tighten the layout with smaller fonts
const double numberToRowSpacing = 8;
const double rowToNameSpacing = 8;

// ================= SECURE REVEAL (FINAL) =================

// Visible height of black reveal bar
const double secureRevealBarHeight = 48;

// Black card slide distance
const double secureRevealSlideOffset = 32;

// Bank card tilt (≈ -1.7°)
const double secureRevealBankTilt = -0.03;

// Animation duration
const Duration secureRevealAnimDuration = Duration(milliseconds: 300);

// Countdown text style
final TextStyle secureRevealTextStyle = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: Colors.white,
  letterSpacing: 0.5,
);

// ================= BLACK CARD =================

// Slightly smaller radius than bank card for depth
const double blackCardBorderRadius = 40;

// Background colors
const Color blackSecureCardBgDark = Color(0xFF0E0E0E);
const Color blackSecureCardBgLight = Color(0xFF1A1A1A);

// Text colors (contrast-safe)
const Color blackSecureCardTextDark = Colors.white;
const Color blackSecureCardTextLight = Color(0xFFEAEAEA);

// Optional: subtle divider / top edge highlight (future use)
const Color blackSecureCardHighlightDark = Color(0x26FFFFFF); // white @ 15%
const Color blackSecureCardHighlightLight = Color(0x14000000); // black @ 8%

// ================= PREVIEW CARD =================
const double previewCardHeight = 220;
