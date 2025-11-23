import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skillpp_kelas12/models/store_model.dart';
import 'package:skillpp_kelas12/services/login_service.dart';
import 'package:skillpp_kelas12/services/store_service.dart';
import 'package:skillpp_kelas12/widgets/edit_profil_dialog.dart';
import 'package:skillpp_kelas12/models/profil_model.dart';
import 'package:skillpp_kelas12/services/profil_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Profile? _userData;
  Store? _store;
  bool _isLoading = true;
  bool _isCheckingStore = true;
  bool _hasStore = false;
  String _errorMessage = '';

  // Controller untuk form pendaftaran toko
  final TextEditingController _namaTokoController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _kontakController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkStoreStatus();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await ProfileService.getProfile();
      
      if (result['success'] == true) {
        final profileResponse = result['data'] as ProfileResponse;
        setState(() {
          _userData = profileResponse.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Gagal memuat data profil';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data pengguna: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkStoreStatus() async {
    setState(() {
      _isCheckingStore = true;
    });

    final hasStore = await StoreService.hasStore();
    
    setState(() {
      _hasStore = hasStore;
      _isCheckingStore = false;
    });

    // Jika punya toko, load data toko
    if (hasStore) {
      _loadStoreData();
    }
  }

  Future<void> _loadStoreData() async {
    final result = await StoreService.getStore();
    if (result['success'] == true) {
      final storeResponse = result['data'] as StoreResponse;
      setState(() {
        _store = storeResponse.data;
      });
    }
  }

  void _showEditProfileDialog() {
    if (_userData == null) return;
    
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(
        profile: _userData!,
        onProfileUpdated: _loadUserData,
      ),
    );
  }

  void _showStoreRegistrationDialog() {
    // Reset form
    _namaTokoController.clear();
    _deskripsiController.clear();
    _kontakController.clear();
    _alamatController.clear();
    _selectedImagePath = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.add_business, color: Colors.blue),
                SizedBox(width: 8),
                Text('Daftar Toko Baru'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gambar Toko
                  GestureDetector(
                    onTap: () => _pickImage(setDialogState),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _selectedImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _selectedImagePath!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.photo, size: 40, color: Colors.grey[400]);
                                },
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, color: Colors.grey[400]),
                                SizedBox(height: 4),
                                Text(
                                  'Upload\nGambar',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Form Fields
                  TextField(
                    controller: _namaTokoController,
                    decoration: InputDecoration(
                      labelText: 'Nama Toko',
                      prefixIcon: Icon(Icons.store),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),

                  TextField(
                    controller: _deskripsiController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi Toko',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),

                  TextField(
                    controller: _kontakController,
                    decoration: InputDecoration(
                      labelText: 'Kontak (WhatsApp)',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                      hintText: '6281234567890',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 12),

                  TextField(
                    controller: _alamatController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Alamat Toko',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => _registerStore(),
                child: Text('Daftar Toko'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickImage(StateSetter setDialogState) async {
    // NOTE: Untuk simplicity, kita pakai URL gambar dummy
    setDialogState(() {
      _selectedImagePath = 'https://via.placeholder.com/150';
    });
  }

  Future<void> _registerStore() async {
    // Validasi form
    if (_namaTokoController.text.isEmpty ||
        _deskripsiController.text.isEmpty ||
        _kontakController.text.isEmpty ||
        _alamatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Semua field harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare data untuk API
    final storeData = {
      'nama_toko': _namaTokoController.text,
      'deskripsi': _deskripsiController.text,
      'kontak_toko': _kontakController.text,
      'alamat': _alamatController.text,
      'gambar': _selectedImagePath ?? '',
    };

    final result = await StoreService.registerStore(storeData);

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Toko berhasil didaftarkan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
        _checkStoreStatus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendaftarkan toko: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Logout'),
        content: Text('Yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await LoginService.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_userData != null)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: _showEditProfileDialog,
            ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
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
              onPressed: _loadUserData,
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_userData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Data pengguna tidak ditemukan',
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
          // Section Profil User
          _buildUserProfile(),
          SizedBox(height: 24),

          // Section Status Toko
          _buildStoreStatus(),
          SizedBox(height: 24),

          // Menu Lainnya
          _buildOtherMenus(),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Foto Profil - Default karena tidak ada dari API
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[100],
              ),
              child: Icon(Icons.person, size: 40, color: Colors.blue[700]),
            ),
            SizedBox(height: 16),

            // Nama User
            Text(
              _userData!.nama,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4),

            // Username (gunakan username karena tidak ada email)
            Text(
              '@${_userData!.username}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),

            // Role badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getRoleColor(_userData!.role),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _userData!.role.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 16),

            // ID User badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Text(
                'ID: ${_userData!.idUser}',
                style: TextStyle(
                  color: Colors.green[800],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 8),

            // Kontak
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  _userData!.kontak,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),

            // Tanggal Bergabung
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                SizedBox(width: 4),
                Text(
                  'Bergabung: ${_formatDate(_userData!.createdAt)}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'member':
        return Colors.blue;
      case 'seller':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildStoreStatus() {
    if (_isCheckingStore) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              CircularProgressIndicator(strokeWidth: 2),
              SizedBox(width: 16),
              Text('Memeriksa status toko...'),
            ],
          ),
        ),
      );
    }

    if (_hasStore && _store != null) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Toko Aktif',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Divider(),
              SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                      image: _store!.hasImage
                          ? DecorationImage(
                              image: NetworkImage(_store!.gambar),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: !_store!.hasImage
                        ? Icon(Icons.store, color: Colors.grey[400])
                        : null,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _store!.namaToko,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _store!.alamat,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.store_mall_directory),
                  label: Text('Kelola Toko Saya'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/store');
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Belum punya toko
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.store_mall_directory, color: Colors.orange, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Belum Punya Toko?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 12),
            Text(
              'Daftarkan toko Anda sekarang dan mulai berjualan! Nikmati fitur lengkap untuk mengelola produk Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.add_business),
                    label: Text('Daftar Toko Sekarang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _showStoreRegistrationDialog,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Gratis - Tidak dipungut biaya apapun',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherMenus() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMenuTile(
              'Riwayat Transaksi',
              Icons.history,
              Colors.purple,
              () {
                // Navigasi ke halaman riwayat transaksi
              },
            ),
            _buildMenuDivider(),
            _buildMenuTile(
              'Pengaturan Akun',
              Icons.settings,
              Colors.blueGrey,
              _showEditProfileDialog,
            ),
            _buildMenuDivider(),
            _buildMenuTile(
              'Bantuan & Support',
              Icons.help_outline,
              Colors.green,
              () {
                // Navigasi ke halaman bantuan
              },
            ),
            _buildMenuDivider(),
            _buildMenuTile(
              'Tentang Aplikasi',
              Icons.info_outline,
              Colors.blue,
              () {
                // Navigasi ke halaman tentang
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildMenuDivider() {
    return Divider(height: 1, color: Colors.grey[200]);
  }
}