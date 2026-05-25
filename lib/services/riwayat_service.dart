import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/riwayat_scan_model.dart';

class RiwayatService {
  static const String _keyRiwayat = 'riwayat_scan';
  static List<RiwayatScanModel> _riwayatList = [];

  // Load data dari penyimpanan
  static Future<void> loadRiwayat() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString(_keyRiwayat);
    
    if (dataString != null && dataString.isNotEmpty) {
      final List<dynamic> decodedData = json.decode(dataString);
      _riwayatList = decodedData.map((item) => RiwayatScanModel.fromMap(item)).toList();
    }
  }

  // Simpan data ke penyimpanan
  static Future<void> _saveRiwayat() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> dataToSave = 
        _riwayatList.map((riwayat) => riwayat.toMap()).toList();
    final String jsonString = json.encode(dataToSave);
    await prefs.setString(_keyRiwayat, jsonString);
  }

  // Ambil semua riwayat
  static List<RiwayatScanModel> getAllRiwayat() {
    return List.from(_riwayatList.reversed.toList()); // Urutkan dari yang terbaru
  }

  // Tambah riwayat baru
  static Future<void> addRiwayat(RiwayatScanModel riwayat) async {
    _riwayatList.add(riwayat);
    await _saveRiwayat();
  }

  // Hapus riwayat
  static Future<void> deleteRiwayat(String id) async {
    _riwayatList.removeWhere((item) => item.id == id);
    await _saveRiwayat();
  }

  // Hapus semua riwayat
  static Future<void> clearAllRiwayat() async {
    _riwayatList.clear();
    await _saveRiwayat();
  }
}