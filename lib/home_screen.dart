import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'user_session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Admin';
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserAndPending();
  }

  Future<void> _loadUserAndPending() async {
    final name = await UserSession.getUserName();
    final list = await DbHelper.instance.getPelangganByStatus(0);
    if (!mounted) return;
    setState(() {
      _userName = name ?? 'Admin';
      _pendingCount = list.length;
    });
  }

  Future<void> _navigateAndRefresh(String route) async {
    await Navigator.pushNamed(context, route);
    await _loadUserAndPending();
  }

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
                        Text(
                          'Hi, $_userName',
                          style: const TextStyle(
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
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
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
                          '$_pendingCount Data Pending',
                          style: const TextStyle(color: Color(0xFFEFFFF8)),
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
                          onTap: () => _navigateAndRefresh('/tasks'),
                        ),
                        _MenuTile(
                          title: 'Input Pelanggan',
                          icon: Icons.edit_document,
                          color: const Color(0xFF0AA06E),
                          onTap: () => _navigateAndRefresh('/input'),
                        ),
                        _MenuTile(
                          title: 'Riwayat',
                          icon: Icons.history,
                          color: const Color(0xFFF08A00),
                          onTap: () => _navigateAndRefresh('/riwayat'),
                        ),
                        _MenuTile(
                          title: 'Sinkronisasi',
                          icon: Icons.sync,
                          color: const Color(0xFF6756E8),
                          onTap: () => _navigateAndRefresh('/sinkronisasi'),
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
