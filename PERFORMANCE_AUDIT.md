# Performance Audit: Swallet Flutter Project

Scope: code inspection of the Flutter project with emphasis on `HomeScreen` scrolling when 10+ cards are present. No source files were modified.

## Executive Summary

The main scrolling bottleneck is structural, not a single expensive widget. Once `HomeScreen` has more than 3 cards, it stops using a virtualized list for most cards and instead builds cards `2..N` inside one `_StackedCardListSection` `Stack`, driven by an `AnimatedBuilder` tied directly to the `ScrollController` ([lib/screens/home_screen.dart:737-790](lib/screens/home_screen.dart:737), [lib/screens/home_screen.dart:1187-1316](lib/screens/home_screen.dart:1187)). That means scroll ticks rebuild and relayout many card widgets that a normal sliver list would keep off-screen.

Each visible bank card is also paint-heavy. A standard card can include a bank logo SVG, a network SVG, a chip SVG, one pattern SVG painted 4 times with `Opacity`/`ShaderMask`/`ColorFiltered`, plus a grain `CustomPainter` loop and a blurred shadow ([lib/widgets/card/bank_card.dart:130-258](lib/widgets/card/bank_card.dart:130), [lib/widgets/card/card_visual_asset_layer.dart:26-99](lib/widgets/card/card_visual_asset_layer.dart:26), [lib/widgets/card/card_visual_asset_layer.dart:218-282](lib/widgets/card/card_visual_asset_layer.dart:218)). On top of that, there is no `RepaintBoundary` around the full card row, only around the pattern layer.

The top 3 issues most likely causing lag are:

1. Scroll-driven full subtree rebuilds in compact mode.
2. Non-virtualized stacked rendering for cards after index 1.
3. Very expensive SVG/painter layering per card, especially with heavy pattern assets.

## 1. Widget Rebuild Analysis

### HomeScreen rebuild propagation

State flow for the hot path:

`Hive.box(cards).listenable()` -> `ValueListenableBuilder` -> `HomeScreen.build` -> `_buildAdaptiveBody` -> `_buildHomeContent` -> `_buildCardsLayout` -> `_buildCardItem` -> `SecureRevealWrapper` -> `BankCard` ([lib/screens/home_screen.dart:1025-1068](lib/screens/home_screen.dart:1025), [lib/screens/home_screen.dart:889-994](lib/screens/home_screen.dart:889), [lib/screens/home_screen.dart:725-827](lib/screens/home_screen.dart:725), [lib/screens/home_screen.dart:558-624](lib/screens/home_screen.dart:558)).

`HomeScreenState` has broad `setState` usage for reveal, filtering, side pane transitions, swipe state, delete animation, unlock settle, and FAB collapse ([lib/screens/home_screen.dart:91-109](lib/screens/home_screen.dart:91), [lib/screens/home_screen.dart:120-139](lib/screens/home_screen.dart:120), [lib/screens/home_screen.dart:155-159](lib/screens/home_screen.dart:155), [lib/screens/home_screen.dart:192-199](lib/screens/home_screen.dart:192), [lib/screens/home_screen.dart:413](lib/screens/home_screen.dart:413), [lib/screens/home_screen.dart:436](lib/screens/home_screen.dart:436), [lib/screens/home_screen.dart:479-527](lib/screens/home_screen.dart:479), [lib/screens/home_screen.dart:572-576](lib/screens/home_screen.dart:572), [lib/screens/home_screen.dart:671-688](lib/screens/home_screen.dart:671), [lib/screens/home_screen.dart:692-718](lib/screens/home_screen.dart:692), [lib/screens/home_screen.dart:978-982](lib/screens/home_screen.dart:978)).

### Excessive rebuild findings

- Critical: compact `HomeScreen` ties the entire card area to `AnimatedBuilder(animation: _scrollController)`, so scroll ticks rebuild the list subtree every frame instead of letting the scroll view paint existing children ([lib/screens/home_screen.dart:737-790](lib/screens/home_screen.dart:737)).
- Critical: in the `visibleCards.length > 3` branch, cards after the first two are all rebuilt through `_StackedCardListSection` on every scroll tick ([lib/screens/home_screen.dart:761-786](lib/screens/home_screen.dart:761), [lib/screens/home_screen.dart:1242-1260](lib/screens/home_screen.dart:1242)).
- High: `SecureRevealWrapper` attaches a scroll listener per card instance, so every scroll event fans out to every card wrapper even when the card is not revealed ([lib/widgets/card/secure_reveal_wrapper.dart:67-76](lib/widgets/card/secure_reveal_wrapper.dart:67), [lib/widgets/card/secure_reveal_wrapper.dart:105-121](lib/widgets/card/secure_reveal_wrapper.dart:105)).
- High: revealing or locking one card updates `_revealedCardId` in `HomeScreen`, which rebuilds the full `HomeScreen` card list instead of just the active card ([lib/screens/home_screen.dart:475-528](lib/screens/home_screen.dart:475), [lib/screens/home_screen.dart:530-539](lib/screens/home_screen.dart:530)).
- High: swipe-open state is stored in `HomeScreen` via `_activeSwipeCardId`, so opening or closing one card's action rail rebuilds all card items ([lib/screens/home_screen.dart:565-577](lib/screens/home_screen.dart:565)).
- Medium: filter selection updates `_activeFilters` in `HomeScreen`, rebuilding the whole scaffold body and all cards ([lib/screens/home_screen.dart:972-984](lib/screens/home_screen.dart:972)).
- Medium: delete flow mutates `_deletingCardIds` and `_cards` with parent `setState`, rebuilding the list during the delete animation ([lib/screens/home_screen.dart:696-719](lib/screens/home_screen.dart:696)).

### Const constructor audit

