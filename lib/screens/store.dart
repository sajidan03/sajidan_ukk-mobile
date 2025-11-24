import 'package:flutter/material.dart';
import 'package:skillpp_kelas12/models/products_model.dart';
import 'package:skillpp_kelas12/models/store_model.dart';
import 'package:skillpp_kelas12/services/product_service.dart';
import 'package:skillpp_kelas12/services/store_service.dart';
import 'package:skillpp_kelas12/widgets/edit_store_dialog.dart';
import 'package:skillpp_kelas12/widgets/product_form_dialog.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  Store? _store;
  List<Product> _products = [];
  bool _isLoading = true;
  bool _isLoadingProducts = true;
  String _errorMessage = '';
  String _productsErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadStore();
    _loadStoreProducts();
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

  Future<void> _loadStoreProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _productsErrorMessage = '';
    });

    final result = await ProductService.getProducts();

    setState(() {
      _isLoadingProducts = false;
      
      if (result['success'] == true) {
        final productResponse = result['data'] as ProductResponse;
        _products = productResponse.data;
      } else {
        _productsErrorMessage = result['message'] ?? 'Gagal memuat produk';
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

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        onSave: (product, images) async {
          final result = await ProductService.addProduct(product);
          
          print('Add Product Result: $result');
          
          if (result['success'] == true) {
            final productId = result['data']['id'] ?? 
                             result['data']['id_produk'] ?? 
                             result['data']['data']['id'] ??
                             result['data']['data']['id_produk'];
            
            print('Product ID from response: $productId');
            
            if (images.isNotEmpty && productId != null) {
              await ProductService.uploadImages(productId, images);
            }
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message'] ?? 'Produk berhasil ditambahkan'),
                  backgroundColor: Colors.green,
                ),
              );
              _loadStoreProducts();
              Navigator.pop(context);
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal menambah produk: ${result['message']}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        product: product,
        onSave: (updatedProduct, images) async {
          try {
            print('Starting update process...');
            print('Updated product data: ${updatedProduct.toJson()}');
            
            final result = await ProductService.updateProduct(updatedProduct);
            
            print('Update result: $result');
            
            if (result['success'] == true) {
              if (images.isNotEmpty) {
                final productId = result['data']['id'] ?? updatedProduct.id ?? updatedProduct.idProduk;
                if (productId != null) {
                  await ProductService.uploadImages(productId, images);
                }
              }
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Produk berhasil diupdate'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadStoreProducts();
                Navigator.pop(context);
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal update produk: ${result['message']}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } catch (e) {
            print('Error in edit dialog: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${product.namaProduk}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await ProductService.deleteProduct(product.id!);
              
              if (mounted) {
                if (result['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Produk berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadStoreProducts();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus produk: ${result['message']}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteStoreConfirmation() {
    if (_store == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Toko'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yakin ingin menghapus toko "${_store!.namaToko}"?'),
            SizedBox(height: 8),
            Text(
              'Tindakan ini akan:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('• Menghapus semua data toko'),
            Text('• Menghapus semua produk yang terkait'),
            Text('• Tidak dapat dikembalikan'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteStore();
            },
            child: Text(
              'Hapus Toko',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStore() async {
    if (_store == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Menghapus toko...'),
          ],
        ),
      ),
    );

    final result = await StoreService.deleteStore(_store!.idToko);

    // Close loading
    if (mounted) Navigator.pop(context);

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Toko berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Kembali ke halaman sebelumnya
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus toko: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            onPressed: () {
              _loadStore();
              _loadStoreProducts();
            },
          ),
          if (_store != null)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') _showEditStoreDialog();
                if (value == 'delete') _showDeleteStoreConfirmation();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit Toko'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Hapus Toko', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _store != null ? FloatingActionButton(
        onPressed: _showAddProductDialog,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ) : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // VALIDASI: Jika error karena tidak punya toko
    if (_errorMessage.isNotEmpty) {
      // Cek jika error terkait toko tidak ditemukan
      if (_errorMessage.toLowerCase().contains('toko') || 
          _errorMessage.toLowerCase().contains('store') ||
          _errorMessage.toLowerCase().contains('tidak ditemukan') ||
          _errorMessage.toLowerCase().contains('not found')) {
        return _buildNoStoreView();
      }
      
      // Error lainnya
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

    // VALIDASI: Jika store null (tidak punya toko)
    if (_store == null) {
      return _buildNoStoreView();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Section Profil Toko
          _buildStoreProfile(),
          SizedBox(height: 30),

          // Section Produk Toko
          _buildProductsSection(),
        ],
      ),
    );
  }

  // Tampilan ketika belum punya toko
  Widget _buildNoStoreView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon besar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.store_mall_directory_outlined,
                size: 60,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 24),

            // Judul
            Text(
              'Anda Belum Memiliki Toko',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),

            // Deskripsi
            Text(
              'Untuk mengakses halaman ini, Anda perlu mendaftarkan toko terlebih dahulu. Daftarkan toko Anda dan mulai berjualan sekarang!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),

            // Tombol daftar toko
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.add_business),
                    label: Text(
                      'Daftar Toko di Profil',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.arrow_back),
                    label: Text('Kembali ke Beranda'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Info tambahan
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pendaftaran toko gratis dan tidak dipungut biaya apapun',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 14,
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

  Widget _buildStoreProfile() {
    return Column(
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
        SizedBox(height: 20),

        // Tombol aksi toko
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
              'Hapus Toko',
              Icons.delete,
              Colors.red,
              _showDeleteStoreConfirmation,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Produk
        Row(
          children: [
            Text(
              '📦 Produk Toko',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Spacer(),
            Text(
              '${_products.length} Produk',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        if (_isLoadingProducts)
          Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_productsErrorMessage.isNotEmpty)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _productsErrorMessage,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
                TextButton(
                  onPressed: _loadStoreProducts,
                  child: Text('Coba Lagi'),
                ),
              ],
            ),
          )
        else if (_products.isEmpty)
          Container(
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'Belum ada produk',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tambahkan produk pertama Anda untuk mulai berjualan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Tambah Produk Pertama'),
                  onPressed: _showAddProductDialog,
                ),
              ],
            ),
          )
        else
          Column(
            children: _products.map((product) => _buildProductCard(product)).toList(),
          ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan nama produk dan action buttons
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.namaProduk,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit') _showEditProductDialog(product);
                    if (value == 'delete') _showDeleteConfirmation(product);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            
            // Kategori
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                product.namaKategori,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 8),
            
            // Harga dan Stok
            Row(
              children: [
                Text(
                  product.formattedPrice,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Stok: ${product.stok}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            
            // Deskripsi
            Text(
              product.deskripsi,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            
            // Gambar Produk
            _buildProductImages(product),
            
            // Tanggal Upload
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Upload: ${product.tanggalUpload}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImages(Product product) {
    if (product.images.isEmpty) {
      return Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_photography, color: Colors.grey[400]),
            SizedBox(height: 4),
            Text(
              'Tidak ada gambar',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: product.images.length,
        itemBuilder: (context, index) {
          final image = product.images[index];
          return Container(
            margin: EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                image.url,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image, color: Colors.grey[400]),
                  );
                },
              ),
            ),
          );
        },
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