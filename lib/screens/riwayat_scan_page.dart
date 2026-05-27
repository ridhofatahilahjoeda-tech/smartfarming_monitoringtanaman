import 'dart:io';
import 'package:flutter/material.dart';
import '../services/riwayat_service.dart';
import '../models/riwayat_scan_model.dart';
import '../themes/app_theme.dart';
import 'hasil_scan_page.dart';

class RiwayatScanPage extends StatefulWidget {
  const RiwayatScanPage({super.key});

  @override
  State<RiwayatScanPage> createState() => _RiwayatScanPageState();
}

class _RiwayatScanPageState extends State<RiwayatScanPage> {
  List<RiwayatScanModel> _riwayatList = [];

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  void _loadRiwayat() {
    setState(() {
      _riwayatList = RiwayatService.getAllRiwayat();
    });
  }

  Future<void> _clearAllRiwayat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Hapus Semua Riwayat'),
        content: const Text('Apakah Anda yakin ingin menghapus semua riwayat scan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await RiwayatService.clearAllRiwayat();
      _loadRiwayat();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua riwayat berhasil dihapus'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Scan'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        actions: [
          if (_riwayatList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllRiwayat,
            ),
        ],
      ),
      body: _riwayatList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat scan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lakukan scan untuk melihat riwayat di sini',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _riwayatList.length,
              itemBuilder: (context, index) {
                final riwayat = _riwayatList[index];
                final isSehat = riwayat.penyakit == 'Sehat';
                final Color statusColor = isSehat ? Colors.green : Colors.orange;
                
                // Cek apakah ada gambar
                final bool hasImage = riwayat.imagePath.isNotEmpty && File(riwayat.imagePath).existsSync();
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HasilScanPage(
                            hasilDeteksi: riwayat.hasilDeteksi,
                            capturedImage: riwayat.imagePath.isNotEmpty
                                ? File(riwayat.imagePath)
                                : null,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Thumbnail Gambar (jika ada) atau Icon (jika tidak ada)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: hasImage
                                  ? Image.file(
                                      File(riwayat.imagePath),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      isSehat ? Icons.health_and_safety : Icons.sick,
                                      size: 32,
                                      color: statusColor,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Informasi
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  riwayat.penyakit,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 12,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${riwayat.tanggal} • ${riwayat.waktu}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: FractionallySizedBox(
                                        widthFactor: riwayat.confidence / 100,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: statusColor,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${riwayat.confidence}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Tombol hapus individual
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text('Hapus Riwayat'),
                                  content: Text('Hapus scan "${riwayat.penyakit}" dari riwayat?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                              
                              if (confirmed == true) {
                                await RiwayatService.deleteRiwayat(riwayat.id);
                                _loadRiwayat();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Riwayat dihapus'),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          
                          const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}