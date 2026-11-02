import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

// ─── Design Tokens ───────────────────────────────────────────────────────────
class SJColors {
  static const Color primary = Color(0xFFEA3F74);
  static const Color primaryLight = Color(0xFFF9ACC6);
  static const Color primarySurface = Color(0xFFFFF1F6);
  static const Color textMain = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const Color bg = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF7F8FA);

  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF7F8FA);

  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFC93659);
  static const Color warning = Color(0xFFF59E0B);

  static const List<Color> primaryGradient = [Color(0xFFEA3F74), Color(0xFFF9ACC6)];
}

class SJRadius {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 16;
  static const double xl = 14;
  static const double full = 999;
}

class SJShadow {
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.04),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.06),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
  static const List<BoxShadow> primary = [
    BoxShadow(
      color: Color.fromRGBO(234, 63, 116, 0.22),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}
// ─────────────────────────────────────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.manropeTextTheme().copyWith(
      displayLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w800, color: SJColors.textMain),
      displayMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w800, color: SJColors.textMain),
      displaySmall: GoogleFonts.manrope(
          fontWeight: FontWeight.w700, color: SJColors.textMain),
      headlineLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w800, color: SJColors.textMain),
      headlineMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w700, color: SJColors.textMain),
      headlineSmall: GoogleFonts.manrope(
          fontWeight: FontWeight.w700, color: SJColors.textMain),
      titleLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w700, color: SJColors.textMain),
      titleMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w600, color: SJColors.textMain),
      titleSmall: GoogleFonts.manrope(
          fontWeight: FontWeight.w600, color: SJColors.textMain),
      bodyLarge: GoogleFonts.manrope(color: SJColors.textMain),
      bodyMedium: GoogleFonts.manrope(color: SJColors.textSecondary),
      bodySmall: GoogleFonts.manrope(color: SJColors.textMuted, fontSize: 12),
      labelLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w700, color: SJColors.textMain),
      labelMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w600, color: SJColors.textSecondary),
      labelSmall: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          color: SJColors.textMuted,
          fontSize: 11),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SocialJoin',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: SJColors.primary,
        scaffoldBackgroundColor: SJColors.bg,
        textTheme: textTheme,
        colorScheme: ColorScheme.fromSeed(
          seedColor: SJColors.primary,
          primary: SJColors.primary,
          secondary: SJColors.primaryLight,
          surface: SJColors.surface,
          onPrimary: Colors.white,
          onSurface: SJColors.textMain,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: SJColors.surface,
          foregroundColor: SJColors.textMain,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          titleTextStyle: GoogleFonts.manrope(
            color: SJColors.textMain,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: const IconThemeData(
            color: SJColors.textMain,
            size: 22,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SJRadius.lg),
          ),
          color: SJColors.surface,
          surfaceTintColor: Colors.transparent,
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: SJColors.surfaceElevated,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SJRadius.md),
            borderSide: const BorderSide(color: SJColors.border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SJRadius.md),
            borderSide: const BorderSide(color: SJColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SJRadius.md),
            borderSide: const BorderSide(color: SJColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SJRadius.md),
            borderSide: const BorderSide(color: SJColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SJRadius.md),
            borderSide: const BorderSide(color: SJColors.error, width: 1.5),
          ),
          hintStyle: GoogleFonts.manrope(color: SJColors.textMuted, fontSize: 14),
          labelStyle: GoogleFonts.manrope(
              color: SJColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: SJColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SJRadius.xl),
            ),
            textStyle: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: SJColors.primary,
            side: const BorderSide(color: SJColors.border, width: 1.5),
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SJRadius.xl),
            ),
            textStyle: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: SJColors.primary,
            textStyle: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: SJColors.surface,
          selectedColor: SJColors.primarySurface,
          labelStyle: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600),
          side: const BorderSide(color: SJColors.border),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SJRadius.full)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        dividerTheme: const DividerThemeData(
          color: SJColors.border,
          thickness: 1,
          space: 0,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: SJColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          surfaceTintColor: Colors.transparent,
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SJRadius.lg)),
          surfaceTintColor: Colors.transparent,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SJRadius.sm)),
          contentTextStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: SJColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: SJColors.primary,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
