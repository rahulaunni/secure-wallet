import 'package:flutter/material.dart';

import '../../models/card_data.dart';
import '../../theme/swallet_theme.dart';
import '../../utils/size_config.dart';
import 'delete_card_preview.dart';

class DeleteCardSheet extends StatelessWidget {
  final CardData card;
  final bool isDark;
  final VoidCallback onDeleteConfirmed;

  const DeleteCardSheet({
    super.key,
    required this.card,
    required this.isDark,
    required this.onDeleteConfirmed,
  });

  static const double sideInset = 16;
  static const double bottomInset = 16;
  static const double cornerRadius = 32;
  static const double buttonHeight = 48;
  static const double buttonRadius = 16;

  @override
  Widget build(BuildContext context) {
    final palette = SwalletPalette(isDark);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        w(sideInset),
        0,
        w(sideInset),
        w(bottomInset),
      ),
      child: Material(
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r(cornerRadius)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.fromLTRB(w(16), w(32), w(16), w(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_rounded,
                size: w(40),
                color: SwalletColors.destructive,
              ),
              SizedBox(height: w(16)),
              Text(
                'Delete this card?',
                style: SwalletText.title.copyWith(color: palette.text),
              ),
              SizedBox(height: w(10)),
              Text(
                'This action is permanent and cannot be undone.',
                textAlign: TextAlign.center,
                style: SwalletText.bodyMedium.copyWith(
                  color: palette.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: w(40)),
              DeleteCardPreview(
                card: card,
                isDark: isDark,
              ),
              SizedBox(height: w(44)),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: w(buttonHeight),
                      child: Material(
                        color: palette.surfaceHigh,
                        borderRadius: BorderRadius.circular(r(buttonRadius)),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: SwalletText.button.copyWith(
                                fontWeight: FontWeight.w500,
                                color: palette.text,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: w(8)),
                  Expanded(
                    child: SizedBox(
                      height: w(buttonHeight),
                      child: Material(
                        color: SwalletColors.destructive,
                        borderRadius: BorderRadius.circular(r(buttonRadius)),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            onDeleteConfirmed();
                          },
                          child: Center(
                            child: Text(
                              'Delete card',
                              style: SwalletText.button.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
