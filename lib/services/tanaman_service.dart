import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tanaman_model.dart';
import 'dart:async';

class TanamanService {
  static const String _keyTanamanList = 'tanaman_list';
  static List<TanamanModel> _tanamanList = [];

  // Load data dari penyimpanan
  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString(_keyTanamanList);
    
    if (dataString != null && dataString.isNotEmpty) {
      // Jika ada data tersimpan, load dari situ
      final List<dynamic> decodedData = json.decode(dataString);
      _tanamanList = decodedData.map((item) => TanamanModel.fromMap(item)).toList();
    } else {
      // Jika belum ada data, gunakan data default
      _tanamanList = _getDefaultData();
      await saveData(); // Simpan data default
    }
  }

  // Data
  static List<TanamanModel> _getDefaultData() {
    return [
      TanamanModel(
        id: '1',
        nama: 'Padi Ciherang',
        lokasi: 'Lahan A - Blok Timur',
        status: 'Sehat',
        tanggalTanam: '15 Maret 2026',
        umur: 60,
        deskripsi: 'Padi varietas Ciherang memiliki produktivitas tinggi dan tahan terhadap hama wereng.',
        riwayatPerawatan: [
          '19 Mar 2026: Pemupukan urea 100 kg/ha',
          '25 Mar 2026: Penyiangan gulma',
          '01 Apr 2026: Pengairan rutin',
        ],
        rekomendasi: 'Panen dalam 30-40 hari ke depan. Jaga kelembaban tanah.',
        imagePath: null, // Tidak ada foto default
      ),
      TanamanModel(
        id: '2',
        nama: 'Cabai Keriting',
        lokasi: 'Lahan B - Greenhouse',
        status: 'Perlu Perhatian',
        tanggalTanam: '01 April 2026',
        umur: 45,
        deskripsi: 'Cabai keriting varietas Lado F1, produktif dan tahan penyakit layu.',
        riwayatPerawatan: [
          '05 Apr 2026: Pemupukan dasar NPK',
          '10 Apr 2026: Pemasangan mulsa plastik',
        ],
        rekomendasi: 'Terdeteksi hama kutu daun. Segera lakukan pengendalian.',
        imagePath: null, // Tidak ada foto default

      ),
    ];
  }

  // Simpan data ke penyimpanan
  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> dataToSave = 
        _tanamanList.map((tanaman) => tanaman.toMap()).toList();
    final String jsonString = json.encode(dataToSave);
    await prefs.setString(_keyTanamanList, jsonString);
  }

  // READ: Get all tanaman
  static List<TanamanModel> getAllTanaman() {
    return List.from(_tanamanList);
  }

  // READ: Get tanaman by id
  static TanamanModel? getTanamanById(String id) {
    try {
      return _tanamanList.firstWhere((tanaman) => tanaman.id == id);
    } catch (e) {
      return null;
    }
  }

  // CREATE: Tambah tanaman baru
  static Future<void> addTanaman(TanamanModel tanaman) async {
    final newTanaman = tanaman.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    _tanamanList.add(newTanaman);
    await saveData(); // Simpan setelah menambah
  }

  // UPDATE: Edit tanaman
  static Future<void> updateTanaman(TanamanModel updatedTanaman) async {
    final index = _tanamanList.indexWhere((t) => t.id == updatedTanaman.id);
    if (index != -1) {
      _tanamanList[index] = updatedTanaman;
      await saveData(); // Simpan setelah update
    }
  }

  // DELETE: Hapus tanaman
  static Future<void> deleteTanaman(String id) async {
    _tanamanList.removeWhere((tanaman) => tanaman.id == id);
    await saveData(); // Simpan setelah hapus
  }

  // Get tanaman berdasarkan status
  static List<TanamanModel> getTanamanByStatus(String status) {
    return _tanamanList.where((tanaman) => tanaman.status == status).toList();
  }

  // Search tanaman berdasarkan nama
  static List<TanamanModel> searchTanaman(String query) {
    if (query.isEmpty) return _tanamanList;
    return _tanamanList
        .where((tanaman) =>
            tanaman.nama.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}