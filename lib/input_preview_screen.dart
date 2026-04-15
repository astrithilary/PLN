import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'db_helper.dart';

class InputPreviewScreen extends StatefulWidget {
  const InputPreviewScreen({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<InputPreviewScreen> createState() => _InputPreviewScreenState();
}

class _InputPreviewScreenState extends State<InputPreviewScreen> {
  bool _isSaving = false;

  String get _fotoPath => widget.data['foto_path']?.toString() ?? '';
  String get _nama => widget.data['nama']?.toString() ?? '-';
  String get _idPelanggan => widget.data['id_pelanggan']?.toString() ?? '-';
  String get _daya => widget.data['daya']?.toString() ?? '-';
  String get _alamat => widget.data['alamat']?.toString() ?? '-';

  Future<void> _saveOffline() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await DbHelper.instance.insertPelanggan(
        Map<String, dynamic>.from(widget.data),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildPhotoPreview() {
    if (_fotoPath.isEmpty) {
      return Container(
        color: const Color(0xFFF4F7FB),
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_outlined,
          size: 46,
          color: Color(0xFF99A3B3),
        ),
      );
    }

    if (kIsWeb) {
      return Image.network(
        _fotoPath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: const Color(0xFFF4F7FB),
          alignment: Alignment.center,
          child: const Icon(
            Icons.broken_image_outlined,
            size: 46,
            color: Color(0xFF99A3B3),
          ),
        ),
      );
    }

    final file = File(_fotoPath);
    if (!file.existsSync()) {
      return Container(
        color: const Color(0xFFF4F7FB),
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_outlined,
          size: 46,
          color: Color(0xFF99A3B3),
        ),
      );
    }

    return Image.file(file, fit: BoxFit.cover);
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isName = false,
    bool withDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label :',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isName ? FontWeight.w500 : FontWeight.w400,
                  color: isName
                      ? const Color(0xFF1368D6)
                      : const Color(0xFF4A4A4A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value.isEmpty ? '-' : value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isName ? FontWeight.w600 : FontWeight.w500,
                    color: isName
                        ? const Color(0xFF1368D6)
                        : const Color(0xFF4A4A4A),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (withDivider)
          const Divider(
            height: 1,
            color: Color(0xFFD5D8DD),
            thickness: 1,
            indent: 12,
            endIndent: 12,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D7EE8),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSaving ? null : () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFFEFEFEF),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 165,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFD9D9D9)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _buildPhotoPreview(),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFD9D9D9)),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              label: 'Nama',
                              value: _nama,
                              isName: true,
                            ),
                            _buildDetailRow(label: 'ID', value: _idPelanggan),
                            _buildDetailRow(label: 'Daya', value: _daya),
                            _buildDetailRow(
                              label: 'Alamat',
                              value: _alamat,
                              withDivider: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveOffline,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF3D7EE8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Simpan Offline',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
