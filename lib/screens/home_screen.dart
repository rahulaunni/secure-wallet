import 'dart:io';

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

// ✅ IMPORT THE ANIMATION WRAPPER
import '../widgets/animations/deleting_list_item_wrapper.dart';

import 'add_card_flow/add_card_flow_screen.dart';
import 'settings/settings_screen.dart';
import '../utils/device_auth.dart';

import '../data/local/card_repository.dart';
import '../data/local/hive_boxes.dart';
import '../theme/swallet_theme.dart';
import '../utils/adaptive_layout.dart';
import '../utils/app_startup_preloader.dart';
import '../utils/card_share_helper.dart';

const int kStackPreviewCount = 4;
const int kTailPrewarmCandidateCount = 5;

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

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const String _swipeActionsTutorialSeenKey =
      'swipe_actions_tutorial_v1_seen';
  static const double _targetCompactCacheExtent = 2500;
  static const Duration _incomingCardSlotDuration = Duration(milliseconds: 2000);
  static const Duration _leadingDeleteReflowDuration = Duration(milliseconds: 1600);

  late final ScrollController _scrollController;
  late final AnimationController _incomingCardPrepController;
  late final AnimationController _leadingDeleteReflowController;
  final AddCardFlowController _addCardFlowController = AddCardFlowController();
  GlobalKey<NavigatorState> _sidePaneNavigatorKey = GlobalKey();
  final GlobalKey _incomingCardSlotKey = GlobalKey();

  bool _fabCollapsed = false;

  final List<CardData> _cards = [];

  // ✅ Track cards currently animating out
  final Set<String> _deletingCardIds = {};

  // 🔒 SINGLE SOURCE OF TRUTH FOR REVEAL
  String? _revealedCardId;
  String? _closingRevealCardId;

  // 🔒 ACTIVE TOP NAV FILTERS
  final Set<String> _activeFilters = {};

  _HomeSidePane? _sidePane;
  CardData? _editingCard;
  String? _editingCardId;
  int _swipeResetToken = 0;
  String? _activeSwipeCardId;
  bool _swipeTutorialQueued = false;
  bool _homeEntrySettled = false;
  bool _compactCacheExtentPrimed = false;
  double? _compactCacheExtent;
  final Set<String> _precachedCustomImageKeys = {};
  CardData? _pendingIncomingCard;
  String? _pendingLeadingDeleteCardId;
  int? _pendingLeadingDeleteIndex;
  List<CardData> _pendingLeadingDeleteCards = const <CardData>[];

  double get _incomingCardPrepProgress => _incomingCardPrepController.value;
  double get _leadingDeleteReflowProgress => _leadingDeleteReflowController.value;

  // ================= EXTERNAL REVEAL CANCEL =================

  bool get isPrimarySurfaceVisible => _sidePane == null;

  String? get _effectiveRevealedCardId => _revealedCardId ?? _closingRevealCardId;

  void _beginRevealClose(String cardId) {
    setState(() {
      _closingRevealCardId = cardId;
      _revealedCardId = null;
      _swipeResetToken++;
      _activeSwipeCardId = null;
    });
  }

  void cancelAllReveals() {
    if (!mounted) return;
    setState(() {
      _revealedCardId = null;
      _closingRevealCardId = null;
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
      _precachedCustomImageKeys.clear();
      _revealedCardId = null;
      _closingRevealCardId = null;
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

    final addedCard = await Navigator.of(context).push<CardData>(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => AddCardFlowScreen(
          isDark: widget.isDark,
          onCardAdded: (_) {},
        ),
      ),
    );

    if (addedCard != null) {
      await _animateIncomingCardAdd(addedCard);
    }

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
    _incomingCardPrepController.reset();
    setState(() {
      _pendingIncomingCard = null;
      _cards.insert(0, card);
      _sidePane = null;
      _editingCard = null;
      _editingCardId = null;
      _swipeResetToken++;
      _activeSwipeCardId = null;
    });
  }

  void _scheduleCustomImagePrecache(
    List<CardData> cards, {
    required double cardWidth,
  }) {
    if (!mounted || cards.isEmpty || cardWidth <= 0) return;

    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final targetImageWidth = (cardWidth * devicePixelRatio).round();
    final imagePaths = <String>[];

    for (final card in cards) {
      if (card.customCardVisualMode != 1) continue;
      final imagePath = card.customCardImagePath?.trim();
      if (imagePath == null || imagePath.isEmpty) continue;

      final key = '$imagePath@$targetImageWidth';
      if (_precachedCustomImageKeys.contains(key)) continue;
      _precachedCustomImageKeys.add(key);
      imagePaths.add(imagePath);
    }

    if (imagePaths.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var index = 0; index < imagePaths.length; index++) {
        Future<void>.delayed(Duration(milliseconds: index * 28), () {
          if (!mounted) return;
          final file = File(imagePaths[index]);
          if (!file.existsSync()) return;

          precacheImage(
            ResizeImage.resizeIfNeeded(
              targetImageWidth,
              null,
              FileImage(file),
            ),
            context,
          );
        });
      }
    });
  }

  void _refreshCardsAfterSettings() {
    refreshCardsFromStorage();
  }

  Future<void> _animateIncomingCardAdd(CardData card) async {
    if (!mounted) return;
    cancelAllReveals();
    _incomingCardPrepController.stop();
    _incomingCardPrepController.value = 0;
    setState(() {
      _pendingIncomingCard = card;
      _swipeResetToken++;
      _activeSwipeCardId = null;
    });

    if (_scrollController.hasClients && _scrollController.offset > 0) {
      try {
        await _scrollController.animateTo(
          0,
          duration: _incomingCardSlotDuration,
          curve: Curves.easeOutCubic,
        );
      } catch (_) {}
    }

    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await _incomingCardPrepController.forward();
    if (!mounted) return;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (!mounted) return;
    await _addCard(card);
  }

  void _primeCompactCacheExtent() {
    if (_compactCacheExtentPrimed || _compactCacheExtent == _targetCompactCacheExtent) {
      return;
    }

    _compactCacheExtentPrimed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _compactCacheExtent == _targetCompactCacheExtent) {
        return;
      }
      setState(() {
        _compactCacheExtent = _targetCompactCacheExtent;
      });
    });
  }

  void _scheduleTailCardPrewarm(
    List<CardData> tailCards, {
    required double cardWidth,
  }) {
    if (!mounted || tailCards.isEmpty || cardWidth <= 0) {
      return;
    }

    AppStartupPreloader.scheduleCardWarmUp(
      context,
      tailCards.take(kTailPrewarmCandidateCount),
      cardWidth: cardWidth,
    );
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
    final storedCards = cardsBox.values
        .toList(growable: false)
        .reversed
        .toList(growable: false);
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
    _scrollController = ScrollController();
    _incomingCardPrepController = AnimationController(
      vsync: this,
      duration: _incomingCardSlotDuration,
    )..addListener(() {
        if (mounted && _pendingIncomingCard != null) {
          setState(() {});
        }
      });
    _leadingDeleteReflowController = AnimationController(
      vsync: this,
      duration: _leadingDeleteReflowDuration,
    )..addListener(() {
        if (mounted && _pendingLeadingDeleteCardId != null) {
          setState(() {});
        }
      });
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
    _incomingCardPrepController.dispose();
    _leadingDeleteReflowController.dispose();
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
      _beginRevealClose(cardId);
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
        _closingRevealCardId = null;
        _swipeResetToken++;
        _activeSwipeCardId = null;
      });
    }
  }

  void _autoLock(CardData card) {
    if (!mounted) return;
    final cardId = _cardId(card);
    if (_revealedCardId == cardId) {
      _beginRevealClose(cardId);
    }
  }

  void _handleRevealCollapseComplete(String cardId) {
    if (!mounted || _closingRevealCardId != cardId) {
      return;
    }
    setState(() {
      _closingRevealCardId = null;
    });
  }

  Widget _adaptiveContentShell(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AdaptiveLayout.contentMaxWidthForWidth(
                constraints.maxWidth,
              ),
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

    final cardItem = DeletingListItemWrapper(
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
        isDeleting: isDeleting,
        onDeleteConfirmed: () => _deleteCard(card, cardId),
        child: SecureRevealWrapper(
          revealed: _revealedCardId == cardId,
          onAutoLock: () => _autoLock(card),
          onCollapseComplete: () => _handleRevealCollapseComplete(cardId),
          child: BankCard(
            snapshotSourceCard: card,
            enableVisualSnapshot: true,
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
    return cardItem;
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

  Future<void> _deleteCard(CardData card, String cardId) async {
    final paneCount = AdaptiveLayout.cardPaneCountForWidth(
      MediaQuery.sizeOf(context).width,
    );
    final visibleCards = _filteredCards(
      _cardsForDisplay(Hive.box<CardData>(HiveBoxes.cards)),
    );
    final leadingDeleteIndex = paneCount == 1
        ? _leadingDeleteIndexForCard(cardId, visibleCards)
        : null;

    if (leadingDeleteIndex != null) {
      await _animateLeadingDelete(card, cardId, leadingDeleteIndex, visibleCards);
      return;
    }

    setState(() {
      _deletingCardIds.add(cardId);
      _revealedCardId = null;
      _closingRevealCardId = null;
      _activeSwipeCardId = cardId;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1120));
    await CardRepository.delete(card);

    if (!mounted) return;
    setState(() {
      _cards.removeWhere((c) => _cardId(c) == cardId);
      _deletingCardIds.remove(cardId);
      _revealedCardId = null;
      _closingRevealCardId = null;
      _swipeResetToken++;
      _activeSwipeCardId = null;
    });
  }

  int? _leadingDeleteIndexForCard(String cardId, List<CardData> visibleCards) {
    final index = visibleCards.indexWhere((card) => _cardId(card) == cardId);
    if (index < 0 || index > 1 || visibleCards.length <= 2) {
      return null;
    }
    return index;
  }

  Future<void> _animateLeadingDelete(
    CardData card,
    String cardId,
    int deleteIndex,
    List<CardData> visibleCards,
  ) async {
    if (!mounted) return;
    cancelAllReveals();
    _incomingCardPrepController.stop();
    _incomingCardPrepController.value = 0;
    _leadingDeleteReflowController.stop();
    _leadingDeleteReflowController.value = 0;

    final transitionCards = visibleCards
        .take(2 + kStackPreviewCount + 1)
        .toList(growable: false);

    setState(() {
      _pendingIncomingCard = null;
      _pendingLeadingDeleteCardId = cardId;
      _pendingLeadingDeleteIndex = deleteIndex;
      _pendingLeadingDeleteCards = transitionCards;
      _activeSwipeCardId = cardId;
    });

    if (_scrollController.hasClients && _scrollController.offset > 0) {
      try {
        await _scrollController.animateTo(
          0,
          duration: _leadingDeleteReflowDuration,
          curve: Curves.easeOutCubic,
        );
      } catch (_) {}
    }

    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await _leadingDeleteReflowController.forward();
    await CardRepository.delete(card);

    if (!mounted) return;
    setState(() {
      _cards.removeWhere((c) => _cardId(c) == cardId);
      _pendingLeadingDeleteCardId = null;
      _pendingLeadingDeleteIndex = null;
      _pendingLeadingDeleteCards = const <CardData>[];
      _revealedCardId = null;
      _closingRevealCardId = null;
      _swipeResetToken++;
      _activeSwipeCardId = null;
    });
  }

  Widget _buildCardsLayout(List<CardData> visibleCards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final paneCount =
            AdaptiveLayout.cardPaneCountForWidth(constraints.maxWidth);
        final horizontalPadding =
            AdaptiveLayout.horizontalPaddingForWidth(constraints.maxWidth);

        if (paneCount == 1) {
          _primeCompactCacheExtent();
          final cardWidth = constraints.maxWidth - (horizontalPadding * 2);
          final cardHeight =
              cardWidth * (cardAspectRatioHeight / cardAspectRatioWidth);
          _scheduleCustomImagePrecache(visibleCards, cardWidth: cardWidth);
          final incomingPreparationProgress = _incomingCardPrepProgress;
          final leadingDeleteProgress = _leadingDeleteReflowProgress;
          final preparingIncomingStack =
              _pendingIncomingCard != null &&
              visibleCards.length >= (kStackPreviewCount + 2);
          final preparingLeadingDelete =
              _pendingLeadingDeleteCardId != null &&
              _pendingLeadingDeleteIndex != null &&
              _pendingLeadingDeleteCards.isNotEmpty;
          final leadingCards = visibleCards.take(2).toList(growable: false);
          final stackPreviewCards = visibleCards
              .skip(2)
              .take(kStackPreviewCount)
              .toList(growable: false);
          final stackPreviewChildren = stackPreviewCards
              .map(_buildCardItem)
              .toList(growable: false);
          final reflowCards = preparingIncomingStack
              ? visibleCards.take(2 + kStackPreviewCount).toList(growable: false)
              : const <CardData>[];
          final reflowChildren = preparingIncomingStack
              ? reflowCards.map(_buildCardItem).toList(growable: false)
              : const <Widget>[];
          final leadingDeleteChildren = preparingLeadingDelete
              ? _pendingLeadingDeleteCards
                    .map(_buildCardItem)
                    .toList(growable: false)
              : const <Widget>[];
          final tailCards = preparingIncomingStack
              ? visibleCards.skip(2 + kStackPreviewCount).toList(growable: false)
              : visibleCards.skip(2 + kStackPreviewCount).toList(growable: false);
          final deleteTailCards = preparingLeadingDelete
              ? visibleCards
                    .skip(_pendingLeadingDeleteCards.length)
                    .toList(growable: false)
              : const <CardData>[];
          _scheduleTailCardPrewarm(tailCards, cardWidth: cardWidth);
          final hasStackPreview = stackPreviewCards.isNotEmpty;
          final compactItemCount = preparingLeadingDelete
              ? 1 + deleteTailCards.length
              : preparingIncomingStack
                  ? 2 + tailCards.length
                  : 1 +
                      leadingCards.length +
                      (hasStackPreview ? 1 : 0) +
                      tailCards.length;

          return ListView.builder(
            controller: _scrollController,
            cacheExtent: _compactCacheExtent,
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              120,
            ),
            itemCount: compactItemCount,
            itemBuilder: (context, index) {
              if (preparingLeadingDelete) {
                if (index == 0) {
                  return _LeadingDeleteReflowSection(
                    cardChildren: leadingDeleteChildren,
                    cardWidth: cardWidth,
                    progress: leadingDeleteProgress,
                    deleteIndex: _pendingLeadingDeleteIndex!,
                  );
                }

                final tailIndex = index - 1;
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: bankCardVerticalSpacing,
                  ),
                  child: _buildCardItem(deleteTailCards[tailIndex]),
                );
              }

              if (index == 0) {
                return _IncomingCardPlaceholder(
                  slotKey: _incomingCardSlotKey,
                  progress: incomingPreparationProgress,
                  cardHeight: cardHeight,
                  child: _pendingIncomingCard == null
                      ? null
                      : _buildCardItem(_pendingIncomingCard!),
                );
              }

              if (preparingIncomingStack) {
                if (index == 1) {
                  return _IncomingTopReflowSection(
                    cardChildren: reflowChildren,
                    cardWidth: cardWidth,
                    progress: incomingPreparationProgress,
                  );
                }

                final tailIndex = index - 2;
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: bankCardVerticalSpacing,
                  ),
                  child: _buildCardItem(tailCards[tailIndex]),
                );
              }

              final contentIndex = index - 1;

              if (contentIndex < leadingCards.length) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: bankCardVerticalSpacing,
                  ),
                  child: _buildCardItem(leadingCards[contentIndex]),
                );
              }

              if (hasStackPreview && contentIndex == leadingCards.length) {
                return _StackedCardListSection(
                  cards: stackPreviewCards,
                  cardChildren: stackPreviewChildren,
                  cardWidth: cardWidth,
                  revealedCardId: _effectiveRevealedCardId,
                  scrollController: _scrollController,
                  cardIdBuilder: _cardId,
                );
              }

              final tailIndex =
                  contentIndex -
                      leadingCards.length -
                      (hasStackPreview ? 1 : 0);
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: bankCardVerticalSpacing,
                ),
                child: _buildCardItem(tailCards[tailIndex]),
              );
            },
          );
        }

        const spacing = AdaptiveLayout.cardPaneSpacing;
        final contentWidth = (AdaptiveLayout.phoneCardWidth * paneCount) +
            (spacing * (paneCount - 1));
        const cardWidth = AdaptiveLayout.phoneCardWidth;
        _scheduleCustomImagePrecache(visibleCards, cardWidth: cardWidth);

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
    final hasIncomingPlaceholder = _pendingIncomingCard != null;
    final cardArea = isEmptyState
        ? EmptyWalletView(isDark: widget.isDark)
        : visibleCards.isEmpty && !hasIncomingPlaceholder
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
                      SvgPicture.asset(
                        'assets/images/logo_44.svg',
                        width: 42,
                        height: 42,
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
          if (!isEmptyState && allCards.isNotEmpty) ...[
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
        final bool isEmptyState =
            allCards.isEmpty && _pendingIncomingCard == null;
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
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endFloat,
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

    return const SizedBox.shrink();
  }
}

