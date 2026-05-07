import 'package:hive/hive.dart';

import '../../models/card_data.dart';
import '../../models/card_network.dart';
import '../../models/card_type.dart';

void registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(CardDataAdapter());
  }

  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(CardNetworkAdapter());
  }

  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(CardTypeAdapter());
  }
}
