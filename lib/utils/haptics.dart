import 'package:flutter/services.dart';

/// ===================================================================
/// SWALLET HAPTICS SYSTEM
/// -------------------------------------------------------------------
/// Purpose:
/// - Centralized, intentional haptics
/// - Avoid noisy or accidental vibration
/// - Make future tuning & expansion safe
///
/// RULES:
/// 1. Never call HapticFeedback directly outside this file
/// 2. Haptics should reflect INTENT, not animation
/// 3. Continuous gestures (scroll, drag, keyboard) must NEVER vibrate
///
/// This file is intentionally explicit and verbose.
/// ===================================================================

class SwalletHaptics {
  SwalletHaptics._(); // no instances

  // ===============================================================
  // 🔹 PRIMARY USER ACTIONS (CURRENTLY USED)
  // ===============================================================

  /// User selects a bank (bank grid → form transition)
  /// Intent: Strong state change
  /// Feel: Confident, deliberate
  static void bankSelected() {
    HapticFeedback.mediumImpact();
  }

  /// User taps "Change bank"
  /// Intent: Reverse / navigation-style action
  /// Feel: Light, non-committal
  static void changeBank() {
    HapticFeedback.lightImpact();
  }

  /// User successfully adds a card
  /// Intent: Commitment / completion
  /// Feel: Solid, final
  static void cardAdded() {
    HapticFeedback.heavyImpact();
  }

  /// Keyboard appears for the first time in a form session
  /// Intent: Subtle acknowledgment of input mode
  /// Feel: Minimal, almost silent
  ///
  /// NOTE:
  /// - Must be fired ONCE per keyboard open
  /// - Guard logic should live in the calling widget
  static void keyboardEntered() {
    HapticFeedback.selectionClick();
  }

  // ===============================================================
  // 🔹 SECONDARY / FUTURE ACTIONS (NOT USED YET)
  // ===============================================================

  /// User toggles secure reveal (eye icon)
  /// Intent: Privacy-sensitive action
  /// Suggested feel: light or selection
  static void secureRevealToggled() {
    // HapticFeedback.selectionClick();
  }

  /// User switches theme (light ↔ dark)
  /// Intent: Global UI mode change
  /// Suggested feel: medium
  static void themeToggled() {
    // HapticFeedback.mediumImpact();
  }

  /// User taps a filter chip
  /// Intent: Lightweight selection
  /// Suggested feel: selection
  static void filterChipSelected() {
    // HapticFeedback.selectionClick();
  }

  /// User deletes a card
  /// Intent: Destructive action
  /// Suggested feel: heavy or warning-style
  static void cardDeleted() {
    // HapticFeedback.heavyImpact();
  }

  // ===============================================================
  // 🔹 ERROR / FEEDBACK (OPTIONAL FUTURE USE)
  // ===============================================================

  /// Validation error (e.g., invalid card number)
  /// Intent: Warning
  /// Use sparingly
  static void validationError() {
    // HapticFeedback.vibrate();
  }

  /// Authentication failed (biometric / PIN)
  static void authFailed() {
    // HapticFeedback.vibrate();
  }

  // ===============================================================
  // 🔹 ACCESSIBILITY / PLATFORM NOTES
  // ===============================================================
  //
  // - Android devices vary widely in haptic strength
  // - iOS haptics are more nuanced
  // - Do NOT stack multiple haptics for one action
  // - Always prefer LESS over MORE
  //
  // ===============================================================
}
