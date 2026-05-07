import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swallet/data/bank_assets.dart';
import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/utils/size_config.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

import 'bank_selection_container.dart';

// ✅ CORRECTED IMPORT: Points to widgets/add_card/sections/bank_select_grid.dart
import '../../../../widgets/add_card/sections/bank_select_grid.dart';

class BankSelectionSection extends StatefulWidget {
  final ValueChanged<String> onBankSelected;

  // 1. Accept optional controller
  final ScrollController? controller;

  const BankSelectionSection({
    super.key,
    required this.onBankSelected,
    this.controller,
  });

  @override
  State<BankSelectionSection> createState() => _BankSelectionSectionState();
}

class _BankSelectionSectionState extends State<BankSelectionSection> {
  final TextEditingController _bankSearchController = TextEditingController();

  String _selectedCountryId = BankAssets.supportedCountries.first.id;
  String _bankSearchQuery = '';

  @override
  void dispose() {
    _bankSearchController.dispose();
    super.dispose();
  }

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final tokens = AddCardMaterialTokens(isDark);
    final countryMenuMaxHeight = MediaQuery.of(context).size.height * 0.40;

    return BankSelectionContainer(
      child: Column(
        children: [
          const SizedBox(height: 8),

          // ================= DRAG HANDLE =================
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? tokens.outlineVariant.withValues(alpha: 0.72)
                  : tokens.outlineVariant.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 12),

          // ================= TITLE =================
          Center(
            child: Text(
              'Choose a bank',
              textAlign: TextAlign.center,
              style: SwalletText.bodyMedium.copyWith(
                color: tokens.onSurface,
              ),
            ),
          ),

          const SizedBox(height: 14),

          _CountrySelector(
            value: _selectedCountryId,
            countries: BankAssets.supportedCountries,
            isDark: isDark,
            maxMenuHeight: countryMenuMaxHeight,
            onChanged: (countryId) {
              setState(() {
                _selectedCountryId = countryId;
                _bankSearchQuery = '';
                _bankSearchController.clear();
              });
              if (widget.controller?.hasClients ?? false) {
                widget.controller?.jumpTo(0);
              }
            },
          ),

          const SizedBox(height: 12),

          _BankSearchField(
            controller: _bankSearchController,
            isDark: isDark,
            onChanged: (value) {
              setState(() => _bankSearchQuery = value);
              if (widget.controller?.hasClients ?? false) {
                widget.controller?.jumpTo(0);
              }
            },
          ),

          const SizedBox(height: 12),

          // ================= BANK LIST =================
          Expanded(
            child: BankSelectGrid(
              // 2. Pass the controller down
              controller: widget.controller ?? ScrollController(),
              banks: BankAssets.banksForCountry(_selectedCountryId),
              searchQuery: _bankSearchQuery,
              onBankSelected: widget.onBankSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class _BankSearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _BankSearchField({
    required this.controller,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(isDark);

    return SizedBox(
      height: w(56),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: tokens.primary,
        style: SwalletText.bodyMedium.copyWith(
          color: tokens.onSurface,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: tokens.surfaceContainer,
          prefixIcon: Icon(
            CupertinoIcons.search,
            color: tokens.onSurfaceVariant,
            size: w(24),
          ),
          hintText: 'Search bank',
          hintStyle: SwalletText.body.copyWith(
            color: tokens.onSurfaceVariant,
            fontSize: sp(14),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: w(16)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r(16)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r(16)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r(16)),
            borderSide: BorderSide(color: tokens.primary, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _CountrySelector extends StatefulWidget {
  final String value;
  final List<BankCountry> countries;
  final bool isDark;
  final double maxMenuHeight;
  final ValueChanged<String> onChanged;

  const _CountrySelector({
    required this.value,
    required this.countries,
    required this.isDark,
    required this.maxMenuHeight,
    required this.onChanged,
  });

  @override
  State<_CountrySelector> createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<_CountrySelector>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  BankCountry get _selectedCountry {
    return widget.countries.firstWhere(
      (country) => country.id == widget.value,
      orElse: () => widget.countries.first,
    );
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
  }

  void _select(BankCountry country) {
    widget.onChanged(country.id);
    setState(() => _isExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(widget.isDark);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: tokens.surfaceContainer,
        borderRadius: BorderRadius.circular(r(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: w(56),
              child: Row(
                children: [
                  SizedBox(width: w(16)),
                  _CountryFlag(country: _selectedCountry),
                  SizedBox(width: w(10)),
                  Expanded(
                    child: Text(
                      _selectedCountry.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SwalletText.bodyMedium.copyWith(
                        color: tokens.onSurface,
                        fontSize: sp(14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 260),
                    child: Icon(
                      CupertinoIcons.chevron_down,
                      color: _isExpanded
                          ? tokens.primary
                          : tokens.onSurfaceVariant,
                      size: w(24),
                    ),
                  ),
                  SizedBox(width: w(12)),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: _isExpanded ? null : 0,
              child: _isExpanded
                  ? ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: widget.maxMenuHeight,
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: w(8)),
                        child: Column(
                          children: [
                            Divider(
                              height: w(1),
                              thickness: w(1),
                              color:
                                  tokens.outlineVariant.withValues(alpha: 0.64),
                            ),
                            ...widget.countries.map((country) {
                              final isSelected = country.id == widget.value;

                              return InkWell(
                                onTap: () => _select(country),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: w(16),
                                    vertical: w(12),
                                  ),
                                  color: isSelected
                                      ? tokens.primary.withValues(alpha: 0.10)
                                      : Colors.transparent,
                                  child: Row(
                                    children: [
                                      _CountryFlag(country: country),
                                      SizedBox(width: w(10)),
                                      Expanded(
                                        child: Text(
                                          country.label,
                                          style: SwalletText.body.copyWith(
                                            color: isSelected
                                                ? tokens.primary
                                                : tokens.onSurface,
                                            fontSize: sp(12),
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          CupertinoIcons.check_mark,
                                          size: w(16),
                                          color: tokens.primary,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryFlag extends StatelessWidget {
  final BankCountry country;

  const _CountryFlag({
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SvgPicture.asset(
        country.flagAsset,
        width: w(24),
        height: w(16),
        fit: BoxFit.cover,
      ),
    );
  }
}
