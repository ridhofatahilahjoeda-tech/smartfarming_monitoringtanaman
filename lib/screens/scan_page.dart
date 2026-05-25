import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../themes/app_theme.dart';
import '../services/riwayat_service.dart';
import '../models/riwayat_scan_model.dart';
import 'hasil_scan_page.dart';
import 'riwayat_scan_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _isLoading = false;
  bool _isImageSelected = false;
  File? _selectedImage;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    await RiwayatService.loadRiwayat();
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isImageSelected = true;
        });
        
        _analyzeImage();
      }
    } catch (e) {
      _showMessage('Gagal memuat gambar: $e');
    }
  }

  // Fungsi untuk mengambil foto dari kamera
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isImageSelected = true;
        });
        
        _analyzeImage();
      }
    } catch (e) {
      _showMessage('Gagal mengambil foto: $e');
    }
  }

  // Simulasi analisis gambar
  void _analyzeImage() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    
    final random = DateTime.now().second % 4;
    
    Map<String, dynamic> hasilDeteksi;
    String penyakit;
    int confidence;
    
    switch (random) {
      case 0:
        penyakit = 'Hawar Daun';
        confidence = 87;
        hasilDeteksi = {
          'penyakit': 'Hawar Daun',
          'namaIlmiah': 'Phytophthora infestans',
          'tingkatKeyakinan': 87,
          'gejala': [
            'Bercak coklat kehitaman pada daun',
            'Tepi bercak tidak beraturan',
            'Daun tampak seperti terbakar air panas',
            'Pada cuaca lembab muncul jamur putih',
          ],
          'rekomendasi': [
            'Gunakan fungisida berbahan aktif Mancozeb',
            'Semprotkan setiap 7-10 hari sekali',
            'Buang bagian tanaman yang terinfeksi',
            'Jaga sirkulasi udara antar tanaman',
          ],
          'tingkatKeparahan': 'Sedang',
        };
        break;
      case 1:
        penyakit = 'Bercak Daun';
        confidence = 76;
        hasilDeteksi = {
          'penyakit': 'Bercak Daun',
          'namaIlmiah': 'Cercospora spp',
          'tingkatKeyakinan': 76,
          'gejala': [
            'Bercak bulat kecil berwarna coklat',
            'Bercak dikelilingi warna kuning',
            'Daun menguning dan rontok',
            'Menyerang daun tua terlebih dahulu',
          ],
          'rekomendasi': [
            'Aplikasikan fungisida berbahan propiconazole',
            'Pangkas daun yang terinfeksi',
            'Hindari penyiraman sore hari',
            'Rotasi tanaman dengan keluarga berbeda',
          ],
          'tingkatKeparahan': 'Ringan',
        };
        break;
      case 2:
        penyakit = 'Karat Daun';
        confidence = 92;
        hasilDeteksi = {
          'penyakit': 'Karat Daun',
          'namaIlmiah': 'Puccinia spp',
          'tingkatKeyakinan': 92,
          'gejala': [
            'Bintik-bintik kecil berwarna oranye',
            'Bintik berubah menjadi coklat kehitaman',
            'Daun mengering dan menggulung',
            'Menyerang seluruh permukaan daun',
          ],
          'rekomendasi': [
            'Gunakan fungisida sistemik',
            'Semprot setiap 5-7 hari sekali',
            'Tanam varietas tahan karat',
            'Jaga jarak tanam tidak terlalu rapat',
          ],
          'tingkatKeparahan': 'Berat',
        };
        break;
      default:
        penyakit = 'Sehat';
        confidence = 95;
        hasilDeteksi = {
          'penyakit': 'Sehat',
          'namaIlmiah': 'Tidak terdeteksi',
          'tingkatKeyakinan': 95,
          'gejala': [
            'Daun berwarna hijau segar',
            'Tidak ada bercak atau kerusakan',
            'Tekstur daun normal',
            'Pertumbuhan optimal',
          ],
          'rekomendasi': [
            'Lanjutkan perawatan rutin',
            'Pantau secara berkala',
            'Pastikan nutrisi tercukupi',
            'Jaga kebersihan lingkungan tanam',
          ],
          'tingkatKeparahan': 'Tidak Ada',
        };
    }
    
    // Simpan ke riwayat
    final now = DateTime.now();
    final riwayat = RiwayatScanModel(
      id: now.millisecondsSinceEpoch.toString(),
      tanggal: '${now.day}/${now.month}/${now.year}',
      waktu: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      penyakit: penyakit,
      confidence: confidence,
      imagePath: _selectedImage?.path ?? '',
      hasilDeteksi: hasilDeteksi,
    );
    
    await RiwayatService.addRiwayat(riwayat);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HasilScanPage(
            hasilDeteksi: hasilDeteksi,
            capturedImage: _selectedImage,
          ),
        ),
      ).then((_) {
        setState(() {
          _isImageSelected = false;
          _selectedImage = null;
        });
      });
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt, size: 22),
            const SizedBox(width: 8),
            const Text(
              'Scan Tanaman',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RiwayatScanPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Container(
              color: Colors.black.withOpacity(0.9),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryGreen,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '🔬 Menganalisis gambar...\nMohon tunggu sebentar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Area Preview Gambar
                  Container(
                    height: 350,
                    width: double.infinity,
                    color: Colors.white,
                    child: _isImageSelected && _selectedImage != null
                        ? Stack(
                            children: [
                              Image.file(
                                _selectedImage!,
                                width: double.infinity,
                                height: 350,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.5),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                left: 16,
                                right: 16,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryGreen,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Gambar siap dianalisis',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_camera,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada gambar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Ambil foto atau pilih dari galeri',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Tombol Kamera
                        ElevatedButton.icon(
                          onPressed: _pickImageFromCamera,
                          icon: const Icon(Icons.camera_alt, size: 28),
                          label: const Text(
                            'Ambil Foto',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Tombol Galeri
                        OutlinedButton.icon(
                          onPressed: _pickImageFromGallery,
                          icon: const Icon(Icons.photo_library, size: 28),
                          label: const Text(
                            'Pilih dari Galeri',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: AppTheme.primaryGreen),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Informasi tambahan
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Fitur ini akan mendeteksi penyakit tanaman berdasarkan gambar daun. Hasil deteksi bersifat simulasi untuk demo.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}