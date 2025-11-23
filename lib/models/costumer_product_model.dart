class CustomerProduct {
  final int id;
  final String nama;
  final String kategori;
  final int harga;
  final int stok;
  final String deskripsi;
  final List<String> images;
  final Store store;
  final double rating;
  final int terjual;
  final DateTime createdAt;

  CustomerProduct({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.stok,
    required this.deskripsi,
    required this.images,
    required this.store,
    required this.rating,
    required this.terjual,
    required this.createdAt,
  });

  factory CustomerProduct.fromJson(Map<String, dynamic> json) {
    return CustomerProduct(
      id: json['id_produk'] ?? json['id'] ?? 0,
      nama: json['nama_produk'] ?? json['nama'] ?? '',
      kategori: json['kategori'] ?? json['nama_kategori'] ?? '',
      harga: int.tryParse(json['harga']?.toString() ?? '0') ?? 0,
      stok: int.tryParse(json['stok']?.toString() ?? '0') ?? 0,
      deskripsi: json['deskripsi'] ?? '',
      images: json['images'] != null && json['images'] is List
          ? List<String>.from(
              (json['images'] as List).map((x) => 
                x['url'] ?? x['url_gambar'] ?? ''))
          : [],
      store: Store.fromJson(json['toko'] ?? {}),
      rating: double.tryParse(json['rating']?.toString() ?? '4.5') ?? 4.5,
      terjual: json['terjual'] ?? json['jumlah_terjual'] ?? 0,
      createdAt: DateTime.parse(json['tanggal_upload'] ?? DateTime.now().toString()),
    );
  }

  String get formattedPrice {
    return 'Rp ${harga.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  String get shortDescription {
    if (deskripsi.length > 100) {
      return '${deskripsi.substring(0, 100)}...';
    }
    return deskripsi;
  }

  bool get isAvailable => stok > 0;
  bool get isPopular => terjual > 50;
}

class Store {
  final int id;
  final String nama;
  final String kontak;
  final String alamat;
  final String kota;
  final double rating;
  final int produkCount;

  Store({
    required this.id,
    required this.nama,
    required this.kontak,
    required this.alamat,
    required this.kota,
    required this.rating,
    required this.produkCount,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: int.tryParse(json['id_toko']?.toString() ?? '0') ?? 0,
      nama: json['nama_toko'] ?? '',
      kontak: json['kontak'] ?? '',
      alamat: json['alamat'] ?? '',
      kota: json['kota'] ?? '',
      rating: double.tryParse(json['rating_toko']?.toString() ?? '4.5') ?? 4.5,
      produkCount: json['jumlah_produk'] ?? 0,
    );
  }
}

class CustomerProductResponse {
  final bool success;
  final String message;
  final List<CustomerProduct> data;
  final int total;
  final int currentPage;
  final int lastPage;

  CustomerProductResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory CustomerProductResponse.fromJson(Map<String, dynamic> json) {
    return CustomerProductResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: List<CustomerProduct>.from(
          (json['data'] ?? []).map((x) => CustomerProduct.fromJson(x))),
      total: json['total'] ?? json['pagination']['total'] ?? 0,
      currentPage: json['current_page'] ?? json['pagination']['current_page'] ?? 1,
      lastPage: json['last_page'] ?? json['pagination']['last_page'] ?? 1,
    );
  }
}