No major hot-path custom widgets are missing `const` constructors. `HomeScreen`, `BankCard`, `CardDetailsBlock`, `BankLogo`, `SecureRevealWrapper`, `CardVisualAssetLayer`, `TopNavBar`, `FilterChipItem`, `AnimatedAddCardButton`, and `ThemeLottieToggle` already expose `const` constructors ([lib/screens/home_screen.dart:44-49](lib/screens/home_screen.dart:44), [lib/widgets/card/bank_card.dart:37-58](lib/widgets/card/bank_card.dart:37), [lib/widgets/card/card_details_block.dart:18-28](lib/widgets/card/card_details_block.dart:18), [lib/widgets/bank/bank_logo.dart:17-25](lib/widgets/bank/bank_logo.dart:17), [lib/widgets/card/secure_reveal_wrapper.dart:13-18](lib/widgets/card/secure_reveal_wrapper.dart:13), [lib/widgets/card/card_visual_asset_layer.dart:10-14](lib/widgets/card/card_visual_asset_layer.dart:10), [lib/widgets/top_nav/top_nav_bar.dart:31-37](lib/widgets/top_nav/top_nav_bar.dart:31), [lib/widgets/top_nav/filter_chip.dart:16-24](lib/widgets/top_nav/filter_chip.dart:16), [lib/widgets/buttons/animated_add_card_button.dart:13-17](lib/widgets/buttons/animated_add_card_button.dart:13), [lib/widgets/buttons/theme_lottie_toggle.dart:10-14](lib/widgets/buttons/theme_lottie_toggle.dart:10)).

This means `const` is not the main problem here. The cost is coming from parent rebuild breadth and dynamic object creation inside `build`.

### Large widget trees rebuilt by broad setState

- `HomeScreen.setState` rebuilds header, top nav, FAB stage, and card list together ([lib/screens/home_screen.dart:1025-1068](lib/screens/home_screen.dart:1025)).
- `_buildCardItem` recreates `DeletingListItemWrapper`, `_SwipeableCardActions`, `SecureRevealWrapper`, `BankCard`, `Alignment`, `Color` objects, and share/reveal closures for each card on parent rebuilds ([lib/screens/home_screen.dart:558-624](lib/screens/home_screen.dart:558)).
- `BankCard` rebuild recreates `BoxDecoration`, `BoxShadow`, gradient resolution, custom image decoration, multiple positioned subtrees, and action widgets ([lib/widgets/card/bank_card.dart:71-262](lib/widgets/card/bank_card.dart:71)).

### Top 20 most expensive rebuild paths

| Rank | Rebuild path | Trigger | Estimated cost | Refs |
|---|---|---|---|---|
| 1 | `HomeScreen -> AnimatedBuilder(_scrollController) -> ListView/ListView(children)` | Every scroll tick in compact mode | Critical | [lib/screens/home_screen.dart:737-790](lib/screens/home_screen.dart:737) |
| 2 | `AnimatedBuilder -> _StackedCardListSection -> Stack(for all cards 2..N)` | Every scroll tick with >3 cards | Critical | [lib/screens/home_screen.dart:761-786](lib/screens/home_screen.dart:761), [lib/screens/home_screen.dart:1221-1263](lib/screens/home_screen.dart:1221) |
| 3 | `_StackedCardPosition(AnimatedPositioned)` for every stacked card | Every scroll tick with position changes | Critical | [lib/screens/home_screen.dart:1335-1352](lib/screens/home_screen.dart:1335) |
| 4 | `_buildCardItem -> SecureRevealWrapper -> BankCard` | Called per card from parent scroll rebuilds | Critical | [lib/screens/home_screen.dart:558-624](lib/screens/home_screen.dart:558) |
| 5 | `SecureRevealWrapper` scroll listener per card | Every scroll tick, once per card | High | [lib/widgets/card/secure_reveal_wrapper.dart:67-76](lib/widgets/card/secure_reveal_wrapper.dart:67), [lib/widgets/card/secure_reveal_wrapper.dart:105-121](lib/widgets/card/secure_reveal_wrapper.dart:105) |
| 6 | `HomeScreen.setState(_revealedCardId)` -> whole body rebuild | Reveal/auto-lock/tap eye | High | [lib/screens/home_screen.dart:479-527](lib/screens/home_screen.dart:479), [lib/screens/home_screen.dart:530-539](lib/screens/home_screen.dart:530) |
| 7 | `HomeScreen.setState(_activeSwipeCardId)` -> whole list rebuild | Swipe start/close | High | [lib/screens/home_screen.dart:570-577](lib/screens/home_screen.dart:570) |
| 8 | `_SwipeableCardActions.setState(_dragOffset)` | Every drag update on active card | High | [lib/screens/home_screen.dart:1418-1498](lib/screens/home_screen.dart:1418) |
| 9 | `BankCard -> CardVisualAssetLayer` | Any parent rebuild of a patterned card | High | [lib/widgets/card/bank_card.dart:147-154](lib/widgets/card/bank_card.dart:147), [lib/widgets/card/card_visual_asset_layer.dart:26-99](lib/widgets/card/card_visual_asset_layer.dart:26) |
| 10 | `SecureRevealWrapper AnimatedBuilder` | Reveal animation frames | High | [lib/widgets/card/secure_reveal_wrapper.dart:174-225](lib/widgets/card/secure_reveal_wrapper.dart:174) |
| 11 | `_CardActions` dual controllers per card | Card mount and reveal state changes | Medium-High | [lib/widgets/card/bank_card.dart:286-452](lib/widgets/card/bank_card.dart:286) |
| 12 | `CardDetailsBlock` subtree | Any card rebuild, plus CVV toggle | Medium-High | [lib/widgets/card/card_details_block.dart:76-223](lib/widgets/card/card_details_block.dart:76) |
| 13 | `BankLogo` asset/file resolution subtree | Any card rebuild | Medium-High | [lib/widgets/bank/bank_logo.dart:28-120](lib/widgets/bank/bank_logo.dart:28) |
| 14 | `HomeScreen.setState(_activeFilters)` | Chip toggle | Medium | [lib/screens/home_screen.dart:972-984](lib/screens/home_screen.dart:972) |
| 15 | `HomeScreen.setState(_deletingCardIds/_cards)` | Delete animation and completion | Medium | [lib/screens/home_screen.dart:696-719](lib/screens/home_screen.dart:696) |
| 16 | `HomeScreen.setState(_homeEntrySettled)` | Unlock settle status | Medium | [lib/screens/home_screen.dart:408-414](lib/screens/home_screen.dart:408) |
| 17 | `HomeScreen.setState(_fabCollapsed)` | Scroll threshold crossing | Medium | [lib/screens/home_screen.dart:433-438](lib/screens/home_screen.dart:433) |
| 18 | `TopNavBar -> FilterChipItem AnimatedBuilder` | Chip state animation | Low-Medium | [lib/widgets/top_nav/top_nav_bar.dart:121-145](lib/widgets/top_nav/top_nav_bar.dart:121), [lib/widgets/top_nav/filter_chip.dart:103-146](lib/widgets/top_nav/filter_chip.dart:103) |
| 19 | `AnimatedAddCardButton` | Collapsed/expanded FAB state change | Low | [lib/widgets/buttons/animated_add_card_button.dart:33-118](lib/widgets/buttons/animated_add_card_button.dart:33) |
| 20 | `ThemeLottieToggle` | Theme toggle animation | Low | [lib/widgets/buttons/theme_lottie_toggle.dart:65-103](lib/widgets/buttons/theme_lottie_toggle.dart:65) |

