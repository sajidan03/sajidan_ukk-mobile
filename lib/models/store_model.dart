class StoreResponse {
  final bool success;
  final String message;
  final Store data;

  StoreResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StoreResponse.fromJson(Map<String, dynamic> json) {
    return StoreResponse(
      success: json['success'],
      message: json['message'],
      data: Store.fromJson(json['data']),
    );
  }
}

class Store {
  final int idToko;
  final String namaToko;
  final String deskripsi;
  final String gambar;
  final String kontakToko;
  final String alamat;
  final String tanggalDibuat;

  Store({
    required this.idToko,
    required this.namaToko,
    required this.deskripsi,
    required this.gambar,
    required this.kontakToko,
    required this.alamat,
    required this.tanggalDibuat,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      idToko: json['id_toko'],
      namaToko: json['nama_toko'],
      deskripsi: json['deskripsi'],
      gambar: json['gambar'],
      kontakToko: json['kontak_toko'],
      alamat: json['alamat'],
      tanggalDibuat: json['tanggal_dibuat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_toko': idToko,
      'nama_toko': namaToko,
      'deskripsi': deskripsi,
      'gambar': gambar,
      'kontak_toko': kontakToko,
      'alamat': alamat,
      'tanggal_dibuat': tanggalDibuat,
    };
  }

  String get formattedDate {
    try {
      final dateTime = DateTime.parse(tanggalDibuat.replaceAll(' ', 'T'));
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return tanggalDibuat;
    }
  }

  bool get hasImage {
    return gambar.isNotEmpty && gambar != 'https://learncode.biz.id/images/no-image.png';
  }
}