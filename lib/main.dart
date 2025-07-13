import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fontsをインポート

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
        textTheme: TextTheme(
          displaySmall:
              GoogleFonts.notoSansJp(fontSize: 45.0, color: Colors.black), // XL
          titleLarge:
              GoogleFonts.notoSansJp(fontSize: 22.0, color: Colors.black), // L
          bodyMedium: GoogleFonts.notoSansJp(
              fontSize: 14.0, color: Colors.black87), // M
          labelSmall: GoogleFonts.notoSansJp(
              fontSize: 12.0, color: Colors.black54), // S
          // その他のスタイルは必要に応じて定義
        ),
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
          displaySmall:
              GoogleFonts.notoSansJp(fontSize: 45.0, color: Colors.white), // XL
          titleLarge:
              GoogleFonts.notoSansJp(fontSize: 22.0, color: Colors.white), // L
          bodyMedium: GoogleFonts.notoSansJp(
              fontSize: 14.0, color: Colors.white70), // M
          labelSmall: GoogleFonts.notoSansJp(
              fontSize: 12.0, color: Colors.white70), // S
          // その他のスタイルは必要に応じて定義
        ),
      ),
    );
  }
}