## 2. List Rendering Audit

### Findings

- Critical: `ListView.builder` is used only when `visibleCards.length <= 3` ([lib/screens/home_screen.dart:740-758](lib/screens/home_screen.dart:740)).
- Critical: once the list grows beyond 3 cards, the implementation switches to a plain `ListView(children: [...])`, not a builder or sliver-based list ([lib/screens/home_screen.dart:761-788](lib/screens/home_screen.dart:761)).
- Critical: cards after index 1 are packed into a single `_StackedCardListSection` child, which means the scroll view cannot virtualize or recycle them individually ([lib/screens/home_screen.dart:777-786](lib/screens/home_screen.dart:777), [lib/screens/home_screen.dart:1237-1263](lib/screens/home_screen.dart:1237)).
- High: in medium/expanded layouts, the screen uses `SingleChildScrollView` + `Wrap`, which fully lays out all cards and recalculates wrapping geometry on parent rebuilds ([lib/screens/home_screen.dart:799-824](lib/screens/home_screen.dart:799)).
- Medium: no `SliverList` or `CustomScrollView` is used in `HomeScreen`; there is no sliver-level virtualization path at all ([lib/screens/home_screen.dart:741-824](lib/screens/home_screen.dart:741)).
- Low: no `shrinkWrap: true` usage was found in `lib/`.
- Low: there is no `NestedScrollView` usage in `lib/`.

### SingleChildScrollView + Column / nested scroll patterns

- `HomeScreen` itself does not use a vertical `SingleChildScrollView + Column` for the compact card feed; it uses `ListView` in compact mode and `SingleChildScrollView + Wrap` for multi-pane mode ([lib/screens/home_screen.dart:741-824](lib/screens/home_screen.dart:741)).
- Horizontal top-nav scrolling is implemented with `SingleChildScrollView` + `Row` ([lib/widgets/top_nav/top_nav_bar.dart:100-150](lib/widgets/top_nav/top_nav_bar.dart:100)).
- Other screens contain `SingleChildScrollView` patterns, but they are not part of the home card scroll path: settings, app unlock, security setup, verification, and add-card bank selection ([lib/screens/settings/settings_screen.dart:180](lib/screens/settings/settings_screen.dart:180), [lib/screens/app_unlock/pin_lock_screen.dart:1462](lib/screens/app_unlock/pin_lock_screen.dart:1462), [lib/screens/app_unlock/security_setup_screen.dart:129](lib/screens/app_unlock/security_setup_screen.dart:129), [lib/screens/app_unlock/security_verification_screen.dart:143](lib/screens/app_unlock/security_verification_screen.dart:143), [lib/screens/add_card_flow/widgets/bank_selection_section.dart:319](lib/screens/add_card_flow/widgets/bank_selection_section.dart:319)).

### Full-list layout recalculation risks

- `_StackedCardListSection` recalculates `sectionHeight`, each card top, scale, and opacity on every scroll frame ([lib/screens/home_screen.dart:1221-1315](lib/screens/home_screen.dart:1221)).
- The medium/expanded `Wrap` path lays out all cards every time the parent rebuilds; `Wrap` is not incremental like a sliver list ([lib/screens/home_screen.dart:812-821](lib/screens/home_screen.dart:812)).

## 3. Paint & Raster Audit

### Expensive effects found

