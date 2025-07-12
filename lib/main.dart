import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fontsをインポート
import 'package:pokemon_encyclopedia/screens/pokemon_list_screen.dart'; // PokemonListScreenをインポート

void main() {
  runApp(const MyApp());
}

/// アプリケーションのメインウィジェット
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Encyclopedia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF0F52BA, <int, Color>{
          50: Color(0xFFE3EAF4),
          100: Color(0xFFB8C9E3),
          200: Color(0xFF8AA5D0),
          300: Color(0xFF5C81BD),
          400: Color(0xFF3866AE),
          500: Color(0xFF0F52BA),
          600: Color(0xFF0D4BAF),
          700: Color(0xFF0B41A2),
          800: Color(0xFF083796),
          900: Color(0xFF042683),
        }),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: GoogleFonts.notoSansJp().fontFamily, // アプリ全体のフォントをNoto Sans JPに設定
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: MaterialColor(0xFF0F52BA, <int, Color>{
          50: Color(0xFFE3EAF4),
          100: Color(0xFFB8C9E3),
          200: Color(0xFF8AA5D0),
          300: Color(0xFF5C81BD),
          400: Color(0xFF3866AE),
          500: Color(0xFF0F52BA),
          600: Color(0xFF0D4BAF),
          700: Color(0xFF0B41A2),
          800: Color(0xFF083796),
          900: Color(0xFF042683),
        }),
        scaffoldBackgroundColor: const Color(0xFF121212), // ダークモードの背景色
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F52BA), // ダークモードのAppBar背景色をサファイアに統一
          foregroundColor: Colors.white, // ダークモードのAppBarテキスト・アイコン色
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.notoSansJp(color: Colors.white),
          displayMedium: GoogleFonts.notoSansJp(color: Colors.white),
          displaySmall: GoogleFonts.notoSansJp(color: Colors.white),
          headlineMedium: GoogleFonts.notoSansJp(color: Colors.white),
          headlineSmall: GoogleFonts.notoSansJp(color: Colors.white),
          titleLarge: GoogleFonts.notoSansJp(color: Colors.white),
          titleMedium: GoogleFonts.notoSansJp(color: Colors.white70),
          titleSmall: GoogleFonts.notoSansJp(color: Colors.white70),
          bodyLarge: GoogleFonts.notoSansJp(color: Colors.white),
          bodyMedium: GoogleFonts.notoSansJp(color: Colors.white70),
          labelLarge: GoogleFonts.notoSansJp(color: Colors.white),
          bodySmall: GoogleFonts.notoSansJp(color: Colors.white70),
          labelSmall: GoogleFonts.notoSansJp(color: Colors.white70),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.system, // システム設定に追従
      home: const PokemonListScreen(),
    );
  }
}