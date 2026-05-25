class RiwayatScanModel {
  final String id;
  final String tanggal;
  final String waktu;
  final String penyakit;
  final int confidence;
  final String imagePath;
  final Map<String, dynamic> hasilDeteksi;

  RiwayatScanModel({
    required this.id,
    required this.tanggal,
    required this.waktu,
    required this.penyakit,
    required this.confidence,
    required this.imagePath,
    required this.hasilDeteksi,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal,
      'waktu': waktu,
      'penyakit': penyakit,
      'confidence': confidence,
      'imagePath': imagePath,
      'hasilDeteksi': hasilDeteksi,
    };
  }

  factory RiwayatScanModel.fromMap(Map<String, dynamic> map) {
    return RiwayatScanModel(
      id: map['id'],
      tanggal: map['tanggal'],
      waktu: map['waktu'],
      penyakit: map['penyakit'],
      confidence: map['confidence'],
      imagePath: map['imagePath'],
      hasilDeteksi: map['hasilDeteksi'],
    );
  }
}