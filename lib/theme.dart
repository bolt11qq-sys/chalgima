import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dizayn tizimi ranglari (7-bo'lim)
  static const Color ink    = Color(0xFF15253F);  // asosiy, tugmalar, matn
  static const Color accent = Color(0xFF2E8B68);  // yashil: bajarildi, FAB, progress
  static const Color amber  = Color(0xFFE08A0B);  // streak bloki
  static const Color bg     = Color(0xFFF2F4F6);  // orqa fon
  static const Color grey   = Color(0xFF61708A);  // ikkilamchi matn
  static const Color line   = Color(0xFFE4E8EC);  // ajratuvchi chiziqlar
  static const Color red    = Color(0xFFC4453C);  // "Unutdim", qiyin kartochka

  // Fan ranglari
  static const List<Color> subjectColors = [
    Color(0xFF3E5FCC),
    Color(0xFF1F8F6B),
    Color(0xFFB4690E),
    Color(0xFF7C4DBC),
    Color(0xFFE08A0B),
    Color(0xFFC4453C),
  ];

  static ThemeData get lightTheme {
    final baseText = GoogleFonts.nunitoTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: ink,
        surface: Colors.white,
        error: red,
      ),
      textTheme: baseText.copyWith(
        displayLarge: baseText.displayLarge?.copyWith(color: ink, fontWeight: FontWeight.bold),
        titleLarge: baseText.titleLarge?.copyWith(color: ink, fontWeight: FontWeight.w700),
        bodyMedium: baseText.bodyMedium?.copyWith(color: ink),
        bodySmall: baseText.bodySmall?.copyWith(color: grey),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: line, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: ink),
        titleTextStyle: TextStyle(color: ink, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseText = GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme);
    const darkBg = Color(0xFF0F172A);
    const darkCard = Color(0xFF1E293B);
    const darkLine = Color(0xFF334155);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: Color(0xFF38BDF8),
        surface: darkCard,
        error: red,
      ),
      textTheme: baseText.copyWith(
        displayLarge: baseText.displayLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        titleLarge: baseText.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        bodyMedium: baseText.bodyMedium?.copyWith(color: Colors.white70),
        bodySmall: baseText.bodySmall?.copyWith(color: Color(0xFF94A3B8)),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkLine, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
