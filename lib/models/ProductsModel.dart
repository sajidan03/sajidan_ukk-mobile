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

  String get formattedPrice {
    final price = int.tryParse(harga) ?? 0;
    return 'Rp ${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
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