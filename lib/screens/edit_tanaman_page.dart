import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/tanaman_service.dart'; 
import '../models/tanaman_model.dart';
import '../themes/app_theme.dart';

class EditTanamanPage extends StatefulWidget {
  final TanamanModel tanaman;

  const EditTanamanPage({super.key, required this.tanaman});

  @override
  State<EditTanamanPage> createState() => _EditTanamanPageState();
}

class _EditTanamanPageState extends State<EditTanamanPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _namaController;
  late TextEditingController _lokasiController;
  late TextEditingController _tanggalTanamController;
  late TextEditingController _umurController;
  late TextEditingController _deskripsiController;
  late TextEditingController _rekomendasiController;
  
  late String _selectedStatus;
  final List<String> _statusOptions = ['Sehat', 'Perlu Perhatian'];
  
  late List<String> _riwayatPerawatan;
  final _riwayatController = TextEditingController();
  
  // Image picker
  String? _selectedImagePath;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isImageLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.tanaman.nama);
    _lokasiController = TextEditingController(text: widget.tanaman.lokasi);
    _tanggalTanamController = TextEditingController(text: widget.tanaman.tanggalTanam);
    _umurController = TextEditingController(text: widget.tanaman.umur.toString());
    _deskripsiController = TextEditingController(text: widget.tanaman.deskripsi);
    _rekomendasiController = TextEditingController(text: widget.tanaman.rekomendasi);
    _selectedStatus = widget.tanaman.status;
    _riwayatPerawatan = List.from(widget.tanaman.riwayatPerawatan);
    _selectedImagePath = widget.tanaman.imagePath;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _tanggalTanamController.dispose();
    _umurController.dispose();
    _deskripsiController.dispose();
    _rekomendasiController.dispose();
    _riwayatController.dispose();
    super.dispose();
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
                'Ganti Foto Tanaman',
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

  void _updateTanaman() async {
    if (_formKey.currentState!.validate()) {
      final updatedTanaman = widget.tanaman.copyWith(
        nama: _namaController.text,
        lokasi: _lokasiController.text,
        status: _selectedStatus,
        tanggalTanam: _tanggalTanamController.text,
        umur: int.parse(_umurController.text),
        deskripsi: _deskripsiController.text,
        riwayatPerawatan: _riwayatPerawatan,
        rekomendasi: _rekomendasiController.text,
        imagePath: _selectedImagePath,
      );
      
      await TanamanService.updateTanaman(updatedTanaman);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanaman berhasil diperbarui!'),
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
        title: const Text('Edit Tanaman'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto Tanaman dengan tombol edit
              _buildImageWithEditButton(),
              const SizedBox(height: 24),
              
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
              
              TextFormField(
                controller: _tanggalTanamController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Tanam',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal tanam harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
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
              
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Tanaman',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _rekomendasiController,
                decoration: const InputDecoration(
                  labelText: 'Rekomendasi Perawatan',
                  prefixIcon: Icon(Icons.lightbulb),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              
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
                      foregroundColor: Colors.white,
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
                      onPressed: _updateTanaman,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Simpan Perubahan'),
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

  Widget _buildImageWithEditButton() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _isImageLoading
                ? const Center(child: CircularProgressIndicator())
                : (_selectedImagePath != null && File(_selectedImagePath!).existsSync())
                    ? Image.file(
                        File(_selectedImagePath!),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.green[50],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada foto',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}