- `BackdropFilter` + `ImageFilter.blur` in app blur overlay: [lib/main.dart:255-269](lib/main.dart:255)
- `BackdropFilter` + `ImageFilter.blur` helper overlay: [lib/widgets/overlays/background_blur_overlay.dart:13-16](lib/widgets/overlays/background_blur_overlay.dart:13)
- `BackdropFilter` + `ImageFilter.blur` in add-card flow: [lib/screens/add_card_flow/add_card_flow_screen.dart:727-730](lib/screens/add_card_flow/add_card_flow_screen.dart:727)
- `BackdropFilter` + `ImageFilter.blur` background widget: [lib/screens/add_card_flow/widgets/add_card_background.dart:15-16](lib/screens/add_card_flow/widgets/add_card_background.dart:15)
- Multiple `Opacity` layers in card visuals and card actions: [lib/widgets/card/card_visual_asset_layer.dart:33-89](lib/widgets/card/card_visual_asset_layer.dart:33), [lib/widgets/card/bank_card.dart:372-447](lib/widgets/card/bank_card.dart:372), [lib/widgets/card/card_details_block.dart:185-205](lib/widgets/card/card_details_block.dart:185)
- `ShaderMask` in pattern layer: [lib/widgets/card/card_visual_asset_layer.dart:42-58](lib/widgets/card/card_visual_asset_layer.dart:42)
- `CustomPaint` premium texture painter: [lib/widgets/card/card_visual_asset_layer.dart:90-94](lib/widgets/card/card_visual_asset_layer.dart:90), [lib/widgets/card/card_visual_asset_layer.dart:218-282](lib/widgets/card/card_visual_asset_layer.dart:218)
- `CustomPaint` in lock/onboarding screens, not in home card scroll path: [lib/widgets/app_lock/security_features_intro_overlay.dart:590](lib/widgets/app_lock/security_features_intro_overlay.dart:590), [lib/widgets/app_lock/security_features_intro_overlay.dart:826](lib/widgets/app_lock/security_features_intro_overlay.dart:826), [lib/widgets/app_lock/security_features_intro_overlay.dart:855](lib/widgets/app_lock/security_features_intro_overlay.dart:855), [lib/screens/app_unlock/pin_lock_screen.dart:1274](lib/screens/app_unlock/pin_lock_screen.dart:1274), [lib/screens/app_unlock/pin_lock_screen.dart:1366](lib/screens/app_unlock/pin_lock_screen.dart:1366)

No `ClipPath` or `PhysicalModel` usages were found in `lib/`. `ClipRRect` is used in the card pattern layer ([lib/widgets/card/card_visual_asset_layer.dart:27-28](lib/widgets/card/card_visual_asset_layer.dart:27)).

### RepaintBoundary audit

- Present: `CardVisualAssetLayer` is wrapped in `RepaintBoundary` ([lib/widgets/card/card_visual_asset_layer.dart:26](lib/widgets/card/card_visual_asset_layer.dart:26)).
- Present: `FilterChipItem` is wrapped in `RepaintBoundary` ([lib/widgets/top_nav/filter_chip.dart:95](lib/widgets/top_nav/filter_chip.dart:95)).
- Missing around full cards: `DeletingListItemWrapper`, `_SwipeableCardActions`, `SecureRevealWrapper`, `BankCard`, and `BlackSecureCard` are not wrapped in a top-level `RepaintBoundary` ([lib/screens/home_screen.dart:562-623](lib/screens/home_screen.dart:562), [lib/widgets/card/secure_reveal_wrapper.dart:165-229](lib/widgets/card/secure_reveal_wrapper.dart:165), [lib/widgets/card/bank_card.dart:106-262](lib/widgets/card/bank_card.dart:106), [lib/widgets/card/black_secure_card.dart:23-71](lib/widgets/card/black_secure_card.dart:23)).

### Estimated repaint cost per card

| Card variant | Estimated repaint cost | Why |
|---|---|---|
| Standard patterned `BankCard` | High | Gradient + shadow + bank logo SVG + network SVG + chip SVG + 4 layered pattern SVG paints + grain `CustomPaint` ([lib/widgets/card/bank_card.dart:130-258](lib/widgets/card/bank_card.dart:130), [lib/widgets/card/card_visual_asset_layer.dart:26-99](lib/widgets/card/card_visual_asset_layer.dart:26)) |
| Custom-image `BankCard` | Medium-High | Avoids pattern layer but still paints image, shadow, bank logo, network logo, chip, details, actions ([lib/widgets/card/bank_card.dart:117-128](lib/widgets/card/bank_card.dart:117), [lib/widgets/card/bank_card.dart:130-258](lib/widgets/card/bank_card.dart:130)) |
| Revealed card | Very High during animation | Standard card + `BlackSecureCard` underneath + tilt transform + animated height changes ([lib/widgets/card/secure_reveal_wrapper.dart:174-225](lib/widgets/card/secure_reveal_wrapper.dart:174), [lib/widgets/card/black_secure_card.dart:23-71](lib/widgets/card/black_secure_card.dart:23)) |
| Swipe-active card | High during gesture | Card subtree transformed/scaled every drag update in `AnimatedContainer` ([lib/screens/home_screen.dart:1490-1498](lib/screens/home_screen.dart:1490)) |

Additional note: `_PremiumTexturePainter` uses a nested loop with a `4.5` pixel step and draws a subset of points as circles. At phone card size (`AdaptiveLayout.phoneCardWidth = 358`) this is roughly a few thousand loop iterations per repaint, before the SVG layers are counted ([lib/utils/adaptive_layout.dart:11-15](lib/utils/adaptive_layout.dart:11), [lib/widgets/card/card_visual_asset_layer.dart:258-277](lib/widgets/card/card_visual_asset_layer.dart:258)).

## 4. Animation Audit

### Project-wide animation usage relevant to the audit

- `AnimatedContainer`: [lib/screens/home_screen.dart:1490](lib/screens/home_screen.dart:1490), [lib/widgets/card/card_details_block.dart:242](lib/widgets/card/card_details_block.dart:242), [lib/widgets/buttons/animated_add_card_button.dart:50](lib/widgets/buttons/animated_add_card_button.dart:50), plus add-card and lock-screen usages outside home.
- `AnimatedOpacity`: [lib/widgets/card/card_details_block.dart:43](lib/widgets/card/card_details_block.dart:43), [lib/widgets/card/card_details_block.dart:185](lib/widgets/card/card_details_block.dart:185), [lib/widgets/animations/deleting_list_item_wrapper.dart:22](lib/widgets/animations/deleting_list_item_wrapper.dart:22).
- `AnimatedSwitcher`: [lib/widgets/card/bank_card.dart:388](lib/widgets/card/bank_card.dart:388), [lib/widgets/top_nav/top_nav_bar.dart:121](lib/widgets/top_nav/top_nav_bar.dart:121), [lib/main.dart:255](lib/main.dart:255).
- `AnimatedPositioned`: [lib/screens/home_screen.dart:1335](lib/screens/home_screen.dart:1335), add-card visual editor also uses it off-path.
- `AnimationController`: per-card in `SecureRevealWrapper` and `_CardActions`; per-chip in `FilterChipItem`; app-level unlock; theme toggle; various onboarding/lock flows ([lib/widgets/card/secure_reveal_wrapper.dart:40-47](lib/widgets/card/secure_reveal_wrapper.dart:40), [lib/widgets/card/bank_card.dart:304-322](lib/widgets/card/bank_card.dart:304), [lib/widgets/top_nav/filter_chip.dart:40-45](lib/widgets/top_nav/filter_chip.dart:40), [lib/main.dart:85-88](lib/main.dart:85), [lib/widgets/buttons/theme_lottie_toggle.dart:30-34](lib/widgets/buttons/theme_lottie_toggle.dart:30)).
- `Lottie.asset`: theme toggle on the home header, auth success, onboarding overlays. No Lottie is instantiated inside each home card item ([lib/widgets/buttons/theme_lottie_toggle.dart:91-98](lib/widgets/buttons/theme_lottie_toggle.dart:91), [lib/screens/app_unlock/app_unlock_screen.dart:125-126](lib/screens/app_unlock/app_unlock_screen.dart:125), [lib/widgets/app_lock/security_features_intro_overlay.dart:528](lib/widgets/app_lock/security_features_intro_overlay.dart:528)).
- No `Hero(` usage was found in `lib/`.

### Animations instantiated inside list items

- Yes: each `SecureRevealWrapper` card instance creates its own `AnimationController` ([lib/widgets/card/secure_reveal_wrapper.dart:40-47](lib/widgets/card/secure_reveal_wrapper.dart:40)).
- Yes: each `BankCard` action strip creates two `AnimationController`s (`_eyeController`, `_shareController`) ([lib/widgets/card/bank_card.dart:294-322](lib/widgets/card/bank_card.dart:294)).
- Yes: stacked cards use `AnimatedPositioned` even though their target `top` changes as part of scroll-driven state ([lib/screens/home_screen.dart:1335-1352](lib/screens/home_screen.dart:1335)).

### Off-screen animation risk

- High: cards after the first two are kept alive inside one `Stack`, so off-screen cards remain built and participate in transforms and opacity calculations ([lib/screens/home_screen.dart:1237-1263](lib/screens/home_screen.dart:1237)).
- Medium: `_CardActions` runs entrance animation on every mounted card through `_startEyeEntrance()`, including cards mounted in the stacked section before they are truly needed on screen ([lib/widgets/card/bank_card.dart:323-359](lib/widgets/card/bank_card.dart:323)).
- Low: the home header `ThemeLottieToggle` exists on screen but does not auto-repeat; it should not be a major scroll offender ([lib/widgets/buttons/theme_lottie_toggle.dart:91-98](lib/widgets/buttons/theme_lottie_toggle.dart:91)).

## 5. SVG & Asset Audit

### SVG assets used by visible card widgets

Home card widgets can use:

- Bank logo assets from `BankAssetResolver.logoPath()` rendered through `BankLogo` as `SvgPicture.asset`, `SvgPicture.file`, `Image.asset`, or `Image.file` depending on extension ([lib/utils/bank_asset_resolver.dart:144-162](lib/utils/bank_asset_resolver.dart:144), [lib/widgets/bank/bank_logo.dart:33-79](lib/widgets/bank/bank_logo.dart:33)).
- Network SVGs: `visa.svg`, `mastercard.svg`, `rupay.svg`, `amex.svg` ([lib/models/card_network.dart:22-35](lib/models/card_network.dart:22)).
- Chip SVG: `assets/images/chip.svg` ([lib/widgets/card/bank_card.dart:217-220](lib/widgets/card/bank_card.dart:217)).
- One visual pattern SVG selected from `_visualAssets` ([lib/constants/card_visuals.dart:970-1060](lib/constants/card_visuals.dart:970)).

### Pattern asset complexity estimate

Pattern assets are loaded from `_visualAssets` ([lib/constants/card_visuals.dart:970-1060](lib/constants/card_visuals.dart:970)) and then painted 4 times in the same card layer ([lib/widgets/card/card_visual_asset_layer.dart:33-88](lib/widgets/card/card_visual_asset_layer.dart:33)).

Heaviest pattern files by file size and basic shape count:

| Asset | Size | Approx shape elements | Complexity |
|---|---:|---:|---|
| `assets/card visuals/pearl-rosettes.svg` | 715,551 bytes | 2,815 | Very High |
| `assets/card visuals/spark-grid.svg` | 318,803 bytes | 1,685 | Very High |
| `assets/card visuals/pinstripe-ribbons.svg` | 105,458 bytes | 122 | High |
| `assets/card visuals/triangle-mesh.svg` | 63,080 bytes | 614 | High |
| `assets/card visuals/floating-cells.svg` | 15,695 bytes | 51 | Medium |
| Most other visual assets | < 2 KB | 3 to 6 | Low |

Because `CardVisualAssetLayer` repaints the same SVG four times with different blending strategies, the real raster cost is much higher than the raw file count suggests ([lib/widgets/card/card_visual_asset_layer.dart:33-88](lib/widgets/card/card_visual_asset_layer.dart:33)).

