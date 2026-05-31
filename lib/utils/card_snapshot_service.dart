import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/card_visuals.dart';
import '../data/local/card_repository.dart';
import '../models/card_data.dart';
import '../utils/bank_asset_resolver.dart';
import 'card_snapshot_cache_manager.dart';

class CardSnapshotService {
  static const double _minimumCaptureLogicalWidth = 320;
  static const String _chipAssetPath = 'assets/images/chip.svg';
  static const int _captureAttemptCount = 12;
  static const Duration _captureAttemptGap = Duration(milliseconds: 16);
  static final Random _random = Random();
  static Future<void> _generationQueue = Future<void>.value();
  static final Set<String> _activeGenerations = <String>{};

  static String? currentSnapshotPath(CardData card) {
    final snapshotPath = card.normalSnapshotPath?.trim();
    if (snapshotPath == null || snapshotPath.isEmpty) {
      return null;
    }

    if (card.normalSnapshotSignature != visualSignature(card)) {
      return null;
    }

    return File(snapshotPath).existsSync() ? snapshotPath : null;
  }

  static bool hasCurrentSnapshot(CardData card) {
    return currentSnapshotPath(card) != null;
  }

  static String visualSignature(CardData card) {
    return [
      'visual_snapshot_v2',
      card.bankCid,
      card.cardNetwork.name,
      card.cardType.name,
      card.customBankName ?? '',
      card.customBankLogoPath ?? '',
      card.customGradientStartColor?.toString() ?? '',
      card.customGradientMiddleColor?.toString() ?? '',
      card.customGradientEndColor?.toString() ?? '',
      card.customCardImagePath ?? '',
      card.customCardVisualMode?.toString() ?? '',
      card.customCardImageAlignmentX?.toString() ?? '',
      card.customCardImageAlignmentY?.toString() ?? '',
      card.customCardPatternAssetPath ?? '',
    ].join('|');
  }

  static Future<void> ensureSnapshotFromBoundary({
    required BuildContext context,
    required CardData card,
    required GlobalKey boundaryKey,
    required double logicalWidth,
  }) async {
    if (!context.mounted || logicalWidth < _minimumCaptureLogicalWidth) {
      return;
    }

    final generationKey = card.cardId ?? _fallbackGenerationKey(card);
    if (_activeGenerations.contains(generationKey)) {
      return;
    }

    final pixelRatio = MediaQuery.devicePixelRatioOf(context).clamp(2.0, 3.0);
    _activeGenerations.add(generationKey);
    _generationQueue = _generationQueue.then((_) async {
      try {
        final result = await _captureFromBoundary(
          card: card,
          boundaryKey: boundaryKey,
          pixelRatio: pixelRatio,
        );
        if (result != null) {
          await CardRepository.update(card, result);
        }
      } finally {
        _activeGenerations.remove(generationKey);
      }
    });
    await _generationQueue;
  }

  static Future<CardData?> captureSnapshotForCard({
    required CardData card,
    required BuildContext context,
    required GlobalKey boundaryKey,
    double? pixelRatioOverride,
    bool persistToRepository = false,
  }) async {
    final existingPath = currentSnapshotPath(card);
    if (existingPath != null) {
      return card;
    }

    if (!context.mounted) {
      return null;
    }

    final pixelRatio =
        pixelRatioOverride ??
            MediaQuery.devicePixelRatioOf(context).clamp(2.0, 3.0);
    await _warmSnapshotAssets(
      context,
      card,
      pixelRatio: pixelRatio,
      logicalWidth: _logicalWidthForBoundary(boundaryKey) ?? 358,
    );
    if (!context.mounted) {
      return null;
    }
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
    CardData? result;
    for (var attempt = 0; attempt < _captureAttemptCount; attempt++) {
      result = await _captureFromBoundary(
        card: card,
        boundaryKey: boundaryKey,
        pixelRatio: pixelRatio,
      );
      if (result != null) {
        break;
      }
      await WidgetsBinding.instance.endOfFrame;
      if (attempt < _captureAttemptCount - 1) {
        await Future<void>.delayed(_captureAttemptGap);
      }
    }
    if (persistToRepository && result != null) {
      await CardRepository.update(card, result);
    }
    return result;
  }

  static double? _logicalWidthForBoundary(GlobalKey boundaryKey) {
    final boundaryContext = boundaryKey.currentContext;
    if (boundaryContext == null) {
      return null;
    }
    final size = boundaryContext.size;
    return size?.width;
  }

  static Future<void> _warmSnapshotAssets(
    BuildContext context,
    CardData card, {
    required double pixelRatio,
    required double logicalWidth,
  }) async {
    final svgAssets = <String>{_chipAssetPath};
    final imageAssets = <String>{};
    final svgFiles = <String>{};
    final imageFiles = <String>{};

    final networkAsset = card.cardNetwork.assetPath.trim();
    if (networkAsset.isNotEmpty) {
      svgAssets.add(networkAsset);
    }

    final bankLogoPath = BankAssetResolver.logoPath(card.bankCid)?.trim();
    if (bankLogoPath != null && bankLogoPath.isNotEmpty) {
      if (bankLogoPath.toLowerCase().endsWith('.svg')) {
        svgAssets.add(bankLogoPath);
      } else {
        imageAssets.add(bankLogoPath);
      }
    }

    final customBankLogoPath = card.customBankLogoPath?.trim();
    if (customBankLogoPath != null && customBankLogoPath.isNotEmpty) {
      if (customBankLogoPath.toLowerCase().endsWith('.svg')) {
        svgFiles.add(customBankLogoPath);
      } else {
        imageFiles.add(customBankLogoPath);
      }
    }

    final visualAssetPath = _resolvedVisualAssetPathForCard(card);
    if (visualAssetPath != null && visualAssetPath.isNotEmpty) {
      svgAssets.add(visualAssetPath);
    }

    final customImagePath = card.customCardImagePath?.trim();
    if (customImagePath != null && customImagePath.isNotEmpty) {
      imageFiles.add(customImagePath);
    }

    for (final assetPath in svgAssets) {
      if (!context.mounted) {
        return;
      }
      try {
        await SvgAssetLoader(assetPath).loadBytes(context);
      } catch (_) {}
    }

    for (final assetPath in imageAssets) {
      if (!context.mounted) {
        return;
      }
      try {
        await precacheImage(AssetImage(assetPath), context);
      } catch (_) {}
    }

    for (final filePath in svgFiles) {
      if (!context.mounted) {
        return;
      }
      try {
        final file = File(filePath);
        if (!file.existsSync()) continue;
        await SvgFileLoader(file).loadBytes(context);
      } catch (_) {}
    }

    final cacheWidth = (logicalWidth * pixelRatio).round();
    for (final filePath in imageFiles) {
      if (!context.mounted) {
        return;
      }
      try {
        final file = File(filePath);
        if (!file.existsSync()) continue;
        await precacheImage(
          ResizeImage.resizeIfNeeded(
            cacheWidth,
            null,
            FileImage(file),
          ),
          context,
        );
      } catch (_) {}
    }
  }

  static String? _resolvedVisualAssetPathForCard(CardData card) {
    final customPatternPath = card.customCardPatternAssetPath?.trim();
    if (customPatternPath != null && customPatternPath.isNotEmpty) {
      return CardVisuals.resolveVisualAssetPath(customPatternPath);
    }

    return CardVisuals.forBank(card.bankCid).visualAssetPath;
  }

  static Future<CardData?> _captureFromBoundary({
    required CardData card,
    required GlobalKey boundaryKey,
    required double pixelRatio,
  }) async {
    if (hasCurrentSnapshot(card)) {
      return card;
    }

    final boundaryContext = boundaryKey.currentContext;
    final renderObject = boundaryContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      return null;
    }

    final signature = visualSignature(card);
    final cardId = card.cardId ?? _generateCardId();
    final snapshotFile = await CardSnapshotCacheManager.snapshotFileForCardId(
      cardId,
      signature: signature,
    );
    final existingPath = card.normalSnapshotPath;
    final stopwatch = Stopwatch()..start();

    ui.Image? image;
    try {
      final capturedImage = await renderObject.toImage(pixelRatio: pixelRatio);
      image = capturedImage;
      final byteData =
          await capturedImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return null;
      }

      final pngBytes = byteData.buffer.asUint8List();
      if (pngBytes.isEmpty) {
        return null;
      }
      await snapshotFile.writeAsBytes(pngBytes, flush: true);

      final updatedCard = card.copyWith(
        cardId: cardId,
        normalSnapshotPath: snapshotFile.path,
        normalSnapshotSignature: signature,
      );

      if (existingPath != null &&
          existingPath.isNotEmpty &&
          existingPath != snapshotFile.path) {
        await CardSnapshotCacheManager.deleteSnapshotPath(existingPath);
      }

      debugPrint(
        'Card snapshot generated for $cardId in '
        '${stopwatch.elapsedMilliseconds}ms '
        '(${pngBytes.lengthInBytes} bytes png)',
      );
      return updatedCard;
    } catch (error, stackTrace) {
      debugPrint('Card snapshot generation failed: $error');
      debugPrint('$stackTrace');
      return null;
    } finally {
      image?.dispose();
    }
  }

  static String _fallbackGenerationKey(CardData card) {
    return [
      card.bankCid,
      card.cardNumber,
      card.expiry,
      card.holderName,
      card.customCardImagePath ?? '',
      card.customCardPatternAssetPath ?? '',
      card.customGradientStartColor?.toString() ?? '',
      card.customGradientMiddleColor?.toString() ?? '',
      card.customGradientEndColor?.toString() ?? '',
    ].join('|');
  }

  static String _generateCardId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final salt = _random.nextInt(1 << 32);
    return '${now}_$salt';
  }
}
