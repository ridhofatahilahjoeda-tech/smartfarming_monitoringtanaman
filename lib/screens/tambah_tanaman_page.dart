import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/tanaman_service.dart';  
import '../models/tanaman_model.dart';    
import '../themes/app_theme.dart';

class TambahTanamanPage extends StatefulWidget {
  const TambahTanamanPage({super.key});

  @override
  State<TambahTanamanPage> createState() => _TambahTanamanPageState();
}

class _TambahTanamanPageState extends State<TambahTanamanPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _namaController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _tanggalTanamController = TextEditingController();
  final _umurController = TextEditingController();
  final _deskripsiController = TextEditingController();
  
  String _selectedStatus = 'Sehat';
  final List<String> _statusOptions = ['Sehat', 'Perlu Perhatian'];
  
  // Riwayat perawatan
  final List<String> _riwayatPerawatan = [];
  final _riwayatController = TextEditingController();
  
  // Image picker
  String? _selectedImagePath;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isImageLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _tanggalTanamController.dispose();
    _umurController.dispose();
    _deskripsiController.dispose();
    _riwayatController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tanggalTanamController.text =
            '${picked.day} ${_getMonthName(picked.month)} ${picked.year}';
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }

  void _addRiwayat() {
    if (_riwayatController.text.isNotEmpty) {
      setState(() {
        _riwayatPerawatan.add(_riwayatController.text);
        _riwayatController.clear();
      });
    }
  }

  void _removeRiwayat(int index) {
    setState(() {
      _riwayatPerawatan.removeAt(index);
    });
  }

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pilih Foto Tanaman',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryGreen),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryGreen),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            if (_selectedImagePath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Hapus Foto'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImagePath = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    setState(() => _isImageLoading = true);
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      _showMessage('Gagal mengambil foto: $e');
    } finally {
      setState(() => _isImageLoading = false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() => _isImageLoading = true);
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      _showMessage('Gagal memilih gambar: $e');
    } finally {
      setState(() => _isImageLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _saveTanaman() async {
    if (_formKey.currentState!.validate()) {
      final newTanaman = TanamanModel(
        id: '',
        nama: _namaController.text,
        lokasi: _lokasiController.text,
        status: _selectedStatus,
        tanggalTanam: _tanggalTanamController.text,
        umur: int.parse(_umurController.text),
        deskripsi: _deskripsiController.text,
        riwayatPerawatan: _riwayatPerawatan,
        rekomendasi: 'Tanaman baru ditambahkan. Lakukan perawatan rutin.',
        imagePath: _selectedImagePath,
      );
      
      await TanamanService.addTanaman(newTanaman);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanaman berhasil ditambahkan!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tanaman Baru'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload Foto Tanaman
              _buildImageUploader(),
              const SizedBox(height: 24),
              
              // Nama Tanaman
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Tanaman',
                  prefixIcon: Icon(Icons.eco),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tanaman harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Lokasi
              TextFormField(
                controller: _lokasiController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi Lahan',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lokasi harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Status
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.health_and_safety),
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Row(
                      children: [
                        Icon(
                          status == 'Sehat' ? Icons.check_circle : Icons.warning,
                          color: status == 'Sehat' ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(status),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Tanggal Tanam
              TextFormField(
                controller: _tanggalTanamController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Tanam',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal tanam harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Umur (Hari)
              TextFormField(
                controller: _umurController,
                decoration: const InputDecoration(
                  labelText: 'Umur (Hari)',
                  prefixIcon: Icon(Icons.timer),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Umur harus diisi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Umur harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Deskripsi
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Tanaman',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Riwayat Perawatan
              const Text(
                'Riwayat Perawatan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _riwayatController,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: 10 Mei 2026: Pemupukan',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addRiwayat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _riwayatPerawatan.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.history, size: 20),
                      title: Text(_riwayatPerawatan[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeRiwayat(index),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Tombol Simpan
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveTanaman,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploader() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: _isImageLoading
            ? const Center(child: CircularProgressIndicator())
            : _selectedImagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(_selectedImagePath!),
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
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Ketuk untuk ganti foto',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ketuk untuk tambah foto',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ambil dari kamera atau galeri',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}