### Repeated decode / parse risks

- Custom card images are explicitly precached with `ResizeImage.resizeIfNeeded`, which is good ([lib/screens/home_screen.dart:202-243](lib/screens/home_screen.dart:202)).
- There is no explicit precache strategy for bank logo SVGs, network SVGs, chip SVG, or card visual SVGs. First-appearance parse and picture build work will happen lazily during interaction ([lib/widgets/bank/bank_logo.dart:33-79](lib/widgets/bank/bank_logo.dart:33), [lib/widgets/card/bank_card.dart:194-220](lib/widgets/card/bank_card.dart:194), [lib/widgets/card/card_visual_asset_layer.dart:33-88](lib/widgets/card/card_visual_asset_layer.dart:33)).
- Custom bank logos loaded through `Image.file` are not resized with `cacheWidth`, so large PNG logos can decode at full size on the UI pipeline ([lib/widgets/bank/bank_logo.dart:45-52](lib/widgets/bank/bank_logo.dart:45)).

## 6. State Management Audit

### Current state flow

- App-level state is local `State` plus Hive. There is no Provider, Riverpod, Bloc, or ChangeNotifier-based app state in the project.
- `HomeScreen` uses `ValueListenableBuilder<Box<CardData>>` against the Hive cards box as its root data subscription ([lib/screens/home_screen.dart:1025-1027](lib/screens/home_screen.dart:1025)).
- `HomeScreen` also maintains a large amount of UI state locally: `_cards`, `_deletingCardIds`, `_revealedCardId`, `_activeFilters`, `_sidePane`, `_editingCard`, `_editingCardId`, `_swipeResetToken`, `_activeSwipeCardId`, `_swipeTutorialQueued`, `_homeEntrySettled`, `_precachedCustomImageKeys` ([lib/screens/home_screen.dart:59-84](lib/screens/home_screen.dart:59)).
- Revealed/CVV state flows through `BankCardScope extends InheritedWidget` inside `SecureRevealWrapper` ([lib/widgets/card/secure_reveal_wrapper.dart:209-219](lib/widgets/card/secure_reveal_wrapper.dart:209), [lib/widgets/card/secure_reveal_wrapper.dart:234-256](lib/widgets/card/secure_reveal_wrapper.dart:234)).

### Rebuild cascade findings

- High: `HomeScreen` mixes data state and interaction state in one widget, so small UI changes rebuild the whole card area ([lib/screens/home_screen.dart:55-84](lib/screens/home_screen.dart:55), [lib/screens/home_screen.dart:1025-1068](lib/screens/home_screen.dart:1025)).
- High: reveal state is centralized in parent state via `_revealedCardId`, even though only one card needs to respond visually ([lib/screens/home_screen.dart:71](lib/screens/home_screen.dart:71), [lib/screens/home_screen.dart:475-528](lib/screens/home_screen.dart:475)).
- High: swipe-open coordination is also centralized in parent state (`_activeSwipeCardId`, `_swipeResetToken`), widening rebuilds ([lib/screens/home_screen.dart:79-80](lib/screens/home_screen.dart:79), [lib/screens/home_screen.dart:565-577](lib/screens/home_screen.dart:565)).
- Medium: `BankCardScope` is scoped well to one card, but it still causes descendants like `BankCard` and `CardDetailsBlock` to rebuild when `cvvVisible` changes ([lib/widgets/card/secure_reveal_wrapper.dart:234-256](lib/widgets/card/secure_reveal_wrapper.dart:234), [lib/widgets/card/bank_card.dart:72-103](lib/widgets/card/bank_card.dart:72)).

### Opportunities where only one card should rebuild

- Reveal/lock should be isolated to the active card instead of rebuilding the full `HomeScreen` card list ([lib/screens/home_screen.dart:475-528](lib/screens/home_screen.dart:475)).
- Swipe state should stay inside the active card row unless a second row must be told to close ([lib/screens/home_screen.dart:565-577](lib/screens/home_screen.dart:565), [lib/screens/home_screen.dart:1398-1448](lib/screens/home_screen.dart:1398)).
- Delete animation state already lives per card wrapper visually, but the initiating state mutation still happens in the parent list ([lib/screens/home_screen.dart:704-718](lib/screens/home_screen.dart:704), [lib/widgets/animations/deleting_list_item_wrapper.dart:14-34](lib/widgets/animations/deleting_list_item_wrapper.dart:14)).

## 7. Memory Audit

### Unnecessary object creation inside build methods

- `HomeScreen._buildCardItem` creates new `Color(...)` and `Alignment(...)` objects per card on each parent rebuild ([lib/screens/home_screen.dart:593-611](lib/screens/home_screen.dart:593)).
- `BankCard.build` recreates `CardVisual`, `File`, `DecorationImage`, `BoxDecoration`, `BoxShadow`, `BorderRadius.circular`, and multiple inline closures every build ([lib/widgets/card/bank_card.dart:74-145](lib/widgets/card/bank_card.dart:74), [lib/widgets/card/bank_card.dart:175-249](lib/widgets/card/bank_card.dart:175)).
- `PreviewCard.build` does similar work for the add-card flow preview ([lib/widgets/card/preview/preview_card.dart:82-154](lib/widgets/card/preview/preview_card.dart:82)).
- `AnimatedAddCardButton.build` reads Hive synchronously and creates theme tokens on each rebuild ([lib/widgets/buttons/animated_add_card_button.dart:34-38](lib/widgets/buttons/animated_add_card_button.dart:34)).

### Repeated gradient creation

- `CardVisuals.customGradient` creates a new `LinearGradient` every time it is called ([lib/constants/card_visuals.dart:35-57](lib/constants/card_visuals.dart:35)).
- `CardVisuals.forBank` creates a new `LinearGradient` per build for each card ([lib/constants/card_visuals.dart:940-959](lib/constants/card_visuals.dart:940)).

