import 'package:flutter/material.dart';
import 'package:skillpp_kelas12/models/store_model.dart';
import 'package:skillpp_kelas12/services/store_service.dart';
import 'package:skillpp_kelas12/widgets/edit_store_dialog.dart';

class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  Store? _store;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await StoreService.getStore();

    setState(() {
      _isLoading = false;
      
      if (result['success'] == true) {
        final storeResponse = result['data'] as StoreResponse;
        _store = storeResponse.data;
      } else {
        _errorMessage = result['message'] ?? 'Terjadi kesalahan';
      }
    });
  }

  void _showEditStoreDialog() {
    if (_store == null) return;
    
    showDialog(
      context: context,
      builder: (context) => EditStoreDialog(
        store: _store!,
        onStoreUpdated: _loadStore,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toko Saya'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadStore,
          ),
          if (_store != null)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: _showEditStoreDialog,
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
              onPressed: _loadStore,
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_store == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_mall_directory, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Data toko tidak ditemukan',
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
          // Header dengan gambar toko
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
              image: _store!.hasImage
                  ? DecorationImage(
                      image: NetworkImage(_store!.gambar),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _store!.hasImage
                ? null
                : Icon(
                    Icons.store,
                    size: 60,
                    color: Colors.grey[400],
                  ),
          ),
          SizedBox(height: 20),

          // Nama toko
          Text(
            _store!.namaToko,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),

          // ID Toko badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Text(
              'ID: ${_store!.idToko}',
              style: TextStyle(
                color: Colors.orange[800],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 20),

          // Card informasi toko
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildStoreItem('Deskripsi Toko', _store!.deskripsi, Icons.description),
                  _buildDivider(),
                  _buildStoreItem('Kontak', _store!.kontakToko, Icons.phone),
                  _buildDivider(),
                  _buildStoreItem('Alamat', _store!.alamat, Icons.location_on),
                  _buildDivider(),
                  _buildStoreItem('Bergabung', _store!.formattedDate, Icons.calendar_today),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),

          // Tombol aksi
          Column(
            children: [
              _buildActionButton(
                'Edit Toko',
                Icons.edit,
                Colors.blue,
                _showEditStoreDialog,
              ),
              SizedBox(height: 12),
              _buildActionButton(
                'Lihat Produk',
                Icons.inventory,
                Colors.green,
                () {
                  // Navigasi ke halaman produk toko
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => StoreProductsPage()));
                },
              ),
              SizedBox(height: 12),
              _buildActionButton(
                'Statistik',
                Icons.analytics,
                Colors.purple,
                () {
                  // Navigasi ke halaman statistik
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreItem(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
}