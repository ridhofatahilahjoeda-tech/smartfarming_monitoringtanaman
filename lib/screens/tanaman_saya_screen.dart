import 'dart:io';
import 'package:flutter/material.dart';
import 'detail_tanaman_page.dart';
import 'tambah_tanaman_page.dart';
import '../services/tanaman_service.dart';  
import '../models/tanaman_model.dart';
import '../themes/app_theme.dart';

class TanamanSayaScreen extends StatefulWidget {
  const TanamanSayaScreen({super.key});

  @override
  State<TanamanSayaScreen> createState() => _TanamanSayaScreenState();
}

class _TanamanSayaScreenState extends State<TanamanSayaScreen> {
  List<TanamanModel> _tanamanList = [];
  String _searchQuery = '';
  String _filterStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadTanaman();
  }

  void _loadTanaman() {
    setState(() {
      _tanamanList = TanamanService.getAllTanaman();
    });
  }

  List<TanamanModel> get _filteredTanaman {
    var list = _tanamanList;
    
    if (_filterStatus != 'Semua') {
      list = list.where((t) => t.status == _filterStatus).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((t) => t.nama.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    
    return list;
  }

  void _refreshData() {
    _loadTanaman();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari tanaman...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Semua'),
                    selected: _filterStatus == 'Semua',
                    onSelected: (_) {
                      setState(() {
                        _filterStatus = 'Semua';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Sehat'),
                    selected: _filterStatus == 'Sehat',
                    onSelected: (_) {
                      setState(() {
                        _filterStatus = 'Sehat';
                      });
                    },
                    selectedColor: Colors.green.shade100,
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Perlu Perhatian'),
                    selected: _filterStatus == 'Perlu Perhatian',
                    onSelected: (_) {
                      setState(() {
                        _filterStatus = 'Perlu Perhatian';
                      });
                    },
                    selectedColor: Colors.orange.shade100,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // List Tanaman
          Expanded(
            child: _filteredTanaman.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.eco,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Tidak ada tanaman yang cocok'
                              : 'Belum ada tanaman',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TambahTanamanPage(),
                                ),
                              ).then((_) => _refreshData());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                            child: const Text('Tambah Tanaman'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTanaman.length,
                    itemBuilder: (context, index) {
                      final tanaman = _filteredTanaman[index];
                      return _buildTanamanCard(tanaman);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahTanamanPage(),
            ),
          ).then((_) => _refreshData());
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTanamanCard(TanamanModel tanaman) {
    final bool isSehat = tanaman.status == 'Sehat';
    final Color statusColor = isSehat ? Colors.green : Colors.orange;
    final IconData statusIcon = isSehat ? Icons.check_circle : Icons.warning_amber;
    
    // Cek apakah ada foto tanaman
    final bool hasImage = tanaman.imagePath != null && File(tanaman.imagePath!).existsSync();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailTanamanPage(tanamanId: tanaman.id),
            ),
          ).then((_) => _refreshData());
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail foto tanaman
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Container(
                width: 90,
                height: 110,
                color: Colors.grey[100],
                child: hasImage
                    ? Image.file(
                        File(tanaman.imagePath!),
                        width: 90,
                        height: 110,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Icon(
                          Icons.eco,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
              ),
            ),
            // Informasi tanaman
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            tanaman.nama,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusColor,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusIcon,
                                color: statusColor,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tanaman.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            tanaman.lokasi,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tanam: ${tanaman.tanggalTanam}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.timer,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Umur: ${tanaman.umur} hari',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}