### Repeated TextStyle creation

- `CardDetailsBlock` repeatedly calls `GoogleFonts.poppins(...)` for card number, labels, values, holder name, toast text, and pill text ([lib/widgets/card/card_details_block.dart:53-60](lib/widgets/card/card_details_block.dart:53), [lib/widgets/card/card_details_block.dart:115-120](lib/widgets/card/card_details_block.dart:115), [lib/widgets/card/card_details_block.dart:138-179](lib/widgets/card/card_details_block.dart:138), [lib/widgets/card/card_details_block.dart:215-220](lib/widgets/card/card_details_block.dart:215), [lib/widgets/card/card_details_block.dart:251-255](lib/widgets/card/card_details_block.dart:251)).
- `BankCard` creates `GoogleFonts.poppins(...)` text styles for type labels ([lib/widgets/card/bank_card.dart:202-207](lib/widgets/card/bank_card.dart:202)).
- `BankLogo` creates `GoogleFonts.poppins(...)` for custom label and fallback initials ([lib/widgets/bank/bank_logo.dart:106-112](lib/widgets/bank/bank_logo.dart:106), [lib/widgets/bank/bank_logo.dart:139-144](lib/widgets/bank/bank_logo.dart:139)).

### Repeated Color creation

- `HomeScreen` reconstructs colors from stored ints on every card build ([lib/screens/home_screen.dart:593-600](lib/screens/home_screen.dart:593)).
- `CardVisualAssetLayer` derives multiple new tinted colors from gradient colors every build of a patterned card ([lib/widgets/card/card_visual_asset_layer.dart:138-203](lib/widgets/card/card_visual_asset_layer.dart:138)).

### Large in-memory caches

- The app opts into a fairly large image cache: `maximumSize = 300`, `maximumSizeBytes = 192 << 20` (~192 MB) ([lib/main.dart:21-23](lib/main.dart:21)).
- `HomeScreen` also duplicates the card collection in `_cards` in addition to Hive's live values, and `_cardsForDisplay` frequently clones lists with `toList(growable: false)` ([lib/screens/home_screen.dart:65](lib/screens/home_screen.dart:65), [lib/screens/home_screen.dart:323-331](lib/screens/home_screen.dart:323), [lib/screens/home_screen.dart:430](lib/screens/home_screen.dart:430)).

## 8. Scrolling Performance Risk Score

### Critical issues

- Scroll-driven full card-list rebuild in compact mode. Impact: severe at 60 Hz, worse at 120 Hz. Refs: [lib/screens/home_screen.dart:737-790](lib/screens/home_screen.dart:737)
- Non-virtualized stacked rendering for cards after index 1. Impact: severe at 60 Hz, very severe at 120 Hz. Refs: [lib/screens/home_screen.dart:761-786](lib/screens/home_screen.dart:761), [lib/screens/home_screen.dart:1237-1263](lib/screens/home_screen.dart:1237)
- `AnimatedPositioned` for every stacked card during scroll-driven updates. Impact: severe at 60 Hz, very severe at 120 Hz. Refs: [lib/screens/home_screen.dart:1335-1352](lib/screens/home_screen.dart:1335)

### High issues

- Pattern layer paints the same SVG four times plus a custom painter. Impact: high at 60 Hz, very high at 120 Hz. Refs: [lib/widgets/card/card_visual_asset_layer.dart:33-94](lib/widgets/card/card_visual_asset_layer.dart:33)
- Heavy pattern assets such as `pearl-rosettes.svg` and `spark-grid.svg`. Impact: high at 60 Hz, very high at 120 Hz. Refs: [lib/constants/card_visuals.dart:970-1060](lib/constants/card_visuals.dart:970)
- Per-card scroll listeners in `SecureRevealWrapper`. Impact: medium-high at 60 Hz, high at 120 Hz. Refs: [lib/widgets/card/secure_reveal_wrapper.dart:67-76](lib/widgets/card/secure_reveal_wrapper.dart:67)
- Full-list rebuilds for reveal and swipe coordination. Impact: high at 60 Hz, very high at 120 Hz. Refs: [lib/screens/home_screen.dart:475-528](lib/screens/home_screen.dart:475), [lib/screens/home_screen.dart:565-577](lib/screens/home_screen.dart:565)

### Medium issues

- `SingleChildScrollView + Wrap` on multi-pane layouts. Impact: medium at 60 Hz, medium-high at 120 Hz. Refs: [lib/screens/home_screen.dart:799-824](lib/screens/home_screen.dart:799)
- Synchronous `File.existsSync()` checks and full-size file image/logo loading in build. Impact: medium at 60 Hz, high during cold scroll/first display. Refs: [lib/widgets/card/bank_card.dart:86-93](lib/widgets/card/bank_card.dart:86), [lib/widgets/bank/bank_logo.dart:29-54](lib/widgets/bank/bank_logo.dart:29)
- Repeated `GoogleFonts`, gradients, and decoration object creation in hot paths. Impact: medium at 60 Hz, medium-high at 120 Hz. Refs: [lib/widgets/card/card_details_block.dart:115-220](lib/widgets/card/card_details_block.dart:115), [lib/constants/card_visuals.dart:35-57](lib/constants/card_visuals.dart:35), [lib/constants/card_visuals.dart:940-959](lib/constants/card_visuals.dart:940)

### Low issues

- Theme toggle Lottie exists in home header but is not continuously animating. Refs: [lib/widgets/buttons/theme_lottie_toggle.dart:91-98](lib/widgets/buttons/theme_lottie_toggle.dart:91)
- `BackdropFilter` usages exist elsewhere in the project, but not on the main home scroll path during normal use. Refs: [lib/main.dart:255-269](lib/main.dart:255), [lib/screens/add_card_flow/add_card_flow_screen.dart:727-730](lib/screens/add_card_flow/add_card_flow_screen.dart:727)

