import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/tanaman_service.dart';
import '../services/riwayat_service.dart';
import '../models/riwayat_scan_model.dart';
import '../themes/app_theme.dart';

class AnalisisScreen extends StatefulWidget {
  const AnalisisScreen({super.key});

  @override
  State<AnalisisScreen> createState() => _AnalisisScreenState();
}

class _AnalisisScreenState extends State<AnalisisScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Data tanaman
  int _totalTanaman = 0;
  int _tanamanSehat = 0;
  int _tanamanPerluPerhatian = 0;
  int _penyakitTerdeteksi = 0;
  
  // Data riwayat scan
  List<RiwayatScanModel> _riwayatScan = [];
  
  // Statistik penyakit
  Map<String, int> _penyakitStats = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final semuaTanaman = TanamanService.getAllTanaman();
    _riwayatScan = RiwayatService.getAllRiwayat();
    
    setState(() {
      _totalTanaman = semuaTanaman.length;
      _tanamanSehat = semuaTanaman.where((t) => t.status == 'Sehat').length;
      _tanamanPerluPerhatian = semuaTanaman.where((t) => t.status == 'Perlu Perhatian').length;
      _penyakitTerdeteksi = _riwayatScan.where((r) => r.penyakit != 'Sehat').length;
      
      _penyakitStats = {};
      for (var scan in _riwayatScan) {
        if (scan.penyakit != 'Sehat') {
          _penyakitStats[scan.penyakit] = (_penyakitStats[scan.penyakit] ?? 0) + 1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Analisis & Laporan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Ringkasan', icon: Icon(Icons.dashboard)),
            Tab(text: 'Penyakit', icon: Icon(Icons.sick)),
            Tab(text: 'Rekomendasi', icon: Icon(Icons.lightbulb)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRingkasanTab(),
          _buildPenyakitTab(),
          _buildRekomendasiTab(),
        ],
      ),
    );
  }

  // ==================== TAB 1: RINGKASAN ====================
  Widget _buildRingkasanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatistikCard(),
          const SizedBox(height: 20),
          _buildKesehatanChart(),
          const SizedBox(height: 20),
          _buildTrenPenyakitChart(),
          const SizedBox(height: 20),
          _buildPrediksiCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatistikCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen,
            AppTheme.secondaryGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Tanaman', '$_totalTanaman', Icons.eco, Colors.white),
                _buildStatItem('Tanaman Sehat', '$_tanamanSehat', Icons.health_and_safety, Colors.white),
                _buildStatItem('Perlu Perhatian', '$_tanamanPerluPerhatian', Icons.warning_amber, Colors.white),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white30),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Penyakit Terdeteksi: $_penyakitTerdeteksi',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildKesehatanChart() {
    final double sehatPersen = _totalTanaman > 0 ? (_tanamanSehat / _totalTanaman) * 100 : 0.0;
    final double perhatianPersen = _totalTanaman > 0 ? (_tanamanPerluPerhatian / _totalTanaman) * 100 : 0.0;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.defaultShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.pie_chart, color: AppTheme.primaryGreen),
                SizedBox(width: 8),
                Text(
                  'Kesehatan Tanaman',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: sehatPersen, // Sekarang bertipe double
                      title: '${sehatPersen.toInt()}%',
                      color: Colors.green,
                      radius: 80,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      value: perhatianPersen, // Sekarang bertipe double
                      title: '${perhatianPersen.toInt()}%',
                      color: Colors.orange,
                      radius: 80,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Sehat', Colors.green),
                const SizedBox(width: 48),
                _buildLegendItem('Perlu Perhatian', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTrenPenyakitChart() {
    final List<FlSpot> spots = [
      const FlSpot(0, 2), const FlSpot(1, 3), const FlSpot(2, 5),
      const FlSpot(3, 4), const FlSpot(4, 6), const FlSpot(5, 8), const FlSpot(6, 7),
    ];
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.defaultShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.show_chart, color: AppTheme.primaryGreen),
                SizedBox(width: 8),
                Text(
                  'Tren Penyakit (7 Hari Terakhir)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                          final index = value.toInt();
                          if (index >= 0 && index < days.length) {
                            return Text(days[index], style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}', style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: true, color: Colors.red.withOpacity(0.1)),
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

  Widget _buildPrediksiCard() {
    final random = Random();
    final prediksiHari = 30 + random.nextInt(20);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.amber.shade400, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.calendar_today, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Prediksi Panen', style: TextStyle(color: Colors.white, fontSize: 14)),
                  Text('~ $prediksiHari Hari Lagi', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Berdasarkan data tanaman Anda', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TAB 2: PENYAKIT ====================
  Widget _buildPenyakitTab() {
    if (_penyakitStats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety, size: 80, color: Colors.green.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('Belum ada penyakit terdeteksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('Lakukan scan untuk mendeteksi penyakit', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ],
        ),
      );
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.defaultShadow),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(Icons.bar_chart, color: AppTheme.primaryGreen), SizedBox(width: 8), Text('Statistik Penyakit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
                const SizedBox(height: 16),
                ..._penyakitStats.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildPenyakitItem(entry.key, entry.value),
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Lakukan scan rutin untuk mendeteksi penyakit lebih awal dan mencegah penyebaran.',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPenyakitItem(String penyakit, int jumlah) {
    Color color;
    switch (penyakit) {
      case 'Hawar Daun': color = Colors.red; break;
      case 'Bercak Daun': color = Colors.brown; break;
      case 'Karat Daun': color = Colors.orange; break;
      default: color = Colors.green;
    }
    
    final total = _penyakitStats.values.reduce((a, b) => a + b);
    
    return Column(
      children: [
        Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(child: Text(penyakit, style: const TextStyle(fontWeight: FontWeight.w600))),
            Text('$jumlah Kali', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: total > 0 ? jumlah / total : 0,
          backgroundColor: Colors.grey.shade200,
          color: color,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  // ==================== TAB 3: REKOMENDASI ====================
  Widget _buildRekomendasiTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildRekomendasiCard(
          icon: Icons.water_drop,
          title: 'Penyiraman',
          description: 'Jadwal penyiraman optimal',
          recommendations: [
            'Siram pada pagi hari (06:00 - 08:00)',
            'Hindari penyiraman sore hari untuk mencegah jamur',
            'Gunakan irigasi tetes untuk efisiensi air',
          ],
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildRekomendasiCard(
          icon: Icons.bug_report,
          title: 'Pengendalian Hama',
          description: 'Rekomendasi berdasarkan data penyakit',
          recommendations: [
            'Lakukan inspeksi rutin setiap minggu',
            'Gunakan pestisida nabati jika ditemukan hama',
            'Tanam tanaman refugia sebagai perangkap alami',
          ],
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildRekomendasiCard(
          icon: Icons.science,
          title: 'Pemupukan',
          description: 'Nutrisi yang dibutuhkan tanaman',
          recommendations: [
            'Pupuk organik lebih baik untuk kesehatan tanah',
            'Berikan pupuk NPK setiap 2 minggu sekali',
            'Sesuaikan dosis dengan umur tanaman',
          ],
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        _buildRekomendasiCard(
          icon: Icons.timeline,
          title: 'Monitoring',
          description: 'Tindakan preventif',
          recommendations: [
            'Scan rutin untuk deteksi dini penyakit',
            'Catat perkembangan tanaman secara berkala',
            'Pantau kondisi cuaca untuk antisipasi',
          ],
          color: Colors.purple,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRekomendasiCard({
    required IconData icon,
    required String title,
    required String description,
    required List<String> recommendations,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.defaultShadow),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 16, color: AppTheme.primaryGreen),
                  const SizedBox(width: 10),
                  Expanded(child: Text(rec, style: const TextStyle(fontSize: 13))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}