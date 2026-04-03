import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'db_helper.dart';
import 'api_service.dart';

class InputDataScreen extends StatefulWidget {
  const InputDataScreen({super.key});

  @override
  State<InputDataScreen> createState() => _InputDataScreenState();
}

class _InputDataScreenState extends State<InputDataScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _idPelangganController = TextEditingController();
  final _alamatController = TextEditingController();
  final _dayaController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _idPelangganController.dispose();
    _alamatController.dispose();
    _dayaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (selectedImage != null) {
      setState(() {
        _image = selectedImage;
      });
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    final row = {
      'nama': _namaController.text,
      'id_pelanggan': _idPelangganController.text,
      'alamat': _alamatController.text,
      'daya': _dayaController.text,
      'foto_path': _image?.path,
      'status_sinkron': 0, // 0 = belum sinkron
    };

    // 1. Simpan ke database lokal (Offline-first)
    final id = await DbHelper.instance.insertPelanggan(row);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data berhasil disimpan offline')),
    );

    // 2. Cek koneksi internet
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      // 3. Jika online, coba sinkronisasi langsung
      row['id'] = id;
      try {
        bool success = await ApiService.savePelanggan(row);
        if (success) {
          if (row['foto_path'] != null) {
            await ApiService.uploadFoto(row['foto_path'] as String, id);
          }
          await DbHelper.instance.updatePelangganStatus(
            id,
            1,
          ); // 1 = sudah sinkron
        }
      } catch (e) {
        // Abaikan error jaringan, data sudah aman di lokal
      }
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Input Data Pelanggan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _FlatInput(hint: 'Nama Pelanggan', controller: _namaController),
              const SizedBox(height: 12),
              _FlatInput(
                hint: 'ID Pelanggan',
                controller: _idPelangganController,
              ),
              const SizedBox(height: 12),
              _FlatInput(hint: 'Alamat', controller: _alamatController),
              const SizedBox(height: 12),
              _FlatInput(hint: 'Daya Listrik', controller: _dayaController),
              const SizedBox(height: 18),
              if (_image != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(File(_image!.path)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(_image == null ? 'Ambil Foto' : 'Ubah Foto'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    backgroundColor: const Color(0xFF1368D6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _saveData,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(
                      color: Color(0xFF1368D6),
                      width: 1.2,
                    ),
                    foregroundColor: const Color(0xFF1368D6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
}

class _FlatInput extends StatelessWidget {
  const _FlatInput({required this.hint, required this.controller});

  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (value) =>
          value == null || value.isEmpty ? 'Wajib diisi' : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
