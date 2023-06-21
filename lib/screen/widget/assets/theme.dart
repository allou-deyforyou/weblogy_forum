import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Themes {
  const Themes._();

  static const Color primary = Color(0xFFFDB813);
  static const Color secondary = Color(0xFF000000);
  static const Color background = Color(0xFFEBE8E5);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: defaultTargetPlatform == TargetPlatform.iOS ? background : null,
      colorScheme: ColorScheme.fromSeed(
        primary: primary,
        seedColor: primary,
        onPrimary: Colors.white,
        onPrimaryContainer: Colors.white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0.0,
        clipBehavior: Clip.antiAlias,
        backgroundColor: defaultTargetPlatform == TargetPlatform.iOS ? background : null,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: CupertinoColors.systemFill, width: 0.8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(9.0)),
        ),
      ),
      dividerTheme: const DividerThemeData(space: 1.0, thickness: 1.0),
      cupertinoOverrideTheme: const NoDefaultCupertinoThemeData(
        barBackgroundColor: background,
      ),
    );
  }

  static ThemeData get darktTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CupertinoColors.black,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: primary,
        onPrimary: Colors.white,
        surface: CupertinoColors.black,
        onPrimaryContainer: Colors.black,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0.0,
        clipBehavior: Clip.antiAlias,
        backgroundColor: defaultTargetPlatform == TargetPlatform.iOS ? CupertinoColors.black : null,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: CupertinoColors.systemFill, width: 0.8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(9.0)),
        ),
      ),
      dividerTheme: const DividerThemeData(space: 1.0, thickness: 1.0),
      cupertinoOverrideTheme: const NoDefaultCupertinoThemeData(
        barBackgroundColor: CupertinoColors.black,
        brightness: Brightness.dark,
        textTheme: CupertinoTextThemeData(),
      ),
    );
  }
}
