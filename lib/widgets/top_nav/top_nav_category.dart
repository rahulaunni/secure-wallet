import 'package:flutter/material.dart';

class TopNavCategory {
  final String id;
  final String label;
  final String iconPath;
  final Color iconColor;

  const TopNavCategory({
    required this.id,
    required this.label,
    required this.iconPath,
    required this.iconColor,
  });

  // ================= BASE CATEGORIES =================

  factory TopNavCategory.credit() {
    return const TopNavCategory(
      id: 'credit',
      label: 'Credit Card',
      iconPath: 'assets/icons/credit_card.svg',
      iconColor: Color(0xFF2979FF),
    );
  }

  factory TopNavCategory.debit() {
    return const TopNavCategory(
      id: 'debit',
      label: 'Debit Card',
      iconPath: 'assets/icons/debit_card.svg',
      iconColor: Color(0xFFAB47BC),
    );
  }

  // ================= PERSON CATEGORY =================

  factory TopNavCategory.person({
    required String id,
    required String label,
  }) {
    return TopNavCategory(
      id: id,
      label: label,
      iconPath: 'assets/icons/person.svg',
      iconColor: _personColorFor(id),
    );
  }

  // ================= COLOR PALETTE =================

  static Color _personColorFor(String seed) {
    const palette = [
      Color(0xFF42A5F5),
      Color(0xFF66BB6A),
      Color(0xFFEC407A),
      Color(0xFFAB47BC),
      Color(0xFFFF7043),
      Color(0xFF26A69A),
      Color(0xFF7E57C2),
    ];

    final index =
        seed.codeUnits.fold(0, (a, b) => a + b) % palette.length;
    return palette[index];
  }
}
