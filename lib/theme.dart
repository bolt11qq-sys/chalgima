import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Yangi dizayn tizimi ranglari (sahifa rasmlari asosida)
  static const Color bg         = Color(0xFFF5F3EE); // Issiq qog'oz foni (warm linen)
  static const Color surface    = Color(0xFFFBFAF6); // Kartochkalar oq-krem yuzasi
  static const Color cardBorder = Color(0xFFE2DFD6); // Yupqa chegara chizig'i
  static const Color accent     = Color(0xFF2E6B4E); // Asosiy yashil (forest green)
  static const Color ink        = Color(0xFF1E2A24); // To'q matn (charcoal forest)
  static const Color grey       = Color(0xFF737A74); // Yordamchi kulrang matn
  static const Color line       = Color(0xFFE8E6E0); // Yupqa ajratuvchi chiziq
  static const Color darkCard   = Color(0xFF23312B); // To'q yashil kartochka (Kunni yakunlash)

  // Qo'shimcha urg'u ranglar va fonlar
  static const Color amber      = Color(0xFFD97706); // Streak va ogohlantirishlar
  static const Color amberBg    = Color(0xFFF4ECE1); // Streak va ogohlantirish nishoni foni
  static const Color mintBg     = Color(0xFFE6ECE5); // Och yashil nishon/ikonka foni
  static const Color blueBg     = Color(0xFFE8EEFA); // Och havorang nishon/ikonka foni
  static const Color red        = Color(0xFFC4453C); // "Unutdim", qiyin kartochka
  static const Color redBg      = Color(0xFFFDE8E8); // Qizil nishon foni

  // Fan ranglari (maketdagi ranglar)
  static const List<Color> subjectColors = [
    Color(0xFF3E5FCC), // Havorang / Ko'k (Kiberxavfsizlik)
    Color(0xFF2E6B4E), // To'q yashil (Ingliz tili)
    Color(0xFFB4690E), // Jigarrang / Zarg'aldoq (Flutter)
    Color(0xFF7C4DBC), // Siyohrang
    Color(0xFFE08A0B), // Sariq / Olovrang
    Color(0xFFC4453C), // Qizil
  ];

  // Umumiy kartochka bezagi
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: cardBorder, width: 1.0),
  );

  // Kvadrat yumaloq ikonka/tugma bezagi
  static BoxDecoration get squareIconDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: cardBorder, width: 1.0),
  );

  // Shrift stillari (Newsreader / Lora va Plus Jakarta Sans)
  static TextStyle serifTitle({
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.w600,
    Color color = ink,
  }) {
    return GoogleFonts.newsreader(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle serifSubheading({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w600,
    Color color = ink,
  }) {
    return GoogleFonts.newsreader(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle sansLabel({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w700,
    Color color = grey,
    double letterSpacing = 1.2,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle sansBody({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = ink,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static ThemeData get lightTheme {
    final baseText = GoogleFonts.plusJakartaSansTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: ink,
        surface: surface,
        error: red,
      ),
      textTheme: baseText.copyWith(
        displayLarge: GoogleFonts.newsreader(color: ink, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.newsreader(color: ink, fontWeight: FontWeight.w600, fontSize: 22),
        bodyLarge: baseText.bodyLarge?.copyWith(color: ink),
        bodyMedium: baseText.bodyMedium?.copyWith(color: ink),
        bodySmall: baseText.bodySmall?.copyWith(color: grey),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: ink),
        titleTextStyle: GoogleFonts.newsreader(color: ink, fontSize: 22, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cardBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cardBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseText = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);
    const darkBg = Color(0xFF131D18);
    const darkSurface = Color(0xFF1B2822);
    const darkBorder = Color(0xFF283931);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: Color(0xFF52B788),
        surface: darkSurface,
        error: red,
      ),
      textTheme: baseText.copyWith(
        displayLarge: GoogleFonts.newsreader(color: Colors.white, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.newsreader(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 22),
        bodyLarge: baseText.bodyLarge?.copyWith(color: Colors.white),
        bodyMedium: baseText.bodyMedium?.copyWith(color: Colors.white70),
        bodySmall: baseText.bodySmall?.copyWith(color: Color(0xFF9AA59F)),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.newsreader(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
      ),
    );
  }
}
