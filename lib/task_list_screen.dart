import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';
import 'db_helper.dart';
import 'task_item.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<TaskItem> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      // 1. Cek Koneksi
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool isOnline =
          connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet);

      if (isOnline) {
        // [Online] Request Tugas API
        final dataTugas = await ApiService.fetchTugas();

        if (dataTugas != null) {
          // Format ke Map database
          List<Map<String, dynamic>> dbList = dataTugas
              .map(
                (t) => {
                  'id':
                      t['id'] ??
                      t['id_tugas'] ??
                      (tasks.length + 1), // Pastikan ada ID unik
                  'nama_pelanggan':
                      t['nama_pelanggan'] ?? t['nama'] ?? 'Pelanggan',
                  'alamat': t['alamat'] ?? 'Alamat tidak tersedia',
                  'status': t['status'] == 1 || t['status'] == 'Selesai'
                      ? 1
                      : 0,
                },
              )
              .toList();

          // Simpan Cache di SQLite
          await DbHelper.instance.saveBatchTugas(dbList);
        } else {
          // Jika gagal fetch API namun online, ambil dari cache (fallback)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Gagal mengambil data dari server, menggunakan data cache',
                ),
              ),
            );
          }
        }
      } else {
        // [Offline] Tampilkan pesan info
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Anda sedang offline. Menampilkan data tersimpan.'),
            ),
          );
        }
      }

      // Ambil data (Tampilkan Data) dari SQLite baik online maupun offline
      final dataLokal = await DbHelper.instance.getTugas();

      setState(() {
        tasks = dataLokal
            .map(
              (t) => TaskItem(
                t['nama_pelanggan'] ?? '',
                t['alamat'] ?? '',
                t['status'] == 1,
              ),
            )
            .toList();

        // Data default jika DB kosong sepenuhnya
        if (tasks.isEmpty) {
          tasks = const [
            TaskItem(
              'Elisabeth Anggraeni',
              'Jl. arimadidi atas blok C No.44',
              true,
            ),
            TaskItem(
              'Elisabeth Anggraeni',
              'Jl. arimadidi atas blok C No.44',
              false,
            ),
          ];
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
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
