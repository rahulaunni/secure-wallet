import 'dart:math' as math;

import 'package:flutter/material.dart';

class SizeConfig {
  SizeConfig._();

  static const double baseWidth = 393;
  static const double baseHeight = 852;

  static double screenWidth = baseWidth;
  static double screenHeight = baseHeight;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;
  static double get heightScale => screenHeight / baseHeight;
  static double get lockedHeightScale => math.min(heightScale, 1.0);
  static double get widthScale => lockedHeightScale;
  static double get textScale => lockedHeightScale;
  static double get radiusScale => lockedHeightScale;

  static void init(BuildContext context) {
    initFromMediaQuery(MediaQuery.of(context));
  }

  static void initFromMediaQuery(MediaQueryData mediaQuery) {
    final size = mediaQuery.size;
    screenWidth = baseWidth;
    screenHeight = size.height <= 0 ? baseHeight : size.height;
    _initialized = true;
  }
}

double w(double value) => value * SizeConfig.widthScale;
double h(double value) => value * SizeConfig.heightScale;
double sp(double value) => value * SizeConfig.textScale;
double r(double value) => value * SizeConfig.radiusScale;