## 9. Most Likely Root Causes

1. `HomeScreen` rebuilds the compact card list on every scroll tick via `AnimatedBuilder(animation: _scrollController)` ([lib/screens/home_screen.dart:737-790](lib/screens/home_screen.dart:737)).
2. After 3 cards, the app abandons item virtualization and places cards `2..N` inside one `Stack` child ([lib/screens/home_screen.dart:761-786](lib/screens/home_screen.dart:761), [lib/screens/home_screen.dart:1237-1263](lib/screens/home_screen.dart:1237)).
3. Each stacked card uses `AnimatedPositioned`, making scrolling fight implicit layout animations ([lib/screens/home_screen.dart:1335-1352](lib/screens/home_screen.dart:1335)).
4. A standard patterned card is paint-heavy because the same pattern SVG is drawn 4 times with blend effects and then topped with `CustomPaint` grain ([lib/widgets/card/card_visual_asset_layer.dart:33-94](lib/widgets/card/card_visual_asset_layer.dart:33)).
5. Some pattern assets are extremely large and complex, notably `pearl-rosettes.svg` and `spark-grid.svg` ([lib/constants/card_visuals.dart:970-1060](lib/constants/card_visuals.dart:970)).
6. There is no full-card `RepaintBoundary`, so card-level transforms and reveal interactions can repaint large subtrees ([lib/screens/home_screen.dart:562-623](lib/screens/home_screen.dart:562), [lib/widgets/card/bank_card.dart:106-262](lib/widgets/card/bank_card.dart:106)).
7. Reveal and swipe state live in parent `HomeScreen` state, causing whole-list rebuilds for single-card interactions ([lib/screens/home_screen.dart:475-528](lib/screens/home_screen.dart:475), [lib/screens/home_screen.dart:565-577](lib/screens/home_screen.dart:565)).
8. Every card instance attaches a scroll listener in `SecureRevealWrapper`, multiplying scroll work by card count ([lib/widgets/card/secure_reveal_wrapper.dart:67-76](lib/widgets/card/secure_reveal_wrapper.dart:67)).
9. Synchronous file checks and image/logo resolution happen during widget build for custom assets ([lib/widgets/card/bank_card.dart:86-93](lib/widgets/card/bank_card.dart:86), [lib/widgets/bank/bank_logo.dart:29-54](lib/widgets/bank/bank_logo.dart:29)).
10. The card hot path repeatedly allocates gradients, text styles, colors, decorations, and closures during rebuilds ([lib/constants/card_visuals.dart:35-57](lib/constants/card_visuals.dart:35), [lib/constants/card_visuals.dart:940-959](lib/constants/card_visuals.dart:940), [lib/widgets/card/card_details_block.dart:115-220](lib/widgets/card/card_details_block.dart:115)).

## 10. Optimization Roadmap

Prioritized by expected FPS improvement:

1. Restore list virtualization for all home cards.
Refs: [lib/screens/home_screen.dart:740-788](lib/screens/home_screen.dart:740)
Expected gain: largest improvement on both 60 Hz and 120 Hz.

2. Remove scroll-tick full-tree rebuilds.
Refs: [lib/screens/home_screen.dart:737-790](lib/screens/home_screen.dart:737)
Expected gain: very large, especially for 120 Hz targets.

3. Replace stacked-section implicit animations with cheaper paint-only or transform-only logic, and keep off-screen cards out of the widget tree.
Refs: [lib/screens/home_screen.dart:1221-1352](lib/screens/home_screen.dart:1221)
Expected gain: very large.

4. Reduce card background paint cost.
Refs: [lib/widgets/card/card_visual_asset_layer.dart:33-94](lib/widgets/card/card_visual_asset_layer.dart:33)
Expected gain: large on GPU-bound devices.

5. Remove or heavily constrain the heaviest pattern SVGs from runtime selection.
Refs: [lib/constants/card_visuals.dart:970-1060](lib/constants/card_visuals.dart:970)
Expected gain: large on first render and while scrolling.

6. Isolate per-card state so reveal/swipe only rebuild the active row.
Refs: [lib/screens/home_screen.dart:475-528](lib/screens/home_screen.dart:475), [lib/screens/home_screen.dart:565-577](lib/screens/home_screen.dart:565)
Expected gain: medium-large.

7. Add a full-card `RepaintBoundary` strategy after rebuild breadth is reduced.
Refs: [lib/widgets/card/bank_card.dart:106-262](lib/widgets/card/bank_card.dart:106), [lib/widgets/card/secure_reveal_wrapper.dart:165-229](lib/widgets/card/secure_reveal_wrapper.dart:165)
Expected gain: medium.

8. Remove per-card scroll listeners and centralize reveal visibility detection.
Refs: [lib/widgets/card/secure_reveal_wrapper.dart:67-76](lib/widgets/card/secure_reveal_wrapper.dart:67)
Expected gain: medium.

9. Cache or pre-resolve custom asset metadata outside `build`, especially file existence and custom logo sizing.
Refs: [lib/widgets/card/bank_card.dart:86-93](lib/widgets/card/bank_card.dart:86), [lib/widgets/bank/bank_logo.dart:29-54](lib/widgets/bank/bank_logo.dart:29)
Expected gain: medium.

10. Hoist recurring gradients/text styles/decorations where practical.
Refs: [lib/constants/card_visuals.dart:35-57](lib/constants/card_visuals.dart:35), [lib/constants/card_visuals.dart:940-959](lib/constants/card_visuals.dart:940), [lib/widgets/card/card_details_block.dart:115-220](lib/widgets/card/card_details_block.dart:115)
Expected gain: small to medium, but worthwhile after the structural fixes.
