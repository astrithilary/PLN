import 'package:flutter/material.dart';
import 'task_item.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = [
      const TaskItem(
        'Elisabeth Anggraeni',
        'Jl. arimadidi atas blok C No.44',
        true,
      ),
      const TaskItem(
        'Elisabeth Anggraeni',
        'Jl. arimadidi atas blok C No.44',
        false,
      ),
      const TaskItem(
        'Elisabeth Anggraeni',
        'Jl. arimadidi atas blok C No.44',
        false,
      ),
      const TaskItem(
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
