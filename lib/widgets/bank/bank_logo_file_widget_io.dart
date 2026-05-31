import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget? buildCustomBankLogoWidget({
  required String path,
  required double size,
  required WidgetBuilder fallbackBuilder,
}) {
  final file = File(path);
  if (!file.existsSync()) {
    return null;
  }

  if (path.toLowerCase().endsWith('.svg')) {
    return SvgPicture.file(
      file,
      height: size,
      fit: BoxFit.contain,
      colorFilter: null,
      errorBuilder: (context, error, stackTrace) => fallbackBuilder(context),
    );
  }

  return Image.file(
    file,
    height: size,
    fit: BoxFit.contain,
    color: null,
    errorBuilder: (context, error, stackTrace) => fallbackBuilder(context),
  );
}