class _StackedCardListSection extends StatelessWidget {
  static const Curve _stackSettleCurve = Cubic(0.22, 1, 0.36, 1);
  static const double _cardTiltPadding = 8;
  static const double _collapsedScaleStep = 0.045;
  static const double _interactionEnableProgress = 0.9;
  static const double _fullyExpandedProgress = 0.999;
  static const int _maxCollapsedDepth = 4;
  static const int _visibleCollapsedCards = 4;
  static const List<double> _collapsedTopOffsets = <double>[
    64,
    30,
    12,
    0,
  ];

  final List<CardData> cards;
  final List<Widget> cardChildren;
  final double cardWidth;
  final String? revealedCardId;
  final ScrollController scrollController;
  final String Function(CardData card) cardIdBuilder;

  const _StackedCardListSection({
    required this.cards,
    required this.cardChildren,
    required this.cardWidth,
    required this.revealedCardId,
    required this.scrollController,
    required this.cardIdBuilder,
  });

  double _lerp(double from, double to, double progress) {
    return from + ((to - from) * progress);
  }

  @override
  Widget build(BuildContext context) {
    final cardHeight = cardWidth * (cardAspectRatioHeight / cardAspectRatioWidth);
    final itemHeight = cardHeight + _cardTiltPadding;
    const itemGap = bankCardVerticalSpacing;
    final slotHeight = itemHeight + itemGap;
    final revealedIndex = cards.indexWhere(
      (card) => cardIdBuilder(card) == revealedCardId,
    );
    final revealExtraHeight = revealedIndex == -1 ? 0.0 : secureRevealBarHeight;
    final sectionHeight = (cards.length * slotHeight) + revealExtraHeight;
    final maxDepth = (cards.length - 1).clamp(1, _maxCollapsedDepth);

    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, _) {
        final scrollOffset =
            scrollController.hasClients ? scrollController.offset : 0.0;
        final progress = _stackSettleCurve.transform(
          (scrollOffset / (cardHeight * 0.84)).clamp(0.0, 1.0).toDouble(),
        );

        if (progress >= _fullyExpandedProgress) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final child in cardChildren)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: bankCardVerticalSpacing,
                  ),
                  child: child,
                ),
            ],
          );
        }

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
                    revealExtraHeight: revealExtraHeight,
                    revealedIndex: revealedIndex,
                    progress: progress,
                  ),
                  scale: _scaleForIndex(
                    index: index,
                    maxDepth: maxDepth,
                    progress: progress,
                  ),
                  opacity: _opacityForIndex(index: index, progress: progress),
                  interactionsEnabled: progress >= _interactionEnableProgress,
                  child: cardChildren[index],
                ),
            ],
          ),
        );
      },
    );
  }

  double _topForIndex({
    required int index,
    required int maxDepth,
    required double slotHeight,
    required double revealExtraHeight,
    required int revealedIndex,
    required double progress,
  }) {
    final collapsedTop = _collapsedTopForIndex(
      index,
      totalCards: cards.length,
    );
    final expandedTop = (index * slotHeight) +
        (revealedIndex != -1 && index > revealedIndex ? revealExtraHeight : 0);

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

  double _collapsedTopForIndex(
    int index, {
    required int totalCards,
  }) {
    final visibleCollapsedCount =
        totalCards.clamp(1, _collapsedTopOffsets.length);
    final anchorTop = _collapsedTopOffsets[visibleCollapsedCount - 1];
    final rawTop = index < _collapsedTopOffsets.length
        ? _collapsedTopOffsets[index]
        : _collapsedTopOffsets.last;

    return rawTop - anchorTop;
  }

  double _opacityForIndex({
    required int index,
    required double progress,
  }) {
    final collapsedOpacity = index < _visibleCollapsedCards ? 1.0 : 0.0;
    return _lerp(collapsedOpacity, 1, progress);
  }
}

