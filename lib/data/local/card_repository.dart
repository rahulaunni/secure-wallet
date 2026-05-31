import 'package:hive/hive.dart';

import '../../models/card_data.dart';
import '../../utils/card_snapshot_cache_manager.dart';
import 'hive_boxes.dart';

class CardRepository {
  /// 🔒 Internal accessor
  /// Box MUST be opened in main.dart (with encryption if enabled)
  static Box<CardData> get _box {
    if (!Hive.isBoxOpen(HiveBoxes.cards)) {
      throw HiveError(
        'CardRepository used before Hive box was opened',
      );
    }
    return Hive.box<CardData>(HiveBoxes.cards);
  }

  // ================= READ =================

  static List<CardData> getAll() {
    return _box.values.toList(growable: false).reversed.toList(growable: false);
  }

  static dynamic _findKey(CardData card) {
    for (final key in _box.keys) {
      final stored = _box.get(key);
      if (stored == null) continue;
      if (identical(stored, card)) {
        return key;
      }
    }

    final cardId = card.cardId?.trim();
    if (cardId != null && cardId.isNotEmpty) {
      for (final key in _box.keys) {
        final stored = _box.get(key);
        if (stored?.cardId == cardId) {
          return key;
        }
      }
    }

    for (final key in _box.keys) {
      final stored = _box.get(key);
      if (stored == null) continue;
      final sameIdentityFields = stored.bankCid == card.bankCid &&
          stored.cardNumber == card.cardNumber &&
          stored.expiry == card.expiry &&
          stored.holderName == card.holderName;
      if (sameIdentityFields) {
        return key;
      }
    }

    return null;
  }

  // ================= ADD =================

  static Future<void> add(CardData card) async {
    await _box.add(card);
  }

  // ================= UPDATE =================
  /// Updates by Hive key using the in-memory card instance as the lookup anchor.
  static Future<void> update(CardData original, CardData updated) async {
    final updateKey = _findKey(original);
    if (updateKey != null) {
      await _box.put(updateKey, updated);
    }
  }

  static Future<void> updateSnapshotMetadata(
    CardData original, {
    String? cardId,
    String? normalSnapshotPath,
    String? normalSnapshotSignature,
  }) async {
    final updated = original.copyWith(
      cardId: cardId,
      normalSnapshotPath: normalSnapshotPath,
      normalSnapshotSignature: normalSnapshotSignature,
    );
    await update(original, updated);
  }

  // ================= DELETE =================
  /// 🔒 Deletes by Hive key (SAFE)
  /// - Does NOT rely on == override
  /// - Works with encrypted boxes
  /// - Stable for future model changes
  static Future<void> delete(CardData card) async {
    final deleteKey = _findKey(card);
    if (deleteKey != null) {
      await CardSnapshotCacheManager.deleteSnapshotsForCard(card);
      await _box.delete(deleteKey);
    }
  }

  // ================= CLEAR (DEV / RESET) =================

  static Future<void> clearAll() async {
    await _box.clear();
  }
}
