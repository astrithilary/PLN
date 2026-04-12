import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _username = 'User';
  int _pendingCount = 0;
  bool _isOnline = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initConnectivity();
  }

  void _initConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult);

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      _isOnline =
          result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet);
    });
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingRows = await DbHelper.instance.getPelangganByStatus(0);

    setState(() {
      _username = prefs.getString('username') ?? 'User';
      _pendingCount = pendingRows.length;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
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
                          'Hi, $_username',
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
                      gradient: LinearGradient(
                        colors: _isOnline
                            ? const [Color(0xFF0AA06E), Color(0xFF20C997)]
                            : const [Color(0xFFE53935), Color(0xFFE35D5B)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isOnline
                                  ? Icons.check_circle_outline
                                  : Icons.wifi_off_outlined,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isOnline ? 'Online' : 'Offline',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
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
