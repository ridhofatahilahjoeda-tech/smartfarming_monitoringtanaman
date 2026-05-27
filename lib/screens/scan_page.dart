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

class _ScanPageState extends State<ScanPage> with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isImageSelected = false;
  File? _selectedImage;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _fadeController;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(_pulseController);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadRiwayat() async {
    await RiwayatService.loadRiwayat();
  }

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt, size: 22, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'Scan',
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
            icon: const Icon(Icons.history, color: Colors.white),
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _pulseAnimation,
                      child: const Text(
                        '🔬 Menganalisis gambar...\nMohon tunggu sebentar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : FadeTransition(
              opacity: _fadeController,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      height: 360,
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: _isImageSelected && _selectedImage != null
                            ? Stack(
                                children: [
                                  Image.file(
                                    _selectedImage!,
                                    width: double.infinity,
                                    height: 360,
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.6),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 20,
                                    left: 20,
                                    right: 20,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryGreen,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryGreen.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'Gambar siap dianalisis',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                color: Colors.grey[100],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TweenAnimationBuilder(
                                      tween: Tween<double>(begin: 0.8, end: 1.0),
                                      duration: const Duration(milliseconds: 1000),
                                      curve: Curves.elasticOut,
                                      builder: (context, double value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: Container(
                                            padding: const EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryGreen.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.photo_camera,
                                              size: 60,
                                              color: AppTheme.primaryGreen.withOpacity(0.6),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Belum ada gambar',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ambil foto atau pilih dari galeri',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImageFromCamera,
                            icon: const Icon(Icons.camera_alt, size: 24),
                            label: const Text(
                              'Ambil Foto',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          OutlinedButton.icon(
                            onPressed: _pickImageFromGallery,
                            icon: const Icon(Icons.photo_library, size: 24),
                            label: const Text(
                              'Pilih dari Galeri',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryGreen,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(color: AppTheme.primaryGreen, width: 1.5),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue.shade700,
                                  size: 22,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    'Fitur ini akan mendeteksi penyakit tanaman berdasarkan gambar daun. Hasil deteksi bersifat simulasi untuk demo.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.4,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}