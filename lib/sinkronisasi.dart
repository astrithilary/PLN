import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';
import 'db_helper.dart';

class SinkronisasiScreen extends StatefulWidget {
  const SinkronisasiScreen({super.key});

  @override
  State<SinkronisasiScreen> createState() => _SinkronisasiScreenState();
}

class _SinkronisasiScreenState extends State<SinkronisasiScreen>
    with TickerProviderStateMixin {
  final Logger _logger = Logger();
  bool _isSyncing = false;
  double _progress = 0.0;
  late AnimationController _animationController;
  int _pendingCount = 0;
  int _syncedCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _refreshCounts();
  }

  Future<void> _refreshCounts() async {
    final pending = await DbHelper.instance.getPelangganByStatus(0);
    final synced = await DbHelper.instance.getPelangganByStatus(1);
    if (!mounted) return;
    setState(() {
      _pendingCount = pending.length;
      _syncedCount = synced.length;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startSyncProcess() async {
    // 1. Cek Koneksi
    final connectivityResult = await Connectivity().checkConnectivity();
    final bool isOnline =
        connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet);

    if (!isOnline) {
      // [Offline]
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tidak ada koneksi')));
      return;
    }

    // [Online]
    final pendingRows = await DbHelper.instance.getPelangganByStatus(0);
    if (pendingRows.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data pending untuk disinkronkan.'),
        ),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
      _progress = 0.0;
    });

    // Loop Sync ke API Laravel
    await _syncToServer(pendingRows);

    if (!mounted) return;
    await _refreshCounts();

    if (mounted) {
      _showSuccessModal();
    }
  }

  Future<void> _syncToServer(List<Map<String, dynamic>> pendingRows) async {
    int totalItems = pendingRows.length;
    int processedItems = 0;

    for (var row in pendingRows) {
      if (!_isSyncing) break;

      try {
        // Kirim data ke API Laravel
        final success = await ApiService.savePelanggan(row);

        if (success) {
          // Jika ada foto, upload juga
          if (row['foto_path'] != null && row['foto_path'].isNotEmpty) {
            final fotoUploaded = await ApiService.uploadFoto(
              row['foto_path'],
              row['id'] as int,
            );
            if (fotoUploaded != null) {
              _logger.i('Foto berhasil diupload: $fotoUploaded');
            }
          }

          // Update status_sinkron = 1 di lokal
          await DbHelper.instance.updatePelangganStatus(row['id'] as int, 1);
          processedItems++;
        }
      } catch (e) {
        _logger.e('Error saat sync: $e');
      }

      // Update progress
      if (mounted) {
        setState(() {
          _progress = processedItems / totalItems;
        });
      }

      await Future.delayed(const Duration(milliseconds: 300));
    }

    // Selesai
    if (mounted) {
      setState(() {
        _progress = 1.0;
      });
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void _cancelSync() {
    setState(() {
      _isSyncing = false;
      _progress = 0.0;
    });
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 50,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sinkronisasi Berhasil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF102545),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Semua data telah tersinkronisasi dengan server',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1368D6),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _isSyncing = false;
                      _progress = 0.0;
                    });
                  },
                  child: const Text(
                    'Selesai',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText() {
    if (_progress == 0.0) {
      return '';
    } else if (_progress == 1.0) {
      return 'Selesai';
    } else {
      return 'Mensinkronkan...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1368D6),
        foregroundColor: Colors.white,
        title: const Text(
          'Sinkronisasi',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isSyncing) {
              _cancelSync();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Cards
            Row(
              children: [
                Expanded(
                  child: _StatusCard(
                    title: 'Pending',
                    count: _pendingCount.toString(),
                    color: const Color(0xFFEEC000),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusCard(
                    title: 'Berhasil',
                    count: _syncedCount.toString(),
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sync Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1368D6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSyncing ? null : _startSyncProcess,
                child: Text(
                  _isSyncing ? 'Sinkronisasi Berjalan...' : 'Sinkronisasi',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Progress Indicator
            if (_isSyncing)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE8FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getStatusText(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF102545),
                            ),
                          ),
                        ),
                        Text(
                          '${(_progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1368D6),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _cancelSync,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _progress == 1.0
                              ? const Color(0xFF10B981)
                              : const Color(0xFF1368D6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.count,
    required this.color,
  });

  final String title;
  final String count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x150A2540),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 6),
              Text(
                count,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