class _IncomingTopReflowSection extends StatelessWidget {
  final List<Widget> cardChildren;
  final double cardWidth;
  final double progress;

  const _IncomingTopReflowSection({
    required this.cardChildren,
    required this.cardWidth,
    required this.progress,
  });

  static const Curve _curve = Cubic(0.18, 0.88, 0.24, 1);

  double _lerp(double from, double to, double t) => from + ((to - from) * t);
  double _arc(double t, double magnitude) => -(4 * t * (1 - t) * magnitude);
  double _drift(double t, double magnitude) => 4 * t * (1 - t) * magnitude;

  double _phase(double begin, double end, {Curve curve = _curve}) {
    return Interval(begin, end, curve: curve).transform(progress);
  }

  double _collapsedTopForStackIndex(int index) {
    const offsets = _StackedCardListSection._collapsedTopOffsets;
    const anchorTop = 0.0;
    final rawTop = index < offsets.length ? offsets[index] : offsets.last;
    return rawTop - anchorTop;
  }

  double _collapsedScaleForStackIndex(int index) {
    final collapsedDepth =
        index.clamp(0, _StackedCardListSection._maxCollapsedDepth);
    return 1 - (_StackedCardListSection._collapsedScaleStep * collapsedDepth);
  }

  @override
  Widget build(BuildContext context) {
    if (cardChildren.length < 6) {
      return const SizedBox.shrink();
    }

    final cardHeight = cardWidth * (cardAspectRatioHeight / cardAspectRatioWidth);
    final itemHeight = cardHeight + _StackedCardListSection._cardTiltPadding;
    const itemGap = bankCardVerticalSpacing;
    final slotHeight = itemHeight + itemGap;
    final sectionHeight = slotHeight * 6;

    return SizedBox(
      height: sectionHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          () {
            final t = _phase(0.04, 0.82);
            return _buildReflowCard(
              child: cardChildren[5],
              top: _lerp(
                (slotHeight * 2) + _collapsedTopForStackIndex(3),
                slotHeight * 5,
                t,
              ),
              scale: _lerp(
                _collapsedScaleForStackIndex(3),
                1.0,
                t,
              ),
              opacity: _lerp(1.0, 0.97, t),
              translateX: _drift(t, 10),
              translateY: _arc(t, 8),
            );
          }(),
          () {
            final t = _phase(0.08, 0.86);
            return _buildReflowCard(
              child: cardChildren[4],
              top: _lerp(
                (slotHeight * 2) + _collapsedTopForStackIndex(2),
                slotHeight + _collapsedTopForStackIndex(3),
                t,
              ),
              scale: _lerp(
                _collapsedScaleForStackIndex(2),
                _collapsedScaleForStackIndex(3),
                t,
              ),
              translateX: _drift(t, 5),
              translateY: _arc(t, 10),
            );
          }(),
          () {
            final t = _phase(0.1, 0.88);
            return _buildReflowCard(
              child: cardChildren[3],
              top: _lerp(
                (slotHeight * 2) + _collapsedTopForStackIndex(1),
                slotHeight + _collapsedTopForStackIndex(2),
                t,
              ),
              scale: _lerp(
                _collapsedScaleForStackIndex(1),
                _collapsedScaleForStackIndex(2),
                t,
              ),
              translateX: _drift(t, -4),
              translateY: _arc(t, 10),
            );
          }(),
          () {
            final t = _phase(0.12, 0.9);
            return _buildReflowCard(
              child: cardChildren[2],
              top: _lerp(
                (slotHeight * 2) + _collapsedTopForStackIndex(0),
                slotHeight + _collapsedTopForStackIndex(1),
                t,
              ),
              scale: _lerp(
                _collapsedScaleForStackIndex(0),
                _collapsedScaleForStackIndex(1),
                t,
              ),
              translateX: _drift(t, 3),
              translateY: _arc(t, 12),
            );
          }(),
          () {
            final t = _phase(
              0.04,
              0.88,
              curve: const Cubic(0.16, 1, 0.22, 1),
            );
            return _buildReflowCard(
              child: cardChildren[1],
              top: _lerp(
                slotHeight,
                slotHeight + _collapsedTopForStackIndex(0),
                t,
              ),
              scale: _lerp(1.0, _collapsedScaleForStackIndex(0), t),
              opacity: _lerp(1.0, 0.985, t),
              translateX: _drift(t, -8),
              translateY: _arc(t, 18),
            );
          }(),
          () {
            final t = _phase(
              0.0,
              0.84,
              curve: const Cubic(0.2, 0.96, 0.24, 1),
            );
            return _buildReflowCard(
              child: cardChildren[0],
              top: 0,
              scale: _lerp(1.0, 0.992, t),
              translateY: _arc(t, 4),
            );
          }(),
        ],
      ),
    );
  }

  Widget _buildReflowCard({
    required Widget child,
    required double top,
    double scale = 1,
    double opacity = 1,
    double translateX = 0,
    double translateY = 0,
  }) {
    return _StackedCardPosition(
      top: top,
      scale: scale,
      opacity: opacity,
      translateX: translateX,
      translateY: translateY,
      interactionsEnabled: false,
      child: child,
    );
  }
}

