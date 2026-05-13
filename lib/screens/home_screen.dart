import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/layout_constants.dart';

import '../models/card_data.dart';
import '../models/card_type.dart';

import '../widgets/top_nav/top_nav_bar.dart';
import '../widgets/top_nav/top_nav_category.dart';
import '../widgets/home/empty_wallet_view.dart';
import '../widgets/home/swipe_actions_tutorial_overlay.dart';
import '../widgets/app_lock/mini_pin_pad.dart';

import '../widgets/card/bank_card.dart';
import '../widgets/card/secure_reveal_wrapper.dart';
import '../widgets/buttons/animated_add_card_button.dart';
import '../widgets/buttons/theme_lottie_toggle.dart';
import '../widgets/buttons/settings_button.dart';
import '../widgets/actions/card_action_button.dart';

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
  final Animation<double>? unlockSettleAnimation;

  const HomeScreen({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
    this.unlockSettleAnimation,
  });

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static const String _swipeActionsTutorialSeenKey =
      'swipe_actions_tutorial_v1_seen';

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
  CardData? _editingCard;
  String? _editingCardId;
  int _swipeResetToken = 0;
  String? _activeSwipeCardId;
  bool _swipeTutorialQueued = false;
  bool _homeEntrySettled = false;

  // ================= EXTERNAL REVEAL CANCEL =================

  bool get isPrimarySurfaceVisible => _sidePane == null;

  void cancelAllReveals() {
    if (!mounted) return;
    setState(() {
      _revealedCardId = null;
      _swipeResetToken++;
      _activeSwipeCardId = null;
    });
  }

  void refreshCardsFromStorage() {
    if (!mounted) return;
    setState(() {
      _cards
        ..clear()
        ..addAll(CardRepository.getAll());
      _revealedCardId = null;
      _activeFilters.clear();
      _swipeResetToken++;
      _activeSwipeCardId = null;
    });
  }

  bool _usesSidePane(BuildContext context) {
    return AdaptiveLayout.windowClassForWidth(
            MediaQuery.sizeOf(context).width) ==
        AdaptiveWindowClass.expanded;
  }

  void _closeSidePane() {
    if (_sidePane == null) return;
    setState(() {
      _sidePane = null;
      _editingCard = null;
      _editingCardId = null;
      _swipeResetToken++;
      _activeSwipeCardId = null;
    });
  }

  Future<void> _openAddCard() async {
    cancelAllReveals();
    if (_usesSidePane(context)) {
      setState(() {
        _sidePaneNavigatorKey = GlobalKey();
        _sidePane = _HomeSidePane.addCard;
        _editingCard = null;
        _editingCardId = null;
        _swipeResetToken++;
        _activeSwipeCardId = null;
      });
      return;
    }

    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => AddCardFlowScreen(
          isDark: widget.isDark,
          onCardAdded: _addCard,
        ),
      ),
    );

    if (mounted) {
      setState(() {
        _swipeResetToken++;
        _activeSwipeCardId = null;
      });
    }
  }

  Future<void> _openSettings() async {
    cancelAllReveals();
    if (_usesSidePane(context)) {
      setState(() {
        _sidePaneNavigatorKey = GlobalKey();
        _sidePane = _HomeSidePane.settings;
        _editingCard = null;
        _editingCardId = null;
        _swipeResetToken++;
        _activeSwipeCardId = null;
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
      _editingCard = null;
      _editingCardId = null;
      _swipeResetToken++;
      _activeSwipeCardId = null;
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
      case _HomeSidePane.editCard:
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

  void _scheduleSwipeActionsTutorial({
    required bool hasCards,
    required bool showSidePane,
  }) {
    if (_swipeTutorialQueued ||
        !_homeEntrySettled ||
        !hasCards ||
        showSidePane) {
      return;
    }

    final settingsBox = Hive.box(HiveBoxes.settings);
    final seen = settingsBox.get(
      _swipeActionsTutorialSeenKey,
      defaultValue: false,
    );
    if (seen == true) return;

    _swipeTutorialQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (!_homeEntrySettled || _sidePane != null) {
        _swipeTutorialQueued = false;
        return;
      }

      final cardsBox = Hive.box<CardData>(HiveBoxes.cards);
      if (_cardsForDisplay(cardsBox).isEmpty) {
        _swipeTutorialQueued = false;
        return;
      }

      final completed = await _showSwipeActionsTutorial();
      if (completed == true) {
        await settingsBox.put(_swipeActionsTutorialSeenKey, true);
      }
      _swipeTutorialQueued = false;
    });
  }

  Future<bool?> _showSwipeActionsTutorial() {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Swipe actions tutorial',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, _, __) {
        return SwipeActionsTutorialOverlay(
          isDark: widget.isDark,
          onDone: () => Navigator.of(context).pop(true),
        );
      },
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  bool _isUnlockSettleComplete(Animation<double>? animation) {
    return animation == null || animation.value >= 0.999;
  }

  void _handleUnlockSettleStatus(AnimationStatus status) {
    final settled = status == AnimationStatus.completed ||
        _isUnlockSettleComplete(widget.unlockSettleAnimation);
    if (_homeEntrySettled == settled || !mounted) return;

    setState(() => _homeEntrySettled = settled);
  }

  void _attachUnlockSettleAnimation() {
    _homeEntrySettled = _isUnlockSettleComplete(widget.unlockSettleAnimation);
    widget.unlockSettleAnimation?.addStatusListener(_handleUnlockSettleStatus);
  }

  void _detachUnlockSettleAnimation(Animation<double>? animation) {
    animation?.removeStatusListener(_handleUnlockSettleStatus);
  }

  // ================= LIFECYCLE =================

  @override
  void initState() {
    super.initState();
    _cards.addAll(CardRepository.getAll());
    _attachUnlockSettleAnimation();

    _scrollController.addListener(() {
      final shouldCollapse = _scrollController.offset > 40;
      if (shouldCollapse != _fabCollapsed) {
        setState(() => _fabCollapsed = shouldCollapse);
      }
    });
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unlockSettleAnimation == widget.unlockSettleAnimation) {
      return;
    }

    _detachUnlockSettleAnimation(oldWidget.unlockSettleAnimation);
    _attachUnlockSettleAnimation();
  }

  @override
  void dispose() {
    _detachUnlockSettleAnimation(widget.unlockSettleAnimation);
    _scrollController.dispose();
    super.dispose();
  }

  // ================= SECURE REVEAL LOGIC =================

  String _cardId(CardData card) {
    return '${card.bankCid}|${card.customBankName ?? ''}|'
        '${card.customBankLogoPath ?? ''}|${card.cardNumber}|'
        '${card.customGradientStartColor ?? ''}|'
        '${card.customGradientMiddleColor ?? ''}|'
        '${card.customGradientEndColor ?? ''}|'
        '${card.customCardImagePath ?? ''}|'
        '${card.customCardPatternAssetPath ?? ''}|'
        '${card.customCardVisualMode ?? ''}|'
        '${card.customCardImageAlignmentX ?? ''}|'
        '${card.customCardImageAlignmentY ?? ''}|${card.expiry}|'
        '${card.holderName}';
  }

  Future<void> _toggleReveal(CardData card) async {
    final cardId = _cardId(card);

    if (_revealedCardId == cardId) {
      setState(() {
        _revealedCardId = null;
        _swipeResetToken++;
        _activeSwipeCardId = null;
      });
      return;
    }

    setState(() {
      _swipeResetToken++;
      _activeSwipeCardId = null;
    });

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
      setState(() {
        _revealedCardId = cardId;
        _swipeResetToken++;
        _activeSwipeCardId = null;
      });
    }
  }

  void _autoLock(CardData card) {
    if (_revealedCardId == _cardId(card)) {
      setState(() {
        _revealedCardId = null;
        _swipeResetToken++;
        _activeSwipeCardId = null;
      });
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
      child: _SwipeableCardActions(
        isDark: widget.isDark,
        cardId: cardId,
        activeSwipeCardId: _activeSwipeCardId,
        resetToken: _swipeResetToken,
        onSwipeStarted: () {
          if (_activeSwipeCardId == cardId) return;
          setState(() => _activeSwipeCardId = cardId);
        },
        onSwipeClosed: () {
          if (_activeSwipeCardId != cardId) return;
          setState(() => _activeSwipeCardId = null);
        },
        onEdit: () => _openEditCard(card, cardId),
        onDelete: () => _showDeleteSheet(card, cardId),
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
            customGradientMiddleColor: card.customGradientMiddleColor != null
                ? Color(card.customGradientMiddleColor!)
                : null,
            customGradientEndColor: card.customGradientEndColor != null
                ? Color(card.customGradientEndColor!)
                : null,
            customCardImagePath: card.customCardVisualMode == 1
                ? card.customCardImagePath
                : null,
            customCardPatternAssetPath: card.customCardVisualMode == 0
                ? card.customCardPatternAssetPath
                : null,
            customCardImageAlignment: Alignment(
              card.customCardImageAlignmentX ?? 0,
              card.customCardImageAlignmentY ?? 0,
            ),
            showActions: _homeEntrySettled,
            onEyeTap: () => _toggleReveal(card),
            onShareTap: () {
              if (_revealedCardId != cardId) {
                return;
              }
              CardShareHelper.shareCard(card);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openEditCard(CardData card, String cardId) async {
    cancelAllReveals();
    if (_usesSidePane(context)) {
      setState(() {
        _sidePaneNavigatorKey = GlobalKey();
        _sidePane = _HomeSidePane.editCard;
        _editingCard = card;
        _editingCardId = cardId;
        _swipeResetToken++;
        _activeSwipeCardId = null;
      });
      return;
    }

    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => AddCardFlowScreen(
          isDark: widget.isDark,
          initialCard: card,
          onCardAdded: (_) {},
          onCardUpdated: (updated) {
            _handleEditedCardSaved(card, cardId, updated);
          },
        ),
      ),
    );

    if (mounted) {
      setState(() {
        _swipeResetToken++;
        _activeSwipeCardId = null;
      });
    }
  }

  Future<void> _handleEditedCardSaved(
    CardData original,
    String originalCardId,
    CardData updated,
  ) async {
    await CardRepository.update(original, updated);
    if (!mounted) return;

    setState(() {
      final index = _cards.indexWhere((card) => identical(card, original));
      if (index != -1) {
        _cards[index] = updated;
      } else {
        final fallbackIndex =
            _cards.indexWhere((card) => _cardId(card) == originalCardId);
        if (fallbackIndex != -1) {
          _cards[fallbackIndex] = updated;
        }
      }
      _revealedCardId = null;
      _sidePane = null;
      _editingCard = null;
      _editingCardId = null;
      _swipeResetToken++;
      _activeSwipeCardId = null;
    });
  }

  void _showDeleteSheet(CardData card, String cardId) {
    setState(() {
      _swipeResetToken++;
      _activeSwipeCardId = null;
    });
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
              _swipeResetToken++;
              _activeSwipeCardId = null;
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
          final cardWidth = constraints.maxWidth - (horizontalPadding * 2);

          return AnimatedBuilder(
            animation: _scrollController,
            builder: (context, _) {
              if (visibleCards.length <= 3) {
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
                      padding: const EdgeInsets.only(
                        bottom: bankCardVerticalSpacing,
                      ),
                      child: _buildCardItem(visibleCards[index]),
                    );
                  },
                );
              }

              return ListView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  120,
                ),
                children: [
                  for (var index = 0; index < 2; index++)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: bankCardVerticalSpacing,
                      ),
                      child: _buildCardItem(visibleCards[index]),
                    ),
                  _StackedCardListSection(
                    cards: visibleCards.sublist(2),
                    cardWidth: cardWidth,
                    scrollOffset: _scrollController.hasClients
                        ? _scrollController.offset
                        : 0,
                    itemBuilder: _buildCardItem,
                  ),
                ],
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
      _HomeSidePane.editCard => AddCardFlowScreen(
          key: ValueKey('edit_card_side_pane_${_editingCardId ?? ''}'),
          isDark: widget.isDark,
          embedded: true,
          controller: _addCardFlowController,
          initialCard: _editingCard,
          onClose: _closeSidePane,
          onCardAdded: (_) {},
          onCardUpdated: (updated) {
            final original = _editingCard;
            final originalId = _editingCardId;
            if (original == null || originalId == null) return;
            _handleEditedCardSaved(original, originalId, updated);
          },
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
    final paneContent = ClipRect(
      child: sidePane == _HomeSidePane.settings
          ? _SidePaneNavigator(
              navigatorKey: _sidePaneNavigatorKey,
              child: child,
            )
          : child,
    );

    return Material(
      color: palette.background,
      elevation: 0,
      child: paneContent,
    );
  }

  Widget _buildHomeContent({
    required bool isEmptyState,
    required List<CardData> allCards,
    required List<CardData> visibleCards,
  }) {
    final palette = SwalletPalette(widget.isDark);
    final cardArea = isEmptyState
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
            : _UnlockEntryCardStage(
                animation: widget.unlockSettleAnimation,
                child: _buildCardsLayout(visibleCards),
              );

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
                introAnimation: widget.unlockSettleAnimation,
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
            child: cardArea,
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
        _scheduleSwipeActionsTutorial(
          hasCards: allCards.isNotEmpty,
          showSidePane: showSidePane,
        );
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
              child: _HomeEntryFabStage(
                visible: _homeEntrySettled,
                child: AnimatedAddCardButton(
                  collapsed: _fabCollapsed && !isEmptyState,
                  onTap: _openAddCard,
                ),
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

class _HomeEntryFabStage extends StatefulWidget {
  final bool visible;
  final Widget child;

  const _HomeEntryFabStage({
    required this.visible,
    required this.child,
  });

  @override
  State<_HomeEntryFabStage> createState() => _HomeEntryFabStageState();
}

class _HomeEntryFabStageState extends State<_HomeEntryFabStage>
    with SingleTickerProviderStateMixin {
  static const Duration _delay = Duration(milliseconds: 90);
  static const Duration _duration = Duration(milliseconds: 360);
  static const Curve _curve = Cubic(0.22, 1, 0.36, 1);

  late final AnimationController _controller;
  late final Animation<double> _animation;
  Future<void>? _sequence;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _duration,
      value: widget.visible ? 1 : 0,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: _curve,
      reverseCurve: Curves.easeInCubic,
    );
    if (widget.visible) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant _HomeEntryFabStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) return;

    if (widget.visible) {
      final sequence = Future<void>.delayed(_delay);
      _sequence = sequence;
      sequence.then((_) {
        if (!mounted || _sequence != sequence || !widget.visible) return;
        _controller.forward();
      });
    } else {
      _sequence = null;
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _sequence = null;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        final progress = _animation.value;

        return IgnorePointer(
          ignoring: progress < 1,
          child: Opacity(
            opacity: progress,
            child: Transform.translate(
              offset: Offset(96 * (1 - progress), 0),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _UnlockEntryCardStage extends StatelessWidget {
  final Animation<double>? animation;
  final Widget child;

  const _UnlockEntryCardStage({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final animation = this.animation;
    if (animation == null || animation.value >= 0.999) {
      return child;
    }

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final raw =
            ((animation.value - 0.94) / 0.06).clamp(0.0, 1.0).toDouble();
        final opacity = Curves.easeOutCubic.transform(raw);

        return IgnorePointer(
          ignoring: opacity < 1,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
    );
  }
}

class _StackedCardListSection extends StatelessWidget {
  static const Curve _stackSettleCurve = Cubic(0.22, 1, 0.36, 1);
  static const double _cardTiltPadding = 8;
  static const double _collapsedScaleStep = 0.045;
  static const int _maxCollapsedDepth = 4;
  static const int _visibleCollapsedCards = 4;
  static const List<double> _collapsedTopOffsets = <double>[
    64,
    30,
    12,
    0,
  ];

  final List<CardData> cards;
  final double cardWidth;
  final double scrollOffset;
  final Widget Function(CardData card) itemBuilder;

  const _StackedCardListSection({
    required this.cards,
    required this.cardWidth,
    required this.scrollOffset,
    required this.itemBuilder,
  });

  double _lerp(double from, double to, double progress) {
    return from + ((to - from) * progress);
  }

  @override
  Widget build(BuildContext context) {
    final cardHeight =
        cardWidth * (cardAspectRatioHeight / cardAspectRatioWidth);
    final itemHeight = cardHeight + _cardTiltPadding;
    const itemGap = bankCardVerticalSpacing;
    final slotHeight = itemHeight + itemGap;
    final progress = _stackSettleCurve.transform(
      (scrollOffset / (cardHeight * 0.84)).clamp(0.0, 1.0).toDouble(),
    );
    final sectionHeight = cards.length * slotHeight;
    final maxDepth = (cards.length - 1).clamp(1, _maxCollapsedDepth);

    return SizedBox(
      height: sectionHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var index = cards.length - 1; index >= 0; index--)
            _StackedCardPosition(
              top: _topForIndex(
                index: index,
                maxDepth: maxDepth,
                slotHeight: slotHeight,
                progress: progress,
              ),
              scale: _scaleForIndex(
                index: index,
                maxDepth: maxDepth,
                progress: progress,
              ),
              opacity: _opacityForIndex(index: index, progress: progress),
              interactionsEnabled: progress >= 0.995,
              child: itemBuilder(cards[index]),
            ),
        ],
      ),
    );
  }

  double _topForIndex({
    required int index,
    required int maxDepth,
    required double slotHeight,
    required double progress,
  }) {
    final collapsedTop = _collapsedTopForIndex(index);
    final expandedTop = index * slotHeight;

    return _lerp(collapsedTop, expandedTop, progress);
  }

  double _scaleForIndex({
    required int index,
    required int maxDepth,
    required double progress,
  }) {
    final collapsedDepth = index.clamp(0, maxDepth);
    final collapsedScale = 1 - (_collapsedScaleStep * collapsedDepth);

    return _lerp(collapsedScale, 1, progress);
  }

  double _collapsedTopForIndex(int index) {
    if (index < _collapsedTopOffsets.length) {
      return _collapsedTopOffsets[index];
    }

    return _collapsedTopOffsets.last;
  }

  double _opacityForIndex({
    required int index,
    required double progress,
  }) {
    final collapsedOpacity = index < _visibleCollapsedCards ? 1.0 : 0.0;
    return _lerp(collapsedOpacity, 1, progress);
  }
}

class _StackedCardPosition extends StatelessWidget {
  final double top;
  final double scale;
  final double opacity;
  final bool interactionsEnabled;
  final Widget child;

  const _StackedCardPosition({
    required this.top,
    required this.scale,
    required this.opacity,
    required this.interactionsEnabled,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: !interactionsEnabled,
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SwipeableCardActions extends StatefulWidget {
  final Widget child;
  final bool isDark;
  final String cardId;
  final String? activeSwipeCardId;
  final int resetToken;
  final VoidCallback onSwipeStarted;
  final VoidCallback onSwipeClosed;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SwipeableCardActions({
    required this.child,
    required this.isDark,
    required this.cardId,
    required this.activeSwipeCardId,
    required this.resetToken,
    required this.onSwipeStarted,
    required this.onSwipeClosed,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_SwipeableCardActions> createState() => _SwipeableCardActionsState();
}

class _SwipeableCardActionsState extends State<_SwipeableCardActions> {
  static const double _buttonSize = 52;
  static const double _buttonGap = 8;
  static const double _buttonInset = 12;
  static const double _cardActionGap = 12;
  static const double _actionWidth =
      _buttonInset + (_buttonSize * 2) + _buttonGap;
  static const double _openOffset = _actionWidth + _cardActionGap;
  static const Duration _snapDuration = Duration(milliseconds: 220);

  double _dragOffset = 0;
  bool _isDragging = false;

  bool get _isOpen => _dragOffset <= -_openOffset * 0.45;

  @override
  void didUpdateWidget(covariant _SwipeableCardActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resetToken != oldWidget.resetToken && _dragOffset != 0) {
      _dragOffset = 0;
      _isDragging = false;
    }
    if (widget.activeSwipeCardId != oldWidget.activeSwipeCardId &&
        widget.activeSwipeCardId != widget.cardId &&
        _dragOffset != 0) {
      _dragOffset = 0;
      _isDragging = false;
    }
  }

  void _handleDragStart(DragStartDetails details) {
    widget.onSwipeStarted();
    setState(() => _isDragging = true);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dx).clamp(-_openOffset, 0.0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final shouldOpen = velocity < -220 || (velocity <= 220 && _isOpen);

    setState(() {
      _isDragging = false;
      _dragOffset = shouldOpen ? -_openOffset : 0;
    });
    if (!shouldOpen) {
      widget.onSwipeClosed();
    }
  }

  void _handleDragCancel() {
    setState(() {
      _isDragging = false;
      _dragOffset = 0;
    });
    widget.onSwipeClosed();
  }

  void _closeAndRun(VoidCallback action) {
    setState(() => _dragOffset = 0);
    widget.onSwipeClosed();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (-_dragOffset / _openOffset).clamp(0.0, 1.0);
    final scale = 1.0 - (0.035 * progress);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      onHorizontalDragCancel: _handleDragCancel,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerRight,
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              widthFactor: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CardActionButton(
                    icon: Icons.edit_rounded,
                    isDark: widget.isDark,
                    onTap: () => _closeAndRun(widget.onEdit),
                  ),
                  const SizedBox(width: _buttonGap),
                  CardActionButton(
                    icon: Icons.delete_rounded,
                    isDark: widget.isDark,
                    destructive: true,
                    onTap: () => _closeAndRun(widget.onDelete),
                  ),
                  const SizedBox(width: _buttonInset),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: _isDragging ? Duration.zero : _snapDuration,
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..translateByDouble(_dragOffset, 0, 0, 1)
              ..scaleByDouble(scale, scale, 1, 1),
            transformAlignment: Alignment.center,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

enum _HomeSidePane {
  addCard,
  editCard,
  settings,
}

class _SidePaneNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const _SidePaneNavigator({
    required this.navigatorKey,
    required this.child,
  });

  @override
  State<_SidePaneNavigator> createState() => _SidePaneNavigatorState();
}

class _SidePaneNavigatorState extends State<_SidePaneNavigator> {
  late final ValueNotifier<Widget> _childNotifier;

  @override
  void initState() {
    super.initState();
    _childNotifier = ValueNotifier<Widget>(widget.child);
  }

  @override
  void didUpdateWidget(covariant _SidePaneNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _childNotifier.value = widget.child;
  }

  @override
  void dispose() {
    _childNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      onGenerateRoute: (_) {
        return MaterialPageRoute<void>(
          builder: (_) => ValueListenableBuilder<Widget>(
            valueListenable: _childNotifier,
            builder: (_, child, __) => child,
          ),
        );
      },
    );
  }
}
