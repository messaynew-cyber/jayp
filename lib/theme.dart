import 'package:flutter/material.dart';

/// Heritage Noir palette — obsidian ground, velvet teal, liquid amber.
class AppColors {
  static const ground    = Color(0xFF0D0E12);
  static const surface   = Color(0xFF121317);
  static const surfaceHi = Color(0xFF191B21);
  static const accent    = Color(0xFF81D1F0);
  static const amber     = Color(0xFFFFB77D);
  static const text      = Color(0xFFE3E2E8);
  static const muted     = Color(0xFF717885);
  static const border    = Color(0x2A81D1F0);
  static const danger    = Color(0xFFE86A6A);
  static const good      = Color(0xFF57D98A);
}

const kMono = TextStyle(
  fontFamily: 'monospace',
  fontSize: 10,
  letterSpacing: 1.6,
  color: AppColors.muted,
);

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.ground,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      secondary: AppColors.amber,
      surface: AppColors.surface,
      error: AppColors.danger,
      onPrimary: AppColors.ground,
      onSurface: AppColors.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.ground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: AppColors.text),
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0x14FFFFFF),
      thickness: 1,
      space: 1,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.surfaceHi,
      contentTextStyle: TextStyle(color: AppColors.text),
      behavior: SnackBarBehavior.floating,
    ),
    splashFactory: InkSparkle.splashFactory,
  );
}

/// Amharic companion label — 9.5px, 62% opacity, per the heritage canon.
class Geez extends StatelessWidget {
  final String text;
  final double size;
  const Geez(this.text, {super.key, this.size = 9.5});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: size,
          color: AppColors.muted.withOpacity( 0.62),
          height: 1.4,
        ),
      );
}

/// Small-caps mono label used above every section.
class Eyebrow extends StatelessWidget {
  final String text;
  final Color? color;
  const Eyebrow(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 1,
            color: (color ?? AppColors.amber).withOpacity( 0.7),
          ),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: kMono.copyWith(color: color ?? AppColors.amber, fontSize: 9.5),
          ),
        ],
      );
}
