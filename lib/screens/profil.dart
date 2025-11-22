import 'package:flutter/material.dart';
import 'package:skillpp_kelas12/models/profil_model.dart';
import 'package:skillpp_kelas12/screens/login.dart';
import 'package:skillpp_kelas12/services/profil_service.dart';
import 'package:skillpp_kelas12/widgets/edit_profil_dialog.dart';
import 'package:skillpp_kelas12/services/login_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Profile? _profile;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await ProfileService.getProfile();

    setState(() {
      _isLoading = false;
      
      if (result['success'] == true) {
        final profileResponse = result['data'] as ProfileResponse;
        _profile = profileResponse.data;
      } else {
        _errorMessage = result['message'] ?? 'Terjadi kesalahan';
      }
    });
  }

  void _showEditProfileDialog() {
    if (_profile == null) return;
    
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(
        profile: _profile!,
        onProfileUpdated: _loadProfile,
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ubah Password'),
        content: Text('Gunakan fitur Edit Profil untuk mengubah password.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Keluar'),
        content: Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: Text(
              'Keluar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    // Panggil logout service untuk clear token
    await LoginService.logout();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil keluar'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Navigasi ke halaman login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()), // Ganti dengan halaman login Anda
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadProfile,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 64),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_profile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Data profil tidak ditemukan',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Header dengan avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 20),

          // Role badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getRoleColor(_profile!.role),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _profile!.role.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),

          // Card informasi profil
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileItem('Nama Lengkap', _profile!.nama, Icons.person),
                  _buildDivider(),
                  _buildProfileItem('Username', _profile!.username, Icons.alternate_email),
                  _buildDivider(),
                  _buildProfileItem('Kontak', _profile!.kontak, Icons.phone),
                  _buildDivider(),
                  _buildProfileItem('Bergabung', _profile!.formattedDate, Icons.calendar_today),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // ID User
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fingerprint, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'ID User: ${_profile!.idUser}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),

          // Tombol aksi
          Column(
            children: [
              _buildActionButton(
                'Edit Profil',
                Icons.edit,
                Colors.blue,
                _showEditProfileDialog,
              ),
              SizedBox(height: 12),
              _buildActionButton(
                'Ubah Password',
                Icons.lock,
                Colors.orange,
                _showChangePasswordDialog,
              ),
              SizedBox(height: 12),
              _buildActionButton(
                'Keluar',
                Icons.logout,
                Colors.red,
                _showLogoutConfirmation,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Colors.blue[700]),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: Colors.grey[300]),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'member':
        return Colors.green;
      case 'premium':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}