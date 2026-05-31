import 'dart:io';

import 'package:flutter/material.dart';

DecorationImage? buildCustomCardDecorationImage({
  required String? path,
  required int targetImageWidth,
  required Alignment alignment,
}) {
  final customImagePath = path?.trim();
  if (customImagePath == null || customImagePath.isEmpty) {
    return null;
  }

  final customImageFile = File(customImagePath);
  if (!customImageFile.existsSync()) {
    return null;
  }

  return DecorationImage(
    image: ResizeImage.resizeIfNeeded(
      targetImageWidth,
      null,
      FileImage(customImageFile),
    ),
    fit: BoxFit.cover,
    alignment: alignment,
    filterQuality: FilterQuality.low,
  );
}
