enum AdaptiveWindowClass {
  compact,
  medium,
  expanded,
}

class AdaptiveLayout {
  static const double compactWidthMax = 600;
  static const double expandedWidthMin = 840;
  static const double tabletLandscapeShortestSideMin = 720;
  static const double phoneDesignWidth = 390;
  static const double phoneHorizontalPadding = 16;
  static const double phoneCardWidth =
      phoneDesignWidth - (phoneHorizontalPadding * 2);
  static const double cardPaneSpacing = 16;
  static const double formPaneMaxWidth = phoneDesignWidth;
  static const double mediumContentMaxWidth =
      (phoneCardWidth * 2) + cardPaneSpacing;
  static const double expandedContentMaxWidth =
      (phoneCardWidth * 3) + (cardPaneSpacing * 2);

  static AdaptiveWindowClass windowClassForWidth(double width) {
    if (width < compactWidthMax) {
      return AdaptiveWindowClass.compact;
    }
    if (width < expandedWidthMin) {
      return AdaptiveWindowClass.medium;
    }
    return AdaptiveWindowClass.expanded;
  }

  static bool usesPhoneCanvas(double width) {
    return windowClassForWidth(width) == AdaptiveWindowClass.compact;
  }

  static bool allowsLandscapeForSize(double width, double height) {
    return width < height
        ? width >= tabletLandscapeShortestSideMin
        : height >= tabletLandscapeShortestSideMin;
  }

  static int cardPaneCountForWidth(double width) {
    final horizontalPadding = horizontalPaddingForWidth(width);
    final availableContentWidth = width - (horizontalPadding * 2);
    final maxPaneCount =
        windowClassForWidth(width) == AdaptiveWindowClass.expanded ? 3 : 2;

    for (var paneCount = maxPaneCount; paneCount > 1; paneCount--) {
      final requiredWidth =
          (phoneCardWidth * paneCount) + (cardPaneSpacing * (paneCount - 1));
      if (availableContentWidth >= requiredWidth) {
        return paneCount;
      }
    }

    return 1;
  }

  static double horizontalPaddingForWidth(double width) {
    switch (windowClassForWidth(width)) {
      case AdaptiveWindowClass.compact:
        return 16;
      case AdaptiveWindowClass.medium:
        return 24;
      case AdaptiveWindowClass.expanded:
        return 32;
    }
  }

  static double contentMaxWidthForWidth(double width) {
    switch (windowClassForWidth(width)) {
      case AdaptiveWindowClass.compact:
        return double.infinity;
      case AdaptiveWindowClass.medium:
        return mediumContentMaxWidth;
      case AdaptiveWindowClass.expanded:
        return expandedContentMaxWidth;
    }
  }

  static double outerGutterForWidth(double width) {
    final maxWidth = contentMaxWidthForWidth(width);
    if (!maxWidth.isFinite || width <= maxWidth) {
      return 0;
    }
    return (width - maxWidth) / 2;
  }
}
