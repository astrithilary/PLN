import 'package:flutter/material.dart';
import 'db_helper.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late Future<List<_RiwayatItem>> allItemsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    allItemsFuture = _loadItems();
  }

  Future<List<_RiwayatItem>> _loadItems() async {
    final rows = await DbHelper.instance.getPelanggan();
    return rows.map((r) {
      final status = r['status_sinkron'] == 1 ? 'Sync' : 'Pending';
      return _RiwayatItem(
        name: r['nama']?.toString() ?? '-',
        date: r['id_pelanggan']?.toString() ?? '-',
        status: status,
        statusColor: status == 'Sync'
            ? const Color(0xFF10B981)
            : const Color(0xFFEEC000),
      );
    }).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_RiwayatItem> _getFilteredItems(List<_RiwayatItem> allItems) {
    final selectedTab = _tabController.index;
    if (selectedTab == 0) {
      return allItems;
    } else if (selectedTab == 1) {
      return allItems.where((item) => item.status == 'Pending').toList();
    } else {
      return allItems.where((item) => item.status == 'Sync').toList();
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
          'Riwayat',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) {
            setState(() {});
          },
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Pending'),
            Tab(text: 'Sync'),
          ],
        ),
      ),
      body: FutureBuilder<List<_RiwayatItem>>(
        future: allItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          final filteredItems = _getFilteredItems(items);

          if (filteredItems.isEmpty) {
            return const Center(child: Text('Tidak ada riwayat data.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: filteredItems.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return _RiwayatItemWidget(item: item);
            },
          );
        },
      ),
    );
  }
}

class _RiwayatItemWidget extends StatelessWidget {
  const _RiwayatItemWidget({required this.item});

  final _RiwayatItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            item.name,
            style: const TextStyle(
              color: Color(0xFF1368D6),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                item.date,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: item.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    color: item.statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RiwayatItem {
  const _RiwayatItem({
    required this.name,
    required this.date,
    required this.status,
    required this.statusColor,
  });

  final String name;
  final String date;
  final String status;
  final Color statusColor;
}
