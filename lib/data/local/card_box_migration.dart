import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/card_data.dart';
import 'hive_boxes.dart';

class CardBoxMigration {
  static Future<Box<CardData>> openEncryptedCardsBox(
    List<int> encryptionKey,
  ) async {
    try {
      return await Hive.openBox<CardData>(
        HiveBoxes.cards,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
    } catch (encryptedError, encryptedStack) {
      debugPrint(
        'Encrypted cards box did not open. Trying legacy card migration.',
      );

      try {
        if (Hive.isBoxOpen(HiveBoxes.cards)) {
          await Hive.box<CardData>(HiveBoxes.cards).close();
        }

        final legacyBox = await Hive.openBox<CardData>(HiveBoxes.cards);
        final legacyCards = legacyBox.values.toList(growable: false);
        await legacyBox.close();

        await Hive.deleteBoxFromDisk(HiveBoxes.cards);

        final encryptedBox = await Hive.openBox<CardData>(
          HiveBoxes.cards,
          encryptionCipher: HiveAesCipher(encryptionKey),
        );

        if (legacyCards.isNotEmpty) {
          await encryptedBox.addAll(legacyCards);
        }

        debugPrint(
          'Migrated ${legacyCards.length} legacy card(s) to encrypted storage.',
        );
        return encryptedBox;
      } catch (legacyError, legacyStack) {
        debugPrint('Legacy card migration failed: $legacyError');
        debugPrint('$legacyStack');
        Error.throwWithStackTrace(encryptedError, encryptedStack);
      }
    }
  }
}
