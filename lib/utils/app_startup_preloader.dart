import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import '../constants/card_visuals.dart';
import '../data/bank_assets.dart';
import '../data/local/card_repository.dart';
import '../models/card_data.dart';
import '../models/card_network.dart';
import 'adaptive_layout.dart';
import 'app_startup_preloader_file_stub.dart'
    if (dart.library.io) 'app_startup_preloader_file_io.dart'
    as app_startup_preloader_file;
import 'bank_asset_resolver.dart';

class AppStartupPreloader {
  static bool _scheduled = false;
  static Future<void>? _warmUpFuture;
  static final Set<String> _warmedSvgAssetPaths = <String>{};
  static final Set<String> _warmedImageAssetPaths = <String>{};
  static final Set<String> _warmedLottieAssetPaths = <String>{};
  static final Set<String> _warmedFileAssetKeys = <String>{};
  static final Set<String> _warmedCardKeys = <String>{};

  static const Duration _batchGap = Duration(milliseconds: 12);
  static const int _batchSize = 4;

  static const List<String> _criticalSvgAssets = [
    'assets/images/logo_44.svg',
    'assets/images/chip.svg',
    'assets/icons/credit_card.svg',
    'assets/icons/debit_card.svg',
    'assets/icons/person.svg',
    'assets/icons/fingerprint-outline-sharp.svg',
  ];

  static const List<String> _criticalImageAssets = [
    'assets/images/logo_56.png',
    'assets/images/textures/blue_leather_texture.jpeg',
  ];

  static const List<String> _criticalLottieAssets = [
    'assets/lottie/auth_success.json',
    'assets/lottie/no_connection.json',
    'assets/lottie/theme/sun_moon_toggle.json',
  ];

  static const List<String> _deferredSvgAssets = [
    'assets/icons/palette-swatch.svg',
    'assets/onboarding/secure card.svg',
    'assets/onboarding/no internet.svg',
    'assets/onboarding/fingerprint.svg',
  ];

  static const List<String> _deferredImageAssets = [
    'assets/images/networks/visa.png',
    'assets/images/networks/mastercard.png',
    'assets/images/networks/rupay.png',
    'assets/images/networks/amex.png',
  ];

  static void scheduleWarmUp(BuildContext context) {
    if (_scheduled) {
      return;
    }
    _scheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _warmUpFuture ??= _runWarmUp(context);
    });
  }

  static void scheduleCardWarmUp(
    BuildContext context,
    Iterable<CardData> cards, {
    required double cardWidth,
  }) {
    final cardList = cards.toList(growable: false);
    if (cardList.isEmpty) {
      return;
    }

    final pendingCards = <CardData>[];
    for (final card in cardList) {
      final cardKey = _cardWarmKey(card);
      if (_warmedCardKeys.add(cardKey)) {
        pendingCards.add(card);
      }
    }

    if (pendingCards.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _warmSpecificCards(
        context,
        pendingCards,
        cardWidth: cardWidth,
      );
    });
  }

  static Future<void> _runWarmUp(BuildContext context) async {
    await _warmCriticalAssets(context);
    if (!context.mounted) {
      return;
    }
    await _yieldToNextFrame();
    if (!context.mounted) {
      return;
    }
    await _warmSavedCardAssets(context);
    if (!context.mounted) {
      return;
    }
    await _yieldToNextFrame();
    if (!context.mounted) {
      return;
    }
    await _warmDeferredAssets(context);
  }

  static Future<void> _warmCriticalAssets(BuildContext context) async {
    final networkSvgAssets = CardNetwork.values
        .map((network) => network.assetPath)
        .where((path) => path.isNotEmpty);

    await _warmSvgAssets(
      context,
      <String>{
        ..._criticalSvgAssets,
        ...networkSvgAssets,
      },
    );
    if (!context.mounted) {
      return;
    }
    await _warmImageAssets(context, _criticalImageAssets);
    if (!context.mounted) {
      return;
    }
    await _warmLottieAssets(_criticalLottieAssets);
  }

  static Future<void> _warmSavedCardAssets(BuildContext context) async {
    if (!context.mounted) {
      return;
    }

    final savedCards = CardRepository.getAll();
    if (savedCards.isEmpty) {
      return;
    }

    await _warmSpecificCards(
      context,
      savedCards,
      cardWidth: AdaptiveLayout.phoneCardWidth,
    );
  }

  static Future<void> _warmDeferredAssets(BuildContext context) async {
    final flagAssets = BankAssets.supportedCountries.map(
      (country) => country.flagAsset,
    );
    final defaultCountryLogos = BankAssets.banksForCountry(
      BankAssets.defaultCountryId,
    ).map(BankAssetResolver.logoPath).whereType<String>();

    await _warmSvgAssets(
      context,
      <String>{
        ..._deferredSvgAssets,
        ...flagAssets,
        ...defaultCountryLogos.where((path) => path.toLowerCase().endsWith('.svg')),
      },
    );
    if (!context.mounted) {
      return;
    }
    await _warmImageAssets(
      context,
      <String>{
        ..._deferredImageAssets,
        ...defaultCountryLogos.where((path) => !path.toLowerCase().endsWith('.svg')),
      },
    );
  }

  static void _collectBankCardAssets(
    CardData card, {
    required Set<String> svgAssets,
    required Set<String> imageAssets,
    required Set<String> fileAssets,
  }) {
    final networkAsset = card.cardNetwork.assetPath;
    if (networkAsset.isNotEmpty) {
      svgAssets.add(networkAsset);
    }

    final customBankLogoPath = card.customBankLogoPath?.trim();
    if (customBankLogoPath != null && customBankLogoPath.isNotEmpty) {
      fileAssets.add(customBankLogoPath);
    } else {
      final bankLogoPath = BankAssetResolver.logoPath(card.bankCid);
      if (bankLogoPath != null) {
        if (bankLogoPath.toLowerCase().endsWith('.svg')) {
          svgAssets.add(bankLogoPath);
        } else {
          imageAssets.add(bankLogoPath);
        }
      }
    }

    final customImagePath = card.customCardImagePath?.trim();
    if (customImagePath != null && customImagePath.isNotEmpty) {
      fileAssets.add(customImagePath);
    }

    final visualAssetPath = _resolvedVisualAssetPathForCard(card);
    if (visualAssetPath != null && visualAssetPath.isNotEmpty) {
      svgAssets.add(visualAssetPath);
    }
  }

  static String? _resolvedVisualAssetPathForCard(CardData card) {
    final customPatternPath = card.customCardPatternAssetPath?.trim();
    if (customPatternPath != null && customPatternPath.isNotEmpty) {
      return CardVisuals.resolveVisualAssetPath(customPatternPath);
    }

    return CardVisuals.forBank(card.bankCid).visualAssetPath;
  }

  static void _resolveVisualConfiguration(CardData card) {
    final customStart = card.customGradientStartColor;
    final customEnd = card.customGradientEndColor;
    if (customStart != null && customEnd != null) {
      CardVisuals.customGradient(
        Color(customStart),
        Color(customEnd),
        middle: card.customGradientMiddleColor != null
            ? Color(card.customGradientMiddleColor!)
            : null,
        visualAssetPath: card.customCardPatternAssetPath,
      );
      return;
    }

    CardVisuals.forBank(card.bankCid);
  }

  static Future<void> _warmSpecificCards(
    BuildContext context,
    Iterable<CardData> cards, {
    required double cardWidth,
  }) async {
    if (!context.mounted) {
      return;
    }

    final cardImageWidth =
        (MediaQuery.devicePixelRatioOf(context) * cardWidth).round();
    final svgAssets = <String>{};
    final imageAssets = <String>{};
    final fileAssets = <String>{};

    for (final card in cards) {
      _resolveVisualConfiguration(card);
      _collectBankCardAssets(
        card,
        svgAssets: svgAssets,
        imageAssets: imageAssets,
        fileAssets: fileAssets,
      );
    }

    await _warmSvgAssets(context, svgAssets);
    if (!context.mounted) {
      return;
    }
    await _warmImageAssets(context, imageAssets);
    if (!context.mounted) {
      return;
    }
    await _warmFileAssets(
      context,
      fileAssets,
      cacheWidth: cardImageWidth,
    );
  }

  static Future<void> _warmSvgAssets(
    BuildContext context,
    Iterable<String> assetPaths,
  ) async {
    final uniquePaths = _consumeUnseenPaths(
      assetPaths,
      _warmedSvgAssetPaths,
    );

    await _runBatches(
      uniquePaths,
      (path) => SvgAssetLoader(path).loadBytes(context),
    );
  }

  static Future<void> _warmImageAssets(
    BuildContext context,
    Iterable<String> assetPaths,
  ) async {
    final uniquePaths = _consumeUnseenPaths(
      assetPaths,
      _warmedImageAssetPaths,
    );

    await _runBatches(
      uniquePaths,
      (path) async {
        if (!context.mounted) {
          return;
        }
        await precacheImage(AssetImage(path), context);
      },
    );
  }

  static Future<void> _warmFileAssets(
    BuildContext context,
    Iterable<String> filePaths, {
    int? cacheWidth,
  }) async {
    final uniquePaths = <String>[];
    for (final rawPath in filePaths) {
      final path = rawPath.trim();
      if (path.isEmpty) {
        continue;
      }
      final key = '$path@${cacheWidth ?? 'full'}';
      if (_warmedFileAssetKeys.add(key)) {
        uniquePaths.add(path);
      }
    }

    await _runBatches(
      uniquePaths,
      (path) async {
        if (!context.mounted) {
          return;
        }
        await app_startup_preloader_file.preloadFileAsset(
          path,
          context,
          cacheWidth: cacheWidth,
        );
      },
    );
  }

  static Future<void> _warmLottieAssets(Iterable<String> assetPaths) async {
    final uniquePaths = _consumeUnseenPaths(
      assetPaths,
      _warmedLottieAssetPaths,
    );

    await _runBatches(
      uniquePaths,
      (path) => AssetLottie(path).load(),
    );
  }

  static Future<void> _runBatches<T>(
    List<T> items,
    Future<void> Function(T item) action,
  ) async {
    for (var start = 0; start < items.length; start += _batchSize) {
      final end = start + _batchSize < items.length
          ? start + _batchSize
          : items.length;
      final batch = items.sublist(start, end);
      await Future.wait(
        batch.map((item) async {
          try {
            await action(item);
          } catch (_) {}
        }),
      );

      if (end < items.length) {
        await _yieldToNextFrame();
      }
    }
  }

  static Future<void> _yieldToNextFrame() {
    return Future<void>.delayed(_batchGap);
  }

  static List<String> _consumeUnseenPaths(
    Iterable<String> assetPaths,
    Set<String> seenPaths,
  ) {
    final uniquePaths = <String>[];
    for (final rawPath in assetPaths) {
      final path = rawPath.trim();
      if (path.isEmpty || !seenPaths.add(path)) {
        continue;
      }
      uniquePaths.add(path);
    }
    return uniquePaths;
  }

  static String _cardWarmKey(CardData card) {
    return '${card.bankCid}|${card.cardNetwork.name}|${card.customBankLogoPath ?? ''}|'
        '${card.customCardImagePath ?? ''}|${card.customCardPatternAssetPath ?? ''}|'
        '${card.customGradientStartColor ?? ''}|${card.customGradientMiddleColor ?? ''}|'
        '${card.customGradientEndColor ?? ''}|${card.customCardVisualMode ?? ''}';
  }
}
