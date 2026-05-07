import 'package:flutter/material.dart';

import '../../constants/layout_constants.dart';
import 'sections/bank_select_grid.dart';
import 'add_card_theme.dart';

class AddCardSheet extends StatelessWidget {
  final double previewTop;
  final DraggableScrollableController controller;
  final ValueChanged<String> onBankSelected;
  final VoidCallback onDismiss;

  const AddCardSheet({
    super.key,
    required this.previewTop,
    required this.controller,
    required this.onBankSelected,
    required this.onDismiss,
  });

  static const double _minExtent = 0.32;
  static const double _initialExtent = 0.64;

  @override
  Widget build(BuildContext context) {
    final double sheetTopPadding =
        previewTop + previewCardHeight + 24;

    return Padding(
      padding: EdgeInsets.only(top: sheetTopPadding),
      child: DraggableScrollableSheet(
        controller: controller,
        initialChildSize: _initialExtent,
        minChildSize: _minExtent,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AddCardTheme.sectionBackground(context),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // ================= DRAG HANDLE =================
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AddCardTheme.handleColor(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 16),

                // ================= TITLE =================
                Text(
                  'Select Bank',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        AddCardTheme.selectBankTitle(context),
                  ),
                ),

                const SizedBox(height: 16),

                // ================= GRID =================
                Expanded(
                  child: BankSelectGrid(
                    controller: scrollController,
                    onBankSelected: onBankSelected,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
