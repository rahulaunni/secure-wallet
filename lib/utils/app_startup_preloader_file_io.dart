import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<void> preloadFileAsset(
  String path,
  BuildContext context, {
  int? cacheWidth,
}) async {
  final trimmedPath = path.trim();
  if (trimmedPath.isEmpty) {
    return;
  }

  final file = File(trimmedPath);
  if (!file.existsSync()) {
    return;
  }

  if (trimmedPath.toLowerCase().endsWith('.svg')) {
    await SvgFileLoader(file).loadBytes(null);
    return;
  }

  final provider = ResizeImage.resizeIfNeeded(
    cacheWidth,
    null,
    FileImage(file),
  );
  await precacheImage(provider, context);
}
