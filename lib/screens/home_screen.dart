import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/layout_constants.dart';

import '../models/card_data.dart';
import '../models/card_type.dart';

import '../widgets/top_nav/top_nav_bar.dart';
import '../widgets/top_nav/top_nav_category.dart';
import '../widgets/home/empty_wallet_view.dart';
import '../widgets/app_lock/mini_pin_pad.dart';

import '../widgets/card/bank_card.dart';
import '../widgets/card/secure_reveal_wrapper.dart';
import '../widgets/buttons/animated_add_card_button.dart';
import '../widgets/buttons/theme_lottie_toggle.dart';
import '../widgets/buttons/settings_button.dart';

import '../widgets/delete_card/delete_card_sheet.dart';
// ✅ IMPORT THE ANIMATION WRAPPER
import '../widgets/animations/deleting_list_item_wrapper.dart';

import 'add_card_flow/add_card_flow_screen.dart';
import 'settings/settings_screen.dart';
import '../utils/device_auth.dart';

import '../data/local/card_repository.dart';
import '../data/local/hive_boxes.dart';
import '../theme/swallet_theme.dart';
import '../utils/adaptive_layout.dart';
import '../utils/card_share_helper.dart';

class HomeScreen extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final AddCardFlowController _addCardFlowController = AddCardFlowController();
  GlobalKey<NavigatorState> _sidePaneNavigatorKey = GlobalKey();

  bool _fabCollapsed = false;

  final List<CardData> _cards = [];

  // ✅ Track cards currently animating out
  final Set<String> _deletingCardIds = {};

  // 🔒 SINGLE SOURCE OF TRUTH FOR REVEAL
  String? _revealedCardId;

  // 🔒 ACTIVE TOP NAV FILTERS
  final Set<String> _activeFilters = {};

  _HomeSidePane? _sidePane;

  // ================= EXTERNAL REVEAL CANCEL =================

  bool get isPrimarySurfaceVisible => _sidePane == null;

  void cancelAllReveals() {
    if (_revealedCardId != null) {
      setState(() => _revealedCardId = null);
    }
  }

  void refreshCardsFromStorage() {
    if (!mounted) return;
    setState(() {
      _cards
        ..clear()
        ..addAll(CardRepository.getAll());
      _revealedCardId = null;
      _activeFilters.clear();
    });
  }

  bool _usesSidePane(BuildContext context) {
    return AdaptiveLayout.windowClassForWidth(
            MediaQuery.sizeOf(context).width) ==
        AdaptiveWindowClass.expanded;
  }

  void _closeSidePane() {
    if (_sidePane == null) return;
    setState(() => _sidePane = null);
  }

  void _openAddCard() {
    cancelAllReveals();
    if (_usesSidePane(context)) {
      setState(() {
        _sidePaneNavigatorKey = GlobalKey();
        _sidePane = _HomeSidePane.addCard;
      });
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => AddCardFlowScreen(
          isDark: widget.isDark,
          onCardAdded: _addCard,
        ),
      ),
    );
  }

  Future<void> _openSettings() async {
    if (_usesSidePane(context)) {
      setState(() {
        _sidePaneNavigatorKey = GlobalKey();
        _sidePane = _HomeSidePane.settings;
      });
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          isDark: widget.isDark,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );

    _refreshCardsAfterSettings();
  }

  Future<void> _addCard(CardData card) async {
    await CardRepository.add(card);
    if (!mounted) return;
    setState(() {
      _cards.add(card);
      _sidePane = null;
    });
  }

  void _refreshCardsAfterSettings() {
    refreshCardsFromStorage();
  }

  void _handleSidePaneBack() {
    final sidePane = _sidePane;
    if (sidePane == null) return;

    switch (sidePane) {
      case _HomeSidePane.addCard:
        if (_addCardFlowController.handleBack()) {
          return;
        }
        _closeSidePane();
        return;
      case _HomeSidePane.settings:
        final navigator = _sidePaneNavigatorKey.currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
          return;
        }
        _refreshCardsAfterSettings();
        _closeSidePane();
    }
  }

  // ================= TOP NAV CATEGORIES =================

  List<TopNavCategory> _buildTopNavCategories(List<CardData> cards) {
    final Map<String, TopNavCategory> map = {};

    map['credit'] = TopNavCategory.credit();
    map['debit'] = TopNavCategory.debit();

    for (final card in cards) {
      final firstName = card.holderName.split(' ').first.toLowerCase();
      map.putIfAbsent(
        firstName,
        () => TopNavCategory.person(
          id: firstName,
          label: card.holderName.split(' ').first,
        ),
      );
    }
    return map.values.toList();
  }

  // ================= FILTER LOGIC =================

  List<CardData> _filteredCards(List<CardData> cards) {
    if (_activeFilters.isEmpty) return cards;

    final bool creditActive = _activeFilters.contains('credit');
    final bool debitActive = _activeFilters.contains('debit');

    return cards.where((card) {
      bool typeMatch = true;
      if (creditActive ^ debitActive) {
        typeMatch = creditActive
            ? card.cardType == CardType.credit
            : card.cardType == CardType.debit;
      }

      final personFilters =
          _activeFilters.where((id) => id != 'credit' && id != 'debit').toSet();

      bool personMatch = true;
      if (personFilters.isNotEmpty) {
        final firstName = card.holderName.split(' ').first.toLowerCase();
        personMatch = personFilters.contains(firstName);
      }

      return typeMatch && personMatch;
    }).toList();
  }

  List<CardData> _cardsForDisplay(Box<CardData> cardsBox) {
    final storedCards = cardsBox.values.toList(growable: false);
    if (storedCards.isNotEmpty) {
      return storedCards;
    }

    // During app updates or the unlock handoff Hive can briefly notify an
    // empty snapshot. Keep the last in-memory list so saved cards do not flash
    // into the empty wallet state.
    return _cards.toList(growable: false);
  }

  // ================= LIFECYCLE =================

  @override
  void initState() {
    super.initState();
    _cards.addAll(CardRepository.getAll());

    _scrollController.addListener(() {
      final shouldCollapse = _scrollController.offset > 40;
      if (shouldCollapse != _fabCollapsed) {
        setState(() => _fabCollapsed = shouldCollapse);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ================= SECURE REVEAL LOGIC =================

  String _cardId(CardData card) {
    return '${card.bankCid}|${card.customBankName ?? ''}|'
        '${card.customBankLogoPath ?? ''}|${card.cardNumber}|'
        '${card.customGradientStartColor ?? ''}|'
        '${card.customGradientEndColor ?? ''}|${card.expiry}|'
        '${card.holderName}';
  }

  Future<void> _toggleReveal(CardData card) async {
    final cardId = _cardId(card);

    if (_revealedCardId == cardId) {
      setState(() => _revealedCardId = null);
      return;
    }

    final settingsBox = Hive.box(HiveBoxes.settings);
    final bool useBiometrics =
        settingsBox.get('use_biometrics', defaultValue: false);
    bool authenticated = false;

    if (useBiometrics) {
      authenticated = await DeviceAuth.authenticate(
        reason: 'Authenticate to reveal card details',
      );
    } else {
      final result = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: MiniPinPad(
            isDark: widget.isDark,
            onSuccess: () {
              Navigator.pop(context, true);
            },
          ),
        ),
      );
      authenticated = result ?? false;
    }

    if (authenticated) {
      setState(() => _revealedCardId = cardId);
    }
  }

  void _autoLock(CardData card) {
    if (_revealedCardId == _cardId(card)) {
      setState(() => _revealedCardId = null);
    }
  }

  Widget _adaptiveContentShell(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  AdaptiveLayout.contentMaxWidthForWidth(constraints.maxWidth),
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildCardItem(CardData card) {
    final cardId = _cardId(card);
    final bool isDeleting = _deletingCardIds.contains(cardId);

    return DeletingListItemWrapper(
      key: ValueKey(cardId),
      isDeleting: isDeleting,
      child: SecureRevealWrapper(
        revealed: _revealedCardId == cardId,
        onAutoLock: () => _autoLock(card),
        child: BankCard(
          bankLogo: card.bankCid,
          networkLogo: card.cardNetwork.assetPath,
          cardType: card.cardType == CardType.credit ? 'Credit' : 'Debit',
          cardNumber: card.cardNumber,
          validThru: card.expiry,
          holderName: card.holderName,
          cvv: card.cvv,
          customBankName: card.customBankName,
          customBankLogoPath: card.customBankLogoPath,
          customGradientStartColor: card.customGradientStartColor != null
              ? Color(card.customGradientStartColor!)
              : null,
          customGradientEndColor: card.customGradientEndColor != null
              ? Color(card.customGradientEndColor!)
              : null,
          onEyeTap: () => _toggleReveal(card),
          onShareTap: () {
            if (_revealedCardId != cardId) {
              return;
            }
            CardShareHelper.shareCard(card);
          },
          onDeleteTap: () => _showDeleteSheet(card, cardId),
        ),
      ),
    );
  }

  void _showDeleteSheet(CardData card, String cardId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DeleteCardSheet(
        card: card,
        isDark: widget.isDark,
        onDeleteConfirmed: () async {
          setState(() {
            _deletingCardIds.add(cardId);
          });

          await Future.delayed(const Duration(milliseconds: 750));
          await CardRepository.delete(card);

          if (mounted) {
            setState(() {
              _cards.removeWhere((c) => c.cardNumber == card.cardNumber);
              _deletingCardIds.remove(cardId);
              _revealedCardId = null;
            });
          }
        },
      ),
    );
  }

  Widget _buildCardsLayout(List<CardData> visibleCards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final paneCount =
            AdaptiveLayout.cardPaneCountForWidth(constraints.maxWidth);
        final horizontalPadding =
            AdaptiveLayout.horizontalPaddingForWidth(constraints.maxWidth);

        if (paneCount == 1) {
          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              120,
            ),
            itemCount: visibleCards.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: bankCardVerticalSpacing),
                child: _buildCardItem(visibleCards[index]),
              );
            },
          );
        }

        const spacing = AdaptiveLayout.cardPaneSpacing;
        final contentWidth = (AdaptiveLayout.phoneCardWidth * paneCount) +
            (spacing * (paneCount - 1));
        const cardWidth = AdaptiveLayout.phoneCardWidth;

        return SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            0,
            horizontalPadding,
            120,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              child: Wrap(
                spacing: spacing,
                runSpacing: bankCardVerticalSpacing,
                children: visibleCards.map((card) {
                  return SizedBox(
                    width: cardWidth,
                    child: _buildCardItem(card),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= UI =================

  Widget _buildSidePane() {
    final sidePane = _sidePane;
    if (sidePane == null) {
      return const SizedBox.shrink();
    }

    final child = switch (sidePane) {
      _HomeSidePane.addCard => AddCardFlowScreen(
          key: const ValueKey('add_card_side_pane'),
          isDark: widget.isDark,
          embedded: true,
          controller: _addCardFlowController,
          onClose: _closeSidePane,
          onCardAdded: _addCard,
        ),
      _HomeSidePane.settings => SettingsScreen(
          key: const ValueKey('settings_side_pane'),
          isDark: widget.isDark,
          onThemeChanged: widget.onThemeChanged,
          onClose: () {
            _refreshCardsAfterSettings();
            _closeSidePane();
          },
        ),
    };

    final palette = SwalletPalette(widget.isDark);

    return Material(
      color: palette.background,
      elevation: 0,
      child: ClipRect(
        child: Navigator(
          key: _sidePaneNavigatorKey,
          onGenerateRoute: (_) {
            return MaterialPageRoute<void>(
              builder: (_) => child,
            );
          },
        ),
      ),
    );
  }

  Widget _buildHomeContent({
    required bool isEmptyState,
    required List<CardData> allCards,
    required List<CardData> visibleCards,
  }) {
    final palette = SwalletPalette(widget.isDark);

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 14),
          _adaptiveContentShell(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: palette.surfaceLow,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: palette.primary.withValues(
                                alpha: widget.isDark ? 0.12 : 0.06,
                              ),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/images/logo_44.svg',
                          width: 34,
                          height: 34,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Swallet',
                            style: SwalletText.title.copyWith(
                              color: palette.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEmptyState
                                ? 'Your digital card storage'
                                : '${allCards.length} saved cards',
                            style: SwalletText.caption.copyWith(
                              color: palette.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SettingsButton(
                        isDark: widget.isDark,
                        onTap: _openSettings,
                      ),
                      const SizedBox(width: 12),
                      ThemeLottieToggle(
                        isDark: widget.isDark,
                        onChanged: widget.onThemeChanged,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (!isEmptyState) ...[
            _adaptiveContentShell(
              TopNavBar(
                key: ValueKey(allCards.length),
                isDark: widget.isDark,
                categories: _buildTopNavCategories(allCards),
                onSelectionChanged: (ids) {
                  setState(() {
                    _activeFilters
                      ..clear()
                      ..addAll(ids);
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: isEmptyState
                ? EmptyWalletView(isDark: widget.isDark)
                : visibleCards.isEmpty
                    ? Center(
                        child: Text(
                          'No cards found',
                          style: SwalletText.bodyMedium.copyWith(
                            color: palette.textMuted,
                          ),
                        ),
                      )
                    : _buildCardsLayout(visibleCards),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveBody({
    required bool isEmptyState,
    required List<CardData> allCards,
    required List<CardData> visibleCards,
    required bool showSidePane,
  }) {
    final homeContent = _buildHomeContent(
      isEmptyState: isEmptyState,
      allCards: allCards,
      visibleCards: visibleCards,
    );

    if (!showSidePane) {
      return homeContent;
    }

    return Row(
      children: [
        Expanded(child: homeContent),
        SizedBox(
          width: AdaptiveLayout.formPaneMaxWidth,
          child: _buildSidePane(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<CardData>>(
      valueListenable: Hive.box<CardData>(HiveBoxes.cards).listenable(),
      builder: (context, cardsBox, _) {
        final allCards = _cardsForDisplay(cardsBox);
        final visibleCards = _filteredCards(allCards);
        final bool isEmptyState = allCards.isEmpty;
        final bool showSidePane = _sidePane != null && _usesSidePane(context);
        final screenWidth = MediaQuery.sizeOf(context).width;
        final fabRightInset = showSidePane
            ? AdaptiveLayout.formPaneMaxWidth + 16
            : AdaptiveLayout.outerGutterForWidth(screenWidth);

        return PopScope(
          canPop: _sidePane == null,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            _handleSidePaneBack();
          },
          child: Scaffold(
            floatingActionButton: Padding(
              padding: EdgeInsets.only(right: fabRightInset),
              child: AnimatedAddCardButton(
                collapsed: _fabCollapsed && !isEmptyState,
                onTap: _openAddCard,
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: _buildAdaptiveBody(
              isEmptyState: isEmptyState,
              allCards: allCards,
              visibleCards: visibleCards,
              showSidePane: showSidePane,
            ),
          ),
        );
      },
    );
  }
}

enum _HomeSidePane {
  addCard,
  settings,
}
