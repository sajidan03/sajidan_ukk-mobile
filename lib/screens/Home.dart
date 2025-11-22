import 'package:flutter/material.dart';
import 'package:skillpp_kelas12/models/products_model.dart';
import 'package:skillpp_kelas12/screens/profil.dart';
import 'package:skillpp_kelas12/screens/store.dart';
import 'package:skillpp_kelas12/services/product_service.dart';
import 'package:skillpp_kelas12/widgets/product_form_dialog.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> _products = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentIndex = 0; // Index untuk bottom navigation

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await ProductService.getProducts();

    setState(() {
      _isLoading = false;
      
      if (result['success'] == true) {
        final productResponse = result['data'] as ProductResponse;
        _products = productResponse.data;
      } else {
        _errorMessage = result['message'] ?? 'Terjadi kesalahan';
      }
    });
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        onSave: (product, images) async {
          final result = await ProductService.addProduct(product);
          
          print('Add Product Result: $result');
          
          if (result['success'] == true) {
            // Handle product ID - bisa dari berbagai kemungkinan field
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
              _loadProducts();
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
              // Upload gambar jika ada gambar baru
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
                _loadProducts();
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
                  _loadProducts();
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

  // Method untuk menangani perubahan tab
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    switch (index) {
      case 0: // Beranda
        // Sudah di halaman beranda, tidak perlu navigasi
        break;
      case 1: // Toko Saya
        // Navigasi ke halaman toko saya
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StorePage()),
        );
        break;
      case 2: // Profil
        // Navigasi ke halaman profil
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddProductDialog,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Toko Saya',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
              onPressed: _loadProducts,
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Tidak ada produk tersedia',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showAddProductDialog,
              child: Text('Tambah Produk Pertama'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return ProductCard(
          product: product,
          onEdit: () => _showEditProductDialog(product),
          onDelete: () => _showDeleteConfirmation(product),
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
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
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
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
            
            // Info Toko
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.store, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      product.toko.nama,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    product.toko.kontak,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            
            // Gambar Produk
            _buildProductImages(),
            
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

  Widget _buildProductImages() {
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
}