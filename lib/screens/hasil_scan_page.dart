import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../themes/app_theme.dart';

class HasilScanPage extends StatelessWidget {
  final Map<String, dynamic> hasilDeteksi;
  final File? capturedImage;

  const HasilScanPage({
    super.key,
    required this.hasilDeteksi,
    this.capturedImage,
  });

  @override
  Widget build(BuildContext context) {
    final int confidence = hasilDeteksi['tingkatKeyakinan'];
    final Color confidenceColor = _getConfidenceColor(confidence);
    final bool isHealthy = hasilDeteksi['penyakit'] == 'Sehat';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(isHealthy ? 'Hasil Deteksi' : 'Hasil Deteksi Penyakit'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _shareResult(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Gambar dengan design lebih baik
            _buildImageCard(isHealthy),
            const SizedBox(height: 20),
            
            // Card Informasi Penyakit
            _buildPenyakitCard(isHealthy),
            const SizedBox(height: 20),
            
            // Card Tingkat Keyakinan (Progress Bar Halus)
            _buildConfidenceCard(confidence, confidenceColor),
            const SizedBox(height: 20),
            
            // Card Gejala (jika tidak sehat)
            if (!isHealthy) ...[
              _buildGejalaCard(),
              const SizedBox(height: 20),
            ],
            
            // Card Rekomendasi
            _buildRekomendasiCard(isHealthy),
            const SizedBox(height: 20),
            
            // Tombol Aksi
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  // ==================== FUNGSI SHARE ====================
  Future<void> _shareResult(BuildContext context) async {
    // Konversi List<dynamic> ke List<String> dengan aman
    final List<String> gejala = List<String>.from(hasilDeteksi['gejala'] ?? []);
    final List<String> rekomendasi = List<String>.from(hasilDeteksi['rekomendasi'] ?? []);
    
    // Membuat teks untuk dibagikan
    String shareText = '''
🌿 *HASIL DETEKSI SMART FARMING* 🌿

📋 *Penyakit:* ${hasilDeteksi['penyakit']}
📊 *Tingkat Keyakinan:* ${hasilDeteksi['tingkatKeyakinan']}%
⚠️ *Tingkat Keparahan:* ${hasilDeteksi['tingkatKeparahan']}

📝 *Gejala:*
${_formatList(gejala)}

💡 *Rekomendasi:*
${_formatList(rekomendasi)}

---
✨ Scan menggunakan aplikasi Smart Farming
    ''';
    
    try {
      // Jika ada gambar, share teks + gambar
      if (capturedImage != null && capturedImage!.existsSync()) {
        await Share.shareXFiles(
          [XFile(capturedImage!.path)],
          text: shareText,
        );
      } else {
        // Jika tidak ada gambar, share teks saja
        await Share.share(shareText);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membagikan hasil: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatList(List<String> items) {
    if (items.isEmpty) return '   - Tidak ada data\n';
    String result = '';
    for (int i = 0; i < items.length; i++) {
      result += '   ${i + 1}. ${items[i]}\n';
    }
    return result;
  }

  // ==================== CARD GAMBAR ====================
  Widget _buildImageCard(bool isHealthy) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.defaultShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isHealthy ? Colors.green.shade50 : Colors.red.shade50,
                isHealthy ? Colors.green.shade100 : Colors.red.shade100,
              ],
            ),
          ),
          child: capturedImage != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      capturedImage!,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isHealthy ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isHealthy ? Icons.check_circle : Icons.warning,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isHealthy ? 'SEHAT' : 'TERDETEKSI',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isHealthy ? Icons.eco : Icons.sick,
                        size: 70,
                        color: isHealthy ? Colors.green.shade400 : Colors.red.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isHealthy ? 'Daun dalam kondisi sehat' : hasilDeteksi['penyakit'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isHealthy ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isHealthy ? 'Tidak ada gejala penyakit' : 'Gambar simulasi deteksi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // ==================== CARD INFORMASI PENYAKIT ====================
  Widget _buildPenyakitCard(bool isHealthy) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.defaultShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        isHealthy ? Colors.green.shade400 : Colors.red.shade400,
                        isHealthy ? Colors.green.shade600 : Colors.red.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isHealthy ? Icons.health_and_safety : Icons.sick,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasilDeteksi['penyakit'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isHealthy) ...[
                        const SizedBox(height: 4),
                        Text(
                          hasilDeteksi['namaIlmiah'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (!isHealthy) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.warning_amber,
                      size: 18,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Tingkat Keparahan: ${hasilDeteksi['tingkatKeparahan']}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== CARD TINGKAT KEYAKINAN ====================
  Widget _buildConfidenceCard(int confidence, Color confidenceColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.defaultShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: confidenceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: confidenceColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tingkat Keyakinan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: confidence / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(confidenceColor),
                      minHeight: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: confidenceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$confidence%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: confidenceColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: confidenceColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    _getConfidenceIcon(confidence),
                    size: 18,
                    color: confidenceColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getConfidenceMessage(confidence),
                      style: TextStyle(
                        fontSize: 12,
                        color: confidenceColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CARD GEJALA ====================
  Widget _buildGejalaCard() {
    final List<String> gejala = List<String>.from(hasilDeteksi['gejala']);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.defaultShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.list_alt,
                    color: Colors.orange.shade700,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Gejala yang Terlihat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: gejala.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.circle,
                          size: 8,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          gejala[index],
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CARD REKOMENDASI ====================
  Widget _buildRekomendasiCard(bool isHealthy) {
    final List<String> rekomendasi = List<String>.from(hasilDeteksi['rekomendasi']);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isHealthy ? Colors.green.shade50 : Colors.blue.shade50,
            isHealthy ? Colors.green.shade100 : Colors.blue.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.defaultShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isHealthy ? Colors.green.shade200 : Colors.blue.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isHealthy ? Icons.eco : Icons.medical_services,
                    color: isHealthy ? Colors.green.shade700 : Colors.blue.shade700,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isHealthy ? 'Tips Perawatan' : 'Rekomendasi Penanganan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isHealthy ? Colors.green.shade800 : Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rekomendasi.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isHealthy ? Colors.green.shade200 : Colors.blue.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isHealthy ? Colors.green.shade700 : Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          rekomendasi[index],
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: isHealthy ? Colors.green.shade800 : Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TOMBOL AKSI ====================
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.camera_alt, size: 20),
            label: const Text('Scan Lagi'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: AppTheme.primaryGreen, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _showSuccessMessage(context, 'Laporan berhasil disimpan!');
            },
            icon: const Icon(Icons.save, size: 20),
            label: const Text('Simpan Laporan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== HELPER FUNCTIONS ====================
  Color _getConfidenceColor(int confidence) {
    if (confidence >= 80) return Colors.green;
    if (confidence >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getConfidenceIcon(int confidence) {
    if (confidence >= 80) return Icons.check_circle;
    if (confidence >= 60) return Icons.warning;
    return Icons.error;
  }

  String _getConfidenceMessage(int confidence) {
    if (confidence >= 80) return 'Tingkat keyakinan tinggi - Hasil deteksi akurat';
    if (confidence >= 60) return 'Tingkat keyakinan sedang - Perlu verifikasi manual';
    return 'Tingkat keyakinan rendah - Disarankan scan ulang';
  }

  void _showSuccessMessage(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppTheme.primaryGreen,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          elevation: 8,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}