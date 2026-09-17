import 'package:flutter/material.dart';

/// Palette lifted from the poster set: printed ink, uncoated cream stock,
/// and three flat spot colours that each own a screen.
class Pal {
  Pal._();

  static const black = Color(0xFF241F1A); // warm printing ink, never pure #000
  static const paper = Color(0xFFF2E6C6); // cream stock
  static const paperDeep = Color(0xFFE2D1A5); // second cream, for insets
  static const rust = Color(0xFFC4522E); // today's drop
  static const olive = Color(0xFF9C9440); // theories
  static const mustard = Color(0xFFE3A93C); // reveals, jars, highlights
  static const bruise = Color(0xFF6E7BA0); // cold accent, unsolved cases
}

/// Display face. If you add the optional font asset, set [_family] to 'Slab'.
const String? _family = null;

TextStyle display(double size, {Color color = Pal.black, double? spacing}) {
  return TextStyle(
    fontFamily: _family,
    fontSize: size,
    height: 0.92,
    fontWeight: FontWeight.w900,
    letterSpacing: spacing ?? -size * 0.02,
    color: color,
  );
}

TextStyle label(double size, {Color color = Pal.black, FontWeight w = FontWeight.w800}) {
  return TextStyle(
    fontSize: size,
    height: 1.1,
    fontWeight: w,
    letterSpacing: 0.9,
    color: color,
  );
}

TextStyle body(double size, {Color color = Pal.black, FontWeight w = FontWeight.w500}) {
  return TextStyle(fontSize: size, height: 1.42, fontWeight: w, color: color);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Pal.paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Pal.rust,
      primary: Pal.rust,
      surface: Pal.paper,
      brightness: Brightness.light,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Pal.black,
      selectionColor: Color(0x33C4522E),
    ),
  );
}