class _LeadingDeleteReflowSection extends StatelessWidget {
  final List<Widget> cardChildren;
  final double cardWidth;
  final double progress;
  final int deleteIndex;

  const _LeadingDeleteReflowSection({
    required this.cardChildren,
    required this.cardWidth,
    required this.progress,
    required this.deleteIndex,
  });

  static const Curve _curve = Cubic(0.18, 0.88, 0.24, 1);

  double _lerp(double from, double to, double t) => from + ((to - from) * t);
  double _arc(double t, double magnitude) => -(4 * t * (1 - t) * magnitude);
  double _drift(double t, double magnitude) => 4 * t * (1 - t) * magnitude;

  double _phase(double begin, double end, {Curve curve = _curve}) {
    return Interval(begin, end, curve: curve).transform(progress);
  }

  double _collapsedTopForStackIndex(int index) {
    const offsets = _StackedCardListSection._collapsedTopOffsets;
    return index < offsets.length ? offsets[index] : offsets.last;
  }

  double _collapsedScaleForStackIndex(int index) {
    final collapsedDepth =
        index.clamp(0, _StackedCardListSection._maxCollapsedDepth);
    return 1 - (_StackedCardListSection._collapsedScaleStep * collapsedDepth);
  }

  Widget _buildTransitionCard({
    required Widget child,
    required double startTop,
    required double endTop,
    double startScale = 1,
    double endScale = 1,
    required double progress,
    double driftMagnitude = 0,
    double arcMagnitude = 0,
    bool driftLeft = false,
  }) {
    return _StackedCardPosition(
      top: _lerp(startTop, endTop, progress),
      scale: _lerp(startScale, endScale, progress),
      opacity: 1,
      translateX: _drift(progress, driftLeft ? -driftMagnitude : driftMagnitude),
      translateY: _arc(progress, arcMagnitude),
      interactionsEnabled: false,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cardChildren.length < 7 || deleteIndex > 1) {
      return const SizedBox.shrink();
    }

    final cardHeight = cardWidth * (cardAspectRatioHeight / cardAspectRatioWidth);
    final itemHeight = cardHeight + _StackedCardListSection._cardTiltPadding;
    const itemGap = bankCardVerticalSpacing;
    final slotHeight = itemHeight + itemGap;
    final sectionHeight = slotHeight * 6;
    const topRow = 0.0;
    final secondRow = slotHeight;
    final stack0 = (slotHeight * 2) + _collapsedTopForStackIndex(0);
    final stack1 = (slotHeight * 2) + _collapsedTopForStackIndex(1);
    final stack2 = (slotHeight * 2) + _collapsedTopForStackIndex(2);
    final stack3 = (slotHeight * 2) + _collapsedTopForStackIndex(3);
    final tailRow = slotHeight * 6;

    final topMotion = _phase(
      0.34,
      0.94,
      curve: const Cubic(0.2, 0.96, 0.24, 1),
    );
    final rowToRowMotion = _phase(
      0.38,
      0.96,
      curve: const Cubic(0.16, 1, 0.22, 1),
    );
    final stack0Motion = _phase(0.42, 0.98);
    final stack1Motion = _phase(0.4, 0.96);
    final stack2Motion = _phase(0.38, 0.94);
    final tailMotion = _phase(
      0.34,
      0.9,
      curve: const Cubic(0.16, 1, 0.22, 1),
    );
    final deletedExit = _phase(0.0, 0.28, curve: const Cubic(0.22, 1, 0.36, 1));
    final messageOpacity = _phase(0.16, 0.46);

    return SizedBox(
      height: sectionHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (deleteIndex == 0) ...[
            _buildTransitionCard(
              child: cardChildren[6],
              startTop: tailRow,
              endTop: stack3,
              startScale: 1,
              endScale: _collapsedScaleForStackIndex(3),
              progress: tailMotion,
              driftMagnitude: 10,
              arcMagnitude: 8,
              driftLeft: true,
            ),
            _buildTransitionCard(
              child: cardChildren[5],
              startTop: stack3,
              endTop: stack2,
              startScale: _collapsedScaleForStackIndex(3),
              endScale: _collapsedScaleForStackIndex(2),
              progress: stack2Motion,
              driftMagnitude: 5,
              arcMagnitude: 10,
              driftLeft: true,
            ),
            _buildTransitionCard(
              child: cardChildren[4],
              startTop: stack2,
              endTop: stack1,
              startScale: _collapsedScaleForStackIndex(2),
              endScale: _collapsedScaleForStackIndex(1),
              progress: stack1Motion,
              driftMagnitude: 4,
              arcMagnitude: 10,
            ),
            _buildTransitionCard(
              child: cardChildren[3],
              startTop: stack1,
              endTop: stack0,
              startScale: _collapsedScaleForStackIndex(1),
              endScale: _collapsedScaleForStackIndex(0),
              progress: stack0Motion,
              driftMagnitude: 3,
              arcMagnitude: 12,
              driftLeft: true,
            ),
            _buildTransitionCard(
              child: cardChildren[2],
              startTop: stack0,
              endTop: secondRow,
              startScale: _collapsedScaleForStackIndex(0),
              endScale: 1,
              progress: rowToRowMotion,
              driftMagnitude: 8,
              arcMagnitude: 18,
            ),
            _buildTransitionCard(
              child: cardChildren[1],
              startTop: secondRow,
              endTop: topRow,
              progress: topMotion,
              driftMagnitude: 6,
              arcMagnitude: 12,
              driftLeft: true,
            ),
          ] else ...[
            _buildTransitionCard(
              child: cardChildren[6],
              startTop: tailRow,
              endTop: stack3,
              startScale: 1,
              endScale: _collapsedScaleForStackIndex(3),
              progress: tailMotion,
              driftMagnitude: 10,
              arcMagnitude: 8,
              driftLeft: true,
            ),
            _buildTransitionCard(
              child: cardChildren[5],
              startTop: stack3,
              endTop: stack2,
              startScale: _collapsedScaleForStackIndex(3),
              endScale: _collapsedScaleForStackIndex(2),
              progress: stack2Motion,
              driftMagnitude: 5,
              arcMagnitude: 10,
              driftLeft: true,
            ),
            _buildTransitionCard(
              child: cardChildren[4],
              startTop: stack2,
              endTop: stack1,
              startScale: _collapsedScaleForStackIndex(2),
              endScale: _collapsedScaleForStackIndex(1),
              progress: stack1Motion,
              driftMagnitude: 4,
              arcMagnitude: 10,
            ),
            _buildTransitionCard(
              child: cardChildren[3],
              startTop: stack1,
              endTop: stack0,
              startScale: _collapsedScaleForStackIndex(1),
              endScale: _collapsedScaleForStackIndex(0),
              progress: stack0Motion,
              driftMagnitude: 3,
              arcMagnitude: 12,
              driftLeft: true,
            ),
            _buildTransitionCard(
              child: cardChildren[2],
              startTop: stack0,
              endTop: secondRow,
              startScale: _collapsedScaleForStackIndex(0),
              endScale: 1,
              progress: rowToRowMotion,
              driftMagnitude: 8,
              arcMagnitude: 18,
            ),
            _buildTransitionCard(
              child: cardChildren[0],
              startTop: topRow,
              endTop: topRow,
              startScale: 0.992,
              endScale: 1,
              progress: topMotion,
              driftMagnitude: 0,
              arcMagnitude: 4,
            ),
          ],
          Positioned(
            top: deleteIndex == 0 ? topRow : secondRow,
            left: 0,
            right: 0,
            child: SizedBox(
              height: itemHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: messageOpacity,
                    child: const _DeletedRowMessage(),
                  ),
                  Transform.translate(
                    offset: Offset(-(cardWidth + 48) * deletedExit, 0),
                    child: cardChildren[deleteIndex],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeletedRowMessage extends StatelessWidget {
  const _DeletedRowMessage();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = SwalletPalette(isDark);

    return Text(
      'Card deleted',
      textAlign: TextAlign.center,
      style: SwalletText.title.copyWith(
        color: palette.text,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _IncomingCardPlaceholder extends StatelessWidget {
  final GlobalKey slotKey;
  final double progress;
  final double cardHeight;
  final Widget? child;

  const _IncomingCardPlaceholder({
    required this.slotKey,
    required this.progress,
    required this.cardHeight,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final rowExtent =
        cardHeight + _StackedCardListSection._cardTiltPadding + bankCardVerticalSpacing;
    final motionProgress = const Interval(
      0.0,
      0.94,
      curve: Cubic(0.18, 0.88, 0.24, 1),
    ).transform(progress);
    final occupiedHeight = rowExtent * motionProgress;
    final travelDistance = rowExtent;
    final translateY = -travelDistance * (1 - motionProgress);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          key: slotKey,
          width: double.infinity,
          height: 0,
        ),
        SizedBox(
          height: occupiedHeight,
          child: child == null
              ? null
              : ClipRect(
                  child: Transform.translate(
                    offset: Offset(0, translateY),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: bankCardVerticalSpacing,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _StackedCardPosition extends StatelessWidget {
  final double top;
  final double scale;
  final double opacity;
  final double translateX;
  final double translateY;
  final bool interactionsEnabled;
  final Widget child;

  const _StackedCardPosition({
    required this.top,
    required this.scale,
    required this.opacity,
    this.translateX = 0,
    this.translateY = 0,
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
          child: Transform.translate(
            offset: Offset(translateX, translateY),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topCenter,
              child: child,
            ),
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
  final bool isDeleting;
  final VoidCallback onSwipeStarted;
  final VoidCallback onSwipeClosed;
  final VoidCallback onEdit;
  final Future<void> Function() onDeleteConfirmed;

  const _SwipeableCardActions({
    required this.child,
    required this.isDark,
    required this.cardId,
    required this.activeSwipeCardId,
    required this.resetToken,
    required this.isDeleting,
    required this.onSwipeStarted,
    required this.onSwipeClosed,
    required this.onEdit,
    required this.onDeleteConfirmed,
  });

  @override
  State<_SwipeableCardActions> createState() => _SwipeableCardActionsState();
}

class _SwipeableCardActionsState extends State<_SwipeableCardActions> {
  static const double _buttonSize = 52;
  static const double _buttonGap = 8;
  static const double _buttonInset = 12;
  static const double _cardActionGap = 12;
  static const double _actionPanelWidth =
      _buttonInset + (_buttonSize * 2) + _buttonGap;
  static const double _confirmPanelWidth = 236;
  static const Duration _snapDuration = Duration(milliseconds: 220);

  double _dragOffset = 0;
  bool _isDragging = false;
  bool _confirmingDelete = false;

  double get _panelWidth =>
      _confirmingDelete ? _confirmPanelWidth : _actionPanelWidth;

  double get _revealWidth =>
      (_confirmingDelete ? _confirmPanelWidth : _actionPanelWidth) +
      _cardActionGap;

  bool get _isOpen => _dragOffset <= -_revealWidth * 0.45;

  @override
  void didUpdateWidget(covariant _SwipeableCardActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resetToken != oldWidget.resetToken && _dragOffset != 0) {
      _dragOffset = 0;
      _isDragging = false;
      _confirmingDelete = false;
    }
    if (widget.activeSwipeCardId != oldWidget.activeSwipeCardId &&
        widget.activeSwipeCardId != widget.cardId &&
        _dragOffset != 0) {
      _dragOffset = 0;
      _isDragging = false;
      _confirmingDelete = false;
    }
    if (widget.isDeleting && !oldWidget.isDeleting) {
      _isDragging = false;
    }
  }

  void _handleDragStart(DragStartDetails details) {
    widget.onSwipeStarted();
    setState(() => _isDragging = true);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dx).clamp(-_revealWidth, 0.0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final shouldOpen = velocity < -220 || (velocity <= 220 && _isOpen);

    setState(() {
      _isDragging = false;
      _dragOffset = shouldOpen ? -_revealWidth : 0;
      if (!shouldOpen) {
        _confirmingDelete = false;
      }
    });
    if (!shouldOpen) {
      widget.onSwipeClosed();
    }
  }

  void _handleDragCancel() {
    setState(() {
      _isDragging = false;
      _dragOffset = 0;
      _confirmingDelete = false;
    });
    widget.onSwipeClosed();
  }

  void _closeAndRun(VoidCallback action) {
    setState(() {
      _dragOffset = 0;
      _confirmingDelete = false;
    });
    widget.onSwipeClosed();
    action();
  }

  void _showInlineDeleteConfirmation() {
    setState(() {
      _confirmingDelete = true;
      _dragOffset = -_revealWidth;
      _isDragging = false;
    });
  }

  Future<void> _confirmDelete() async {
    await widget.onDeleteConfirmed();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (-_dragOffset / _revealWidth).clamp(0.0, 1.0);
    final scale = 1.0 - (0.035 * progress);
    final revealedWidth = (-_dragOffset).clamp(0.0, _revealWidth);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerRight,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: widget.isDeleting ? null : _handleDragStart,
          onHorizontalDragUpdate: widget.isDeleting ? null : _handleDragUpdate,
          onHorizontalDragEnd: widget.isDeleting ? null : _handleDragEnd,
          onHorizontalDragCancel: widget.isDeleting ? null : _handleDragCancel,
          child: AnimatedContainer(
            duration: _isDragging ? Duration.zero : _snapDuration,
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..translateByDouble(_dragOffset, 0, 0, 1)
              ..scaleByDouble(scale, scale, 1, 1),
            transformAlignment: Alignment.center,
            child: widget.child,
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: revealedWidth == 0,
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: revealedWidth,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedContainer(
                      duration: _snapDuration,
                      curve: Curves.easeOutCubic,
                      width: _panelWidth,
                      alignment: Alignment.centerRight,
                      child: _confirmingDelete
                          ? _InlineDeleteConfirmation(
                              isDark: widget.isDark,
                              onCancel: () {
                                setState(() {
                                  _confirmingDelete = false;
                                  _dragOffset =
                                      -(_actionPanelWidth + _cardActionGap);
                                });
                              },
                              onConfirm: _confirmDelete,
                            )
                          : SizedBox(
                              width: _actionPanelWidth,
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
                                    onTap: _showInlineDeleteConfirmation,
                                  ),
                                  const SizedBox(width: _buttonInset),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineDeleteConfirmation extends StatelessWidget {
  final bool isDark;
  final VoidCallback onCancel;
  final Future<void> Function() onConfirm;

  const _InlineDeleteConfirmation({
    required this.isDark,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final palette = SwalletPalette(isDark);

    return SizedBox(
      width: double.infinity,
      child: SizedBox(
        height: 108,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Delete this card?',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: SwalletText.section.copyWith(color: palette.text),
              ),
              const SizedBox(height: 6),
              Text(
                'This action is permanent and cannot be undone.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: SwalletText.caption.copyWith(
                  color: palette.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: Material(
                        color: palette.surfaceHigh,
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: onCancel,
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: Material(
                        color: SwalletColors.destructive,
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: onConfirm,
                          child: Center(
                            child: Text(
                              'Delete card',
                              style: SwalletText.button.copyWith(
                                fontWeight: FontWeight.w500,
                                color: palette.onPrimary,
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
