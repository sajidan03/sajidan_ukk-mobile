class ProductResponse {
  final bool success;
  final String message;
  final Pagination pagination;
  final List<Product> data;

  ProductResponse({
    required this.success,
    required this.message,
    required this.pagination,
    required this.data,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
      data: List<Product>.from((json['data'] ?? []).map((x) => Product.fromJson(x))),
    );
  }
}

class Pagination {
  final int total;
  final int currentPage;
  final int lastPage;

  Pagination({
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
    );
  }
}

class Product {
  final int idProduk;
  final String namaProduk;
  final String idKategori;
  final String namaKategori;
  final String harga;
  final String stok;
  final String deskripsi;
  final String tanggalUpload;
  final Toko toko;
  final List<ProductImage> images;

  // Additional properties for CRUD operations
  int? id; // For update/delete operations

  Product({
    required this.idProduk,
    required this.namaProduk,
    required this.idKategori,
    required this.namaKategori,
    required this.harga,
    required this.stok,
    required this.deskripsi,
    required this.tanggalUpload,
    required this.toko,
    required this.images,
    this.id,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      idProduk: json['id_produk'] ?? 0,
      namaProduk: json['nama_produk'] ?? '',
      idKategori: json['id_kategori']?.toString() ?? '',
      namaKategori: json['kategori'] ?? json['nama_kategori'] ?? '', // FIX: handle kedua field
      harga: json['harga']?.toString() ?? '0',
      stok: json['stok']?.toString() ?? '0',
      deskripsi: json['deskripsi'] ?? '',
      tanggalUpload: json['tanggal_upload'] ?? '',
      toko: Toko.fromJson(json['toko'] ?? {}), // FIX: default empty map
      images: json['images'] != null && json['images'] is List
          ? List<ProductImage>.from(
              (json['images'] as List).map((x) => ProductImage.fromJson(x)))
          : [], // FIX: default empty list
      id: json['id'] ?? json['id_produk'],
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'id_kategori': int.tryParse(idKategori) ?? 0,
      'nama_produk': namaProduk,
      'harga': int.tryParse(harga) ?? 0,
      'stok': int.tryParse(stok) ?? 0,
      'deskripsi': deskripsi,
    };
  }

  factory Product.createNew({
    required int idKategori,
    required String namaProduk,
    required int harga,
    required int stok,
    required String deskripsi,
  }) {
    return Product(
      idProduk: 0,
      namaProduk: namaProduk,
      idKategori: idKategori.toString(),
      namaKategori: '',
      harga: harga.toString(),
      stok: stok.toString(),
      deskripsi: deskripsi,
      tanggalUpload: '',
      toko: Toko(id: '', nama: '', kontak: '', alamat: ''),
      images: [],
    );
  }

  Product copyWith({
    int? idKategori,
    String? namaProduk,
    int? harga,
    int? stok,
    String? deskripsi,
  }) {
    return Product(
      idProduk: idProduk,
      namaProduk: namaProduk ?? this.namaProduk,
      idKategori: idKategori?.toString() ?? this.idKategori,
      namaKategori: namaKategori ?? this.namaKategori,
      harga: harga?.toString() ?? this.harga,
      stok: stok?.toString() ?? this.stok,
      deskripsi: deskripsi ?? this.deskripsi,
      tanggalUpload: tanggalUpload,
      toko: toko,
      images: images,
      id: id ?? idProduk,
    );
  }

  String get formattedPrice {
    try {
      final price = int.tryParse(harga) ?? 0;
      return 'Rp ${price.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';
    } catch (e) {
      return 'Rp 0';
    }
  }

  int get intHarga => int.tryParse(harga) ?? 0;
  int get intStok => int.tryParse(stok) ?? 0;
  int get intIdKategori => int.tryParse(idKategori) ?? 0;
}

class Toko {
  final String id;
  final String nama;
  final String kontak;
  final String alamat;

  Toko({
    required this.id,
    required this.nama,
    required this.kontak,
    required this.alamat,
  });

  factory Toko.fromJson(Map<String, dynamic> json) {
    return Toko(
      id: json['id_toko']?.toString() ?? '',
      nama: json['nama_toko'] ?? '',
      kontak: json['kontak'] ?? '',
      alamat: json['alamat'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_toko': id,
      'nama_toko': nama,
      'kontak': kontak,
      'alamat': alamat,
    };
  }
}

class ProductImage {
  final int id;
  final String url;
  final String? urlGambar;

  ProductImage({
    required this.id,
    required this.url,
    this.urlGambar,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id_gambar'] ?? json['id'] ?? 0,
      url: json['url'] ?? json['url_gambar'] ?? '',
      urlGambar: json['url_gambar'],
    );
  }

  // Getter untuk URL yang aman
  String get imageUrl {
    return url.isNotEmpty ? url : (urlGambar ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
    };
  }
}

class ProductDetailResponse {
  final bool success;
  final String message;
  final Product data;

  ProductDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: Product.fromJson(json['data'] ?? {}),
    );
  }
}

class CategoryResponse {
  final bool success;
  final String message;
  final List<Category> data;

  CategoryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: List<Category>.from((json['data'] ?? []).map((x) => Category.fromJson(x))),
    );
  }
}

class Category {
  final int id;
  final String nama;

  Category({
    required this.id,
    required this.nama,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id_kategori'] ?? json['id'] ?? 0,
      nama: json['nama_kategori'] ?? json['nama'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kategori': id,
      'nama_kategori': nama,
    };
  }
}