import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'user_session.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock data - ganti dengan API/database nanti
  late _ProfileData _profile;
  bool _isEditing = false;
  bool _isLoading = true;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _departmentController;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    try {
      // Cek apakah ada user yang login
      final loggedInUserName = await UserSession.getUserName();
      final loggedInUserEmail = await UserSession.getUserEmail();

      final profileData = await DbHelper.instance.getUserProfile();
      
      if (profileData != null) {
        _profile = _ProfileData(
          name: profileData['name'] ?? loggedInUserName ?? '',
          email: profileData['email'] ?? loggedInUserEmail ?? '',
          phone: profileData['phone'] ?? '',
          address: profileData['address'] ?? '',
          department: profileData['department'] ?? '',
          status: profileData['status'] ?? 'Online',
        );
      } else {
        // Default data jika belum ada profil di database
        // Gunakan nama dari user yang login
        _profile = _ProfileData(
          name: loggedInUserName ?? 'Admin',
          email: loggedInUserEmail ?? 'admin@pln.com',
          phone: '+62 812 3456 7890',
          address: 'Jl. Gatot Subroto No. 10, Jakarta',
          department: 'Survey & Inspection',
          status: 'Online',
        );
        // Simpan default data ke database
        await DbHelper.instance.saveUserProfile({
          'name': _profile.name,
          'email': _profile.email,
          'phone': _profile.phone,
          'address': _profile.address,
          'department': _profile.department,
          'status': _profile.status,
        });
      }

      _nameController = TextEditingController(text: _profile.name);
      _emailController = TextEditingController(text: _profile.email);
      _phoneController = TextEditingController(text: _profile.phone);
      _addressController = TextEditingController(text: _profile.address);
      _departmentController = TextEditingController(text: _profile.department);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Fallback ke default data jika ada error
      final loggedInUserName = await UserSession.getUserName();
      final loggedInUserEmail = await UserSession.getUserEmail();

      _profile = _ProfileData(
        name: loggedInUserName ?? 'Admin',
        email: loggedInUserEmail ?? 'admin@pln.com',
        phone: '+62 812 3456 7890',
        address: 'Jl. Gatot Subroto No. 10, Jakarta',
        department: 'Survey & Inspection',
        status: 'Online',
      );

      _nameController = TextEditingController(text: _profile.name);
      _emailController = TextEditingController(text: _profile.email);
      _phoneController = TextEditingController(text: _profile.phone);
      _addressController = TextEditingController(text: _profile.address);
      _departmentController = TextEditingController(text: _profile.department);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_isEditing) {
      _saveProfile();
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() async {
    try {
      final updatedProfile = _ProfileData(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        department: _departmentController.text,
        status: _profile.status,
      );

      // Simpan ke database
      await DbHelper.instance.saveUserProfile({
        'name': updatedProfile.name,
        'email': updatedProfile.email,
        'phone': updatedProfile.phone,
        'address': updatedProfile.address,
        'department': updatedProfile.department,
        'status': updatedProfile.status,
      });

      // Update state dengan data yang baru disimpan
      _profile = updatedProfile;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan profil'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF08A00),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logout berhasil')),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1368D6),
        foregroundColor: Colors.white,
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  // Reset
                  _nameController.text = _profile.name;
                  _emailController.text = _profile.email;
                  _phoneController.text = _profile.phone;
                  _addressController.text = _profile.address;
                  _departmentController.text = _profile.department;
                }
                _toggleEdit();
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : (_isEditing ? _buildEditForm() : _buildProfileView()),
    );
  }

  Widget _buildProfileView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header dengan profile picture
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1368D6), Color(0xFF0D47A1)],
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Color(0xFF1368D6),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _profile.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                      const SizedBox(width: 6),
                      Text(
                        _profile.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Profile Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ProfileInfoCard(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: _profile.email,
                  color: const Color(0xFF1368D6),
                ),
                const SizedBox(height: 12),
                _ProfileInfoCard(
                  icon: Icons.phone_outlined,
                  label: 'Nomor Telepon',
                  value: _profile.phone,
                  color: const Color(0xFF0AA06E),
                ),
                const SizedBox(height: 12),
                _ProfileInfoCard(
                  icon: Icons.location_on_outlined,
                  label: 'Alamat',
                  value: _profile.address,
                  color: const Color(0xFFF08A00),
                ),
                const SizedBox(height: 12),
                _ProfileInfoCard(
                  icon: Icons.business_outlined,
                  label: 'Departemen',
                  value: _profile.department,
                  color: const Color(0xFF6756E8),
                ),
              ],
            ),
          ),

          // (Delete profile removed)

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF08A00),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Edit Picture
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF4F7FB),
                      border: Border.all(
                        color: const Color(0xFF1368D6),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF1368D6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur upload foto sedang disiapkan'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Ubah Foto'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form Fields
            _EditTextField(
              controller: _nameController,
              label: 'Nama Lengkap',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 14),
            _EditTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            _EditTextField(
              controller: _phoneController,
              label: 'Nomor Telepon',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            _EditTextField(
              controller: _departmentController,
              label: 'Departemen',
              icon: Icons.business_outlined,
            ),
            const SizedBox(height: 14),
            _EditTextField(
              controller: _addressController,
              label: 'Alamat',
              icon: Icons.location_on_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _toggleEdit,
                child: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x150A2540),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF102545),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditTextField extends StatelessWidget {
  const _EditTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1368D6)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF1368D6),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }
}

class _ProfileData {
  String name;
  String email;
  String phone;
  String address;
  String department;
  String status;

  _ProfileData({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.department,
    required this.status,
  });
}
