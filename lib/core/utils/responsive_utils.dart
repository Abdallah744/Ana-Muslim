import 'dart:ui';
import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Dynamically scale font size based on device width
  static double fontSize(BuildContext context, double baseSize) {
    double width = MediaQuery.of(context).size.width;
    double scaleFactor = width / 390.0; // Standard reference width (iPhone 12/13/14)
    double scaledSize = baseSize * scaleFactor;
    // Clamp so font never gets unreasonably tiny or huge
    return clampDouble(scaledSize, baseSize * 0.85, baseSize * 1.35);
  }

  /// Get responsive grid cross axis count
  static int gridCrossAxisCount(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1024) return desktop;
    if (width >= 600) return tablet;
    return mobile;
  }

  /// Get responsive horizontal padding
  static EdgeInsets pagePadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1024) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    } else if (width >= 600) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    }
  }
}

extension ResponsiveExtension on BuildContext {
  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);
  double get screenWidth => Responsive.screenWidth(this);
  double get screenHeight => Responsive.screenHeight(this);
  double respFont(double baseSize) => Responsive.fontSize(this, baseSize);
}
