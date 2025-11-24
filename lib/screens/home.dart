import 'package:flutter/material.dart';
import 'package:skillpp_kelas12/screens/costumer_detail.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:skillpp_kelas12/models/products_model.dart';
import 'package:skillpp_kelas12/screens/profil.dart';
import 'package:skillpp_kelas12/screens/store.dart';
import 'package:skillpp_kelas12/services/product_service.dart';
import 'package:skillpp_kelas12/services/store_service.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<dynamic> _categories = []; // Changed to dynamic
  bool _isLoading = true;
  bool _isLoadingCategories = true;
  bool _isCheckingStore = true;
  bool _hasStore = false;
  String _errorMessage = '';
  String _categoryErrorMessage = '';
  int _currentIndex = 0;
  int? _selectedCategoryId;
  String _selectedCategoryName = 'Semua Kategori';
  final TextEditingController _searchController = TextEditingController();
  final Color primaryColor = const Color(0xFF3d3d7e);

  @override
  void initState() {
    super.initState();
    _checkStoreStatus();
    _loadCategories();
    _loadProducts();
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
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoryErrorMessage = '';
    });

    final result = await ProductService.getCategories();

    setState(() {
      _isLoadingCategories = false;
      
      if (result['success'] == true) {
        // Add "All Categories" option first
        _categories = [
          {'id_kategori': null, 'nama_kategori': 'Semua Kategori'}
        ];
        // Add API categories
        _categories.addAll(result['data'] as List<dynamic>);
      } else {
        _categoryErrorMessage = result['message'] ?? 'Gagal memuat kategori';
        // Fallback to static categories if API fails
        _categories = [
          {'id_kategori': null, 'nama_kategori': 'Semua Kategori'},
          {'id_kategori': 5, 'nama_kategori': 'Aksesoris'},
          {'id_kategori': 8, 'nama_kategori': 'Alat Musik'},
          {'id_kategori': 4, 'nama_kategori': 'ATK'},
          {'id_kategori': 2, 'nama_kategori': 'Buku'},
          {'id_kategori': 1, 'nama_kategori': 'Elektronik'},
          {'id_kategori': 7, 'nama_kategori': 'Hardware'},
          {'id_kategori': 9, 'nama_kategori': 'Kamera'},
          {'id_kategori': 10, 'nama_kategori': 'Perabot Sekolah'},
          {'id_kategori': 3, 'nama_kategori': 'Seragam'},
          {'id_kategori': 6, 'nama_kategori': 'Software'},
        ];
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kategori: $_categoryErrorMessage - Menggunakan data fallback'),
              backgroundColor: Colors.orange,
            ),
          );
        });
      }
    });
  }

  Future<void> _loadProducts({int? categoryId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = categoryId != null 
        ? await ProductService.getProductsByCategory(categoryId)
        : await ProductService.getProducts();

    setState(() {
      _isLoading = false;
      
      if (result['success'] == true) {
        final productResponse = result['data'] as ProductResponse;
        _products = productResponse.data;
        _filteredProducts = List.from(_products);
      } else {
        _errorMessage = result['message'] ?? 'Terjadi kesalahan';
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    });
  }

  void _filterByCategory(int? categoryId, String categoryName) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedCategoryName = categoryName;
      _searchController.clear(); // Clear search when changing category
    });

    _loadProducts(categoryId: categoryId);
  }

  void _searchProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(_products);
      } else {
        _filteredProducts = _products.where((product) =>
            product.namaProduk.toLowerCase().contains(query.toLowerCase()) ||
            product.deskripsi.toLowerCase().contains(query.toLowerCase()) ||
            product.namaKategori.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerProductDetailPage(productId: product.idProduk),
      ),
    );
  }

  void _contactSeller(String phoneNumber) async {
    String formattedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '62${formattedPhone.substring(1)}';
    } else if (!formattedPhone.startsWith('62')) {
      formattedPhone = '62$formattedPhone';
    }
    
    final url = 'https://wa.me/$formattedPhone?text=${Uri.encodeComponent('Halo, saya tertarik dengan produk Anda')}';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka WhatsApp'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    switch (index) {
      case 0: // Beranda
        break;
      case 1: // Toko Saya
        if (_hasStore) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StorePage()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Anda belum memiliki toko. Daftar terlebih dahulu di menu Profil.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          });
        }
        break;
      case 2: // Profil
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'SA Market',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    if (_isCheckingStore) {
      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
            label: 'Loading...',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      );
    }

    if (_hasStore) {
      return BottomNavigationBar(
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
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      );
    }

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store_mall_directory_outlined),
          label: 'Buka Toko',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty && _filteredProducts.isEmpty) {
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
              onPressed: () => _loadProducts(categoryId: _selectedCategoryId),
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
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
            SizedBox(height: 8),
            Text(
              'Kategori: $_selectedCategoryName',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _filterByCategory(null, 'Semua Kategori'),
              child: Text('Lihat Semua Produk'),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: _searchProducts,
              ),
            ),
          ),
        ),

        // Filter Kategori
        SliverToBoxAdapter(
          child: _buildCategoryFilter(),
        ),

        // Banner Promosi
        SliverToBoxAdapter(
          child: Container(
            height: 120,
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [primaryColor, Colors.lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 20,
                  top: 10,
                  child: Icon(Icons.shopping_bag, size: 60, color: Colors.white30),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Menyediakan peralatan sekolah & makanan ringan, dengan harga pelajar!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Diskon hingga 50% untuk produk pilihan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Header Produk
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🛍️ Semua Produk',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                if (_selectedCategoryId != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _selectedCategoryName,
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Grid Produk
        SliverPadding(
          padding: EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = _filteredProducts[index];
                return _buildProductCard(product);
              },
              childCount: _filteredProducts.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    if (_isLoadingCategories) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final categoryId = category['id_kategori'];
          final categoryName = category['nama_kategori'];
          final isSelected = _selectedCategoryId == categoryId;
          
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                categoryName,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                _filterByCategory(categoryId, categoryName);
              },
              backgroundColor: Colors.white,
              selectedColor: primaryColor,
              checkmarkColor: Colors.white,
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? primaryColor : Colors.grey[300]!,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => _navigateToProductDetail(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    image: product.images.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(product.images.first.url),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey[200],
                  ),
                  child: product.images.isEmpty
                      ? Icon(Icons.photo, size: 40, color: Colors.grey[400])
                      : null,
                ),
                
                // Badge Stok Habis
                if (product.intStok == 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'HABIS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Info Produk
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Produk
                    Text(
                      product.namaProduk,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),

                    // Harga
                    Text(
                      product.formattedPrice,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(height: 4),

                    // Kategori
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.namaKategori,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),

                    // Stok
                    Text(
                      'Stok: ${product.stok}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),

                    Spacer(),

                    // Tombol WhatsApp
                    if (product.intStok > 0)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.chat, size: 16),
                          label: Text(
                            'Chat',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _contactSeller(product.toko.kontak),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}