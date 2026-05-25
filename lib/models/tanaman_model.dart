class TanamanModel {
  final String id;
  final String nama;
  final String lokasi;
  final String status;
  final String tanggalTanam;
  final int umur;
  final String deskripsi;
  final List<String> riwayatPerawatan;
  final String rekomendasi;
  final String? imagePath; // Tambahkan field untuk menyimpan path gambar

  TanamanModel({
    required this.id,
    required this.nama,
    required this.lokasi,
    required this.status,
    required this.tanggalTanam,
    required this.umur,
    required this.deskripsi,
    required this.riwayatPerawatan,
    required this.rekomendasi,
    this.imagePath, // Tambahkan parameter opsional
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'lokasi': lokasi,
      'status': status,
      'tanggalTanam': tanggalTanam,
      'umur': umur,
      'deskripsi': deskripsi,
      'riwayatPerawatan': riwayatPerawatan,
      'rekomendasi': rekomendasi,
      'imagePath': imagePath, // Tambahkan ke map
    };
  }

  factory TanamanModel.fromMap(Map<String, dynamic> map) {
    return TanamanModel(
      id: map['id'] ?? '',
      nama: map['nama'] ?? '',
      lokasi: map['lokasi'] ?? '',
      status: map['status'] ?? 'Sehat',
      tanggalTanam: map['tanggalTanam'] ?? '',
      umur: map['umur'] ?? 0,
      deskripsi: map['deskripsi'] ?? '',
      riwayatPerawatan: List<String>.from(map['riwayatPerawatan'] ?? []),
      rekomendasi: map['rekomendasi'] ?? '',
      imagePath: map['imagePath'], // Ambil dari map
    );
  }

  TanamanModel copyWith({
    String? id,
    String? nama,
    String? lokasi,
    String? status,
    String? tanggalTanam,
    int? umur,
    String? deskripsi,
    List<String>? riwayatPerawatan,
    String? rekomendasi,
    String? imagePath,
  }) {
    return TanamanModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      lokasi: lokasi ?? this.lokasi,
      status: status ?? this.status,
      tanggalTanam: tanggalTanam ?? this.tanggalTanam,
      umur: umur ?? this.umur,
      deskripsi: deskripsi ?? this.deskripsi,
      riwayatPerawatan: riwayatPerawatan ?? this.riwayatPerawatan,
      rekomendasi: rekomendasi ?? this.rekomendasi,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}