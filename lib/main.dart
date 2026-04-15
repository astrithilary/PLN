import 'package:flutter/material.dart';
import 'riwayat.dart';
import 'profile.dart';
import 'sinkronisasi.dart';
import 'signup_screen.dart';
import 'login_screen.dart';
import 'input_data_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final initialRoute = token != null ? '/home' : '/';
  runApp(MainApp(initialRoute: initialRoute));
}

class MainApp extends StatelessWidget {
  final String initialRoute;
  const MainApp({super.key, required this.initialRoute});

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
      initialRoute: initialRoute,
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header dengan nama dan profile
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1368D6), Color(0xFF0D47A1)],
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hi, Carl',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Selamat Datang',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFE0E7FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF1368D6),
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Body content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0AA06E), Color(0xFF20C997)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Online',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          '10 Data Pending',
                          style: TextStyle(color: Color(0xFFEFFFF8)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Menu Grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1.12,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _MenuTile(
                          title: 'Daftar Tugas',
                          icon: Icons.assignment_outlined,
                          color: const Color(0xFF1368D6),
                          onTap: () => Navigator.pushNamed(context, '/tasks'),
                        ),
                        _MenuTile(
                          title: 'Input Pelanggan',
                          icon: Icons.edit_document,
                          color: const Color(0xFF0AA06E),
                          onTap: () => Navigator.pushNamed(context, '/input'),
                        ),
                        _MenuTile(
                          title: 'Riwayat',
                          icon: Icons.history,
                          color: const Color(0xFFF08A00),
                          onTap: () => Navigator.pushNamed(context, '/riwayat'),
                        ),
                        _MenuTile(
                          title: 'Sinkronisasi',
                          icon: Icons.sync,
                          color: const Color(0xFF6756E8),
                          onTap: () =>
                              Navigator.pushNamed(context, '/sinkronisasi'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = [
      const _TaskItem(
        'Elisabeth Anggraeni',
        'Jl. arimadidi atas blok C No.44',
        true,
      ),
      const _TaskItem(
        'Elisabeth Anggraeni',
        'Jl. arimadidi atas blok C No.44',
        false,
      ),
      const _TaskItem(
        'Elisabeth Anggraeni',
        'Jl. arimadidi atas blok C No.44',
        false,
      ),
      const _TaskItem(
        'Elisabeth Anggraeni',
        'Jl. arimadidi atas blok C No.44',
        false,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Tugas',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Daftar Tugas',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: tasks.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x150A2540),
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.name,
                          style: const TextStyle(
                            color: Color(0xFF1368D6),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          task.address,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              'Status',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: task.isDone
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                task.isDone ? 'Selesai' : 'Belum',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
              width: 1.3,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 29),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF102545),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskItem {
  const _TaskItem(this.name, this.address, this.isDone);

  final String name;
  final String address;
  final bool isDone;
}
