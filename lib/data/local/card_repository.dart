import 'package:hive/hive.dart';

import '../../models/card_data.dart';
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
    return _box.values.toList(growable: false);
  }

  // ================= ADD =================

  static Future<void> add(CardData card) async {
    await _box.add(card);
  }

  // ================= DELETE =================
  /// 🔒 Deletes by Hive key (SAFE)
  /// - Does NOT rely on == override
  /// - Works with encrypted boxes
  /// - Stable for future model changes
  static Future<void> delete(CardData card) async {
    dynamic deleteKey;

    for (final key in _box.keys) {
      final stored = _box.get(key);
      if (identical(stored, card)) {
        deleteKey = key;
        break;
      }
    }

    if (deleteKey != null) {
      await _box.delete(deleteKey);
    }
  }

  // ================= CLEAR (DEV / RESET) =================

  static Future<void> clearAll() async {
    await _box.clear();
  }
}
