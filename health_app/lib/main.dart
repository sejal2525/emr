import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:health_app/screens/loginpage.dart';
import 'package:health_app/screens/structure.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDoNKF0DFjn43QdJj2UX0ucjjyw61bYnhg",
      appId: "1:772076741308:android:d3bd9ced9301cab293a6b9",
      messagingSenderId: "772076741308",
      projectId: "health-app-7dd5e",
    ),
  );
  runApp(const MyApp());
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Hospital App',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          
          // --- LIGHT THEME ---
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Soft Slate 50
            primaryColor: const Color(0xFF0284C7), // Sky Blue 600
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0284C7),
              secondary: Color(0xFF059669), // Emerald
              surface: Colors.white,
              background: Color(0xFFF8FAFC),
            ),
            textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
              bodyColor: const Color(0xFF334155), // Slate 700
              displayColor: const Color(0xFF0F172A), // Slate 900
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(color: Color(0xFF0284C7)),
              titleTextStyle: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: const Color(0xFF0284C7).withOpacity(0.3),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF0284C7), width: 2),
              ),
              prefixIconColor: const Color(0xFF0284C7),
              labelStyle: const TextStyle(color: Color(0xFF64748B)), // Slate 500
            ),
          ),

          // --- DARK THEME ---
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A), // Deep Space Blue
            primaryColor: const Color(0xFF06B6D4), // Vibrant Cyan
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF06B6D4),
              secondary: Color(0xFFD1FAE5), // Soft Mint
              surface: Color(0xFF1E293B),
              background: Color(0xFF0F172A),
            ),
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(color: Color(0xFF06B6D4)),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06B6D4),
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: const Color(0xFF06B6D4).withOpacity(0.5),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF1E293B),
              elevation: 8,
              shadowColor: Colors.black45,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: const Color(0xFF06B6D4).withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF06B6D4), width: 2),
              ),
              prefixIconColor: const Color(0xFF06B6D4),
              labelStyle: const TextStyle(color: Colors.white70),
            ),
          ),
          
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
                );
              }
              if (snapshot.hasData) {
                return const MyHome();
              } else {
                return const LoginPage();
              }
            },
          ),
        );
      },
    );
  }
}
