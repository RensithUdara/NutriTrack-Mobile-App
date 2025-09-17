import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getResponsiveWidth(BuildContext context, double mobileWidth,
      {double? tabletWidth, double? desktopWidth}) {
    if (isDesktop(context) && desktopWidth != null) {
      return desktopWidth;
    } else if (isTablet(context) && tabletWidth != null) {
      return tabletWidth;
    }
    return mobileWidth;
  }

  static double getResponsiveHeight(BuildContext context, double mobileHeight,
      {double? tabletHeight, double? desktopHeight}) {
    if (isDesktop(context) && desktopHeight != null) {
      return desktopHeight;
    } else if (isTablet(context) && tabletHeight != null) {
      return tabletHeight;
    }
    return mobileHeight;
  }

  static EdgeInsets getResponsivePadding(BuildContext context,
      {EdgeInsets? mobilePadding,
      EdgeInsets? tabletPadding,
      EdgeInsets? desktopPadding}) {
    if (isDesktop(context) && desktopPadding != null) {
      return desktopPadding;
    } else if (isTablet(context) && tabletPadding != null) {
      return tabletPadding;
    }
    return mobilePadding ?? const EdgeInsets.all(16);
  }

  static double getResponsiveFontSize(
      BuildContext context, double mobileFontSize,
      {double? tabletFontSize, double? desktopFontSize}) {
    if (isDesktop(context) && desktopFontSize != null) {
      return desktopFontSize;
    } else if (isTablet(context) && tabletFontSize != null) {
      return tabletFontSize;
    }
    return mobileFontSize;
  }

  static int getResponsiveColumns(BuildContext context,
      {int mobileColumns = 1, int tabletColumns = 2, int desktopColumns = 3}) {
    if (isDesktop(context)) {
      return desktopColumns;
    } else if (isTablet(context)) {
      return tabletColumns;
    }
    return mobileColumns;
  }

  static Widget getResponsiveLayout(BuildContext context,
      {required Widget mobileLayout,
      Widget? tabletLayout,
      Widget? desktopLayout}) {
    if (isDesktop(context) && desktopLayout != null) {
      return desktopLayout;
    } else if (isTablet(context) && tabletLayout != null) {
      return tabletLayout;
    }
    return mobileLayout;
  }

  static double getCardWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isDesktop(context)) {
      return (screenWidth - 80) / 3; // 3 columns with gaps
    } else if (isTablet(context)) {
      return (screenWidth - 60) / 2; // 2 columns with gaps
    }
    return screenWidth - 32; // Full width minus padding
  }

  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1200;
    } else if (isTablet(context)) {
      return 800;
    }
    return getScreenWidth(context);
  }

  static bool shouldShowSidebar(BuildContext context) {
    return isDesktop(context);
  }

  static bool shouldShowBottomNavigation(BuildContext context) {
    return isMobile(context) || isTablet(context);
  }
}
