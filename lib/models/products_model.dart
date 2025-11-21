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
      success: json['success'],
      message: json['message'],
      pagination: Pagination.fromJson(json['pagination']),
      data: List<Product>.from(json['data'].map((x) => Product.fromJson(x))),
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
      total: json['total'],
      currentPage: json['current_page'],
      lastPage: json['last_page'],
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

  // Constructor untuk create/update
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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      idProduk: json['id_produk'],
      namaProduk: json['nama_produk'],
      idKategori: json['id_kategori'],
      namaKategori: json['nama_kategori'],
      harga: json['harga'],
      stok: json['stok'],
      deskripsi: json['deskripsi'],
      tanggalUpload: json['tanggal_upload'],
      toko: Toko.fromJson(json['toko']),
      images: List<ProductImage>.from(
          json['images'].map((x) => ProductImage.fromJson(x))),
    );
  }

  // Untuk create new product
  Product.create({
    required this.idKategori,
    required this.namaProduk,
    required this.harga,
    required this.stok,
    required this.deskripsi,
  }) : 
    idProduk = 0,
    namaKategori = '',
    tanggalUpload = '',
    toko = Toko(nama: '', kontak: ''),
    images = [];

  // Untuk update product
  Product.update({
    required this.idProduk,
    required this.idKategori,
    required this.namaProduk,
    required this.harga,
    required this.stok,
    required this.deskripsi,
  }) : 
    namaKategori = '',
    tanggalUpload = '',
    toko = Toko(nama: '', kontak: ''),
    images = [];

  // Getter untuk ID (digunakan dalam update/delete)
  int? get id => idProduk;

  String get formattedPrice {
    final price = int.tryParse(harga) ?? 0;
    return 'Rp ${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  // Convert to JSON untuk create/update
  Map<String, dynamic> toJsonForCreate() {
    return {
      'id_kategori': int.parse(idKategori),
      'nama_produk': namaProduk,
      'harga': int.parse(harga),
      'stok': int.parse(stok),
      'deskripsi': deskripsi,
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    return {
      'id': idProduk,
      'id_kategori': int.parse(idKategori),
      'nama_produk': namaProduk,
      'harga': int.parse(harga),
      'stok': int.parse(stok),
      'deskripsi': deskripsi,
    };
  }
}

class Toko {
  final String nama;
  final String kontak;

  Toko({
    required this.nama,
    required this.kontak,
  });

  factory Toko.fromJson(Map<String, dynamic> json) {
    return Toko(
      nama: json['nama'],
      kontak: json['kontak'],
    );
  }
}

class ProductImage {
  final int id;
  final String url;

  ProductImage({
    required this.id,
    required this.url,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      url: json['url'],
    );
  }
}

// Model untuk kategori (jika diperlukan)
class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['nama_kategori'],
    );
  }
}