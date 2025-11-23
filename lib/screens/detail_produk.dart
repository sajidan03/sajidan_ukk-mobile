import 'package:flutter/material.dart';
import 'package:skillpp_kelas12/models/products_model.dart';
import 'package:skillpp_kelas12/services/product_service.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Product? _product;
  List<ProductImage> _productImages = [];
  bool _isLoading = true;
  bool _isLoadingImages = false;
  String _errorMessage = '';
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProductDetail();
    _loadProductImages();
  }

  Future<void> _loadProductDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await ProductService.getProductDetail(widget.productId);

    setState(() {
      _isLoading = false;
      
      if (result['success'] == true) {
        final productDetailResponse = result['data'] as ProductDetailResponse;
        _product = productDetailResponse.data;
      } else {
        _errorMessage = result['message'] ?? 'Terjadi kesalahan';
      }
    });
  }

  Future<void> _loadProductImages() async {
    setState(() {
      _isLoadingImages = true;
    });

    final result = await ProductService.getProductImages(widget.productId);

    setState(() {
      _isLoadingImages = false;
      
      if (result['success'] == true) {
        _productImages = result['data'] as List<ProductImage>;
        print('Loaded ${_productImages.length} additional images');
      } else {
        print('Error loading images: ${result['message']}');
      }
    });
  }

  List<ProductImage> get _allImages {
    final List<ProductImage> allImages = [];
    
    if (_product != null && _product!.images.isNotEmpty) {
      allImages.addAll(_product!.images);
    }
    
    if (_productImages.isNotEmpty) {
      allImages.addAll(_productImages);
    }
    
    return allImages;
  }

  void _showImageDialog(int index) {
    if (_allImages.isEmpty) return;
    
    final validIndex = index.clamp(0, _allImages.length - 1);
    final image = _allImages[validIndex];
    final imageUrl = image.imageUrl;
    
    if (imageUrl.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 24),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _loadProductDetail();
              _loadProductImages();
            },
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
              onPressed: () {
                _loadProductDetail();
                _loadProductImages();
              },
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_product == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Produk tidak ditemukan',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Utama
          _buildMainImage(),
          SizedBox(height: 20),

          if (_isLoadingImages)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Memuat gambar...',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

          if (_allImages.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                '${_allImages.length} gambar tersedia',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),

          // Nama Produk dan Harga
          Row(
            children: [
              Expanded(
                child: Text(
                  _product!.namaProduk,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          Text(
            _product!.formattedPrice,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          SizedBox(height: 16),

          // Kategori
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Text(
              _product!.namaKategori,
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 16),

          // Info Stok
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_2, color: Colors.grey[600]),
                SizedBox(width: 12),
                Text(
                  'Stok Tersedia: ${_product!.stok}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _product!.intStok > 0 ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _product!.intStok > 0 ? 'Tersedia' : 'Habis',
                    style: TextStyle(
                      color: _product!.intStok > 0 ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Deskripsi
          Text(
            'Deskripsi Produk',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              _product!.deskripsi,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 20),

          // Info Toko
          Text(
            'Informasi Toko',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.store, color: Colors.blue, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _product!.toko.nama,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.phone, color: Colors.green, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _product!.toko.kontak,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.orange, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _product!.toko.alamat,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Tanggal Upload
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Diupload: ${_product!.tanggalUpload}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMainImage() {
    final images = _allImages;
    
    if (images.isEmpty) {
      return Container(
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_photography, size: 60, color: Colors.grey[400]),
            SizedBox(height: 8),
            Text(
              'Tidak ada gambar',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Pastikan index valid
    if (_selectedImageIndex >= images.length) {
      _selectedImageIndex = 0;
    }

    final currentImage = images[_selectedImageIndex];
    final imageUrl = currentImage.imageUrl;

    return Column(
      children: [
        // Gambar utama
        GestureDetector(
          onTap: () => _showImageDialog(_selectedImageIndex),
          child: Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[200],
              image: imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 60, color: Colors.grey[400]),
                      SizedBox(height: 8),
                      Text(
                        'Gambar tidak tersedia',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ),
        SizedBox(height: 12),

        // Thumbnail images
        if (images.length > 1)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final thumbnail = images[index];
                final thumbnailUrl = thumbnail.imageUrl;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImageIndex = index;
                    });
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedImageIndex == index 
                            ? Colors.blue 
                            : Colors.transparent,
                        width: 2,
                      ),
                      color: Colors.grey[200],
                      image: thumbnailUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(thumbnailUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: thumbnailUrl.isEmpty
                        ? Icon(Icons.broken_image, color: Colors.grey[400])
                        : null,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}