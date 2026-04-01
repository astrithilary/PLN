import 'package:flutter/material.dart';
import 'riwayat.dart';
import 'profile.dart';
import 'sinkronisasi.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'task_list_screen.dart';
import 'input_data_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PLN Mobile Survey',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1368D6),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Color(0xFF102545),
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF102545),
          ),
          bodyMedium: TextStyle(color: Color(0xFF4D6180)),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/home': (_) => const HomeScreen(),
        '/tasks': (_) => const TaskListScreen(),
        '/input': (_) => const InputDataScreen(),
        '/riwayat': (_) => const RiwayatScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/sinkronisasi': (_) => const SinkronisasiScreen(),
      },
    );
  }
}
