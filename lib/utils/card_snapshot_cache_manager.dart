import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';

import '../models/card_data.dart';

class CardSnapshotCacheManager {
  static const String _snapshotDirectoryName = 'swallet/card_snapshots';

  static Future<Directory> snapshotsDirectory() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final directory = Directory(
      '${documentsDirectory.path}${Platform.pathSeparator}'
      '${_snapshotDirectoryName.replaceAll('/', Platform.pathSeparator)}',
    );
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  static Future<File> snapshotFileForCardId(
    String cardId, {
    String? signature,
  }) async {
    final directory = await snapshotsDirectory();
    final signatureSuffix = signature == null || signature.isEmpty
        ? 'base'
        : signature.hashCode.abs().toString();
    return File(
      '${directory.path}${Platform.pathSeparator}'
      '${cardId}_visual_$signatureSuffix.png',
    );
  }

  static Future<void> deleteSnapshotPath(String? snapshotPath) async {
    final trimmedPath = snapshotPath?.trim();
    if (trimmedPath == null || trimmedPath.isEmpty) {
      return;
    }

    final file = File(trimmedPath);
    await FileImage(file).evict();
    if (file.existsSync()) {
      await file.delete();
    }
  }

  static Future<void> deleteSnapshotsForCard(CardData card) async {
    await deleteSnapshotPath(card.normalSnapshotPath);
  }

  static Future<void> cleanupOrphanedSnapshots(Iterable<CardData> cards) async {
    final directory = await snapshotsDirectory();
    if (!directory.existsSync()) {
      return;
    }

    final activePaths = cards
        .map((card) => card.normalSnapshotPath?.trim())
        .whereType<String>()
        .where((path) => path.isNotEmpty)
        .toSet();

    await for (final entity in directory.list()) {
      if (entity is! File) {
        continue;
      }
      if (!activePaths.contains(entity.path)) {
        await entity.delete();
      }
    }
  }
}
