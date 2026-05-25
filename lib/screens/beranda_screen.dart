import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smartfarming_monitoringtanaman/services/tanaman_service.dart';
import 'package:smartfarming_monitoringtanaman/screens/scan_page.dart';
import 'package:smartfarming_monitoringtanaman/screens/tambah_tanaman_page.dart';
import '../themes/app_theme.dart';
import 'dart:async';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  // Data real-time untuk cuaca (simulasi)
  String _suhu = '28';
  String _kondisiCuaca = 'Cerah Berawan';
  String _kelembaban = '65';
  String _iconCuaca = '☀️';
  
  // Data ringkasan kebun (real-time dari service)
  int _totalTanaman = 0;
  int _tanamanSehat = 0;
  int _tanamanPerluPerhatian = 0;
  int _penyakitTerdeteksi = 0;
  
  // Daftar tips
  final List<Map<String, dynamic>> _tips = [
    {'icon': Icons.water_drop, 'color': Colors.blue, 'tip': 'Siram tanaman di pagi hari untuk hasil maksimal'},
    {'icon': Icons.grass, 'color': Colors.green, 'tip': 'Periksa kondisi daun untuk deteksi dini hama'},
    {'icon': Icons.science, 'color': Colors.orange, 'tip': 'Gunakan pupuk organik untuk kesuburan tanah'},
    {'icon': Icons.sunny, 'color': Colors.amber, 'tip': 'Pastikan tanaman mendapat sinar matahari cukup'},
    {'icon': Icons.cleaning_services, 'color': Colors.teal, 'tip': 'Bersihkan gulma secara rutin setiap minggu'},
  ];
  
  int _currentTipIndex = 0;
  late Timer _tipTimer;
  late Timer _weatherTimer;
  late Timer _dataRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadDataTanaman();
    _startRealTimeSimulation();
  }

  void _loadDataTanaman() {
    final semuaTanaman = TanamanService.getAllTanaman();
    
    setState(() {
      _totalTanaman = semuaTanaman.length;
      _tanamanSehat = semuaTanaman.where((t) => t.status == 'Sehat').length;
      _tanamanPerluPerhatian = semuaTanaman.where((t) => t.status == 'Perlu Perhatian').length;
      _penyakitTerdeteksi = semuaTanaman.where((t) => 
        t.status == 'Perlu Perhatian' && 
        t.rekomendasi.contains('penyakit') || t.rekomendasi.contains('hama')
      ).length;
    });
  }

  void _startRealTimeSimulation() {
    _tipTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) setState(() => _currentTipIndex = (_currentTipIndex + 1) % _tips.length);
    });
    _weatherTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) _simulateWeatherChange();
    });
    _dataRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) _loadDataTanaman();
    });
  }

  void _simulateWeatherChange() {
    final weathers = [
      {'suhu': '28', 'kondisi': 'Cerah Berawan', 'kelembaban': '65', 'icon': '☀️'},
      {'suhu': '30', 'kondisi': 'Panas Terik', 'kelembaban': '58', 'icon': '🔥'},
      {'suhu': '25', 'kondisi': 'Berawan', 'kelembaban': '72', 'icon': '☁️'},
      {'suhu': '23', 'kondisi': 'Hujan Ringan', 'kelembaban': '85', 'icon': '🌧️'},
      {'suhu': '26', 'kondisi': 'Mendung', 'kelembaban': '78', 'icon': '⛅'},
    ];
    final randomWeather = weathers[DateTime.now().second % weathers.length];
    setState(() {
      _suhu = randomWeather['suhu']!;
      _kondisiCuaca = randomWeather['kondisi']!;
      _kelembaban = randomWeather['kelembaban']!;
      _iconCuaca = randomWeather['icon']!;
    });
  }

  @override
  void dispose() {
    _tipTimer.cancel();
    _weatherTimer.cancel();
    _dataRefreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _loadDataTanaman();
          return Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWeatherCard(),
              const SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ringkasan Kebun Anda',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _loadDataTanaman();
                      _showMessage(context, 'Data berhasil diperbarui');
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh'),
                    style: TextButton.styleFrom(foregroundColor: AppTheme.primaryGreen),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildGardenSummaryGrid(),
              const SizedBox(height: 24),
              _buildQuickTips(context),
              const SizedBox(height: 20), // Tambahan padding bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    IconData weatherIcon;
    switch (_iconCuaca) {
      case '☀️': weatherIcon = Icons.wb_sunny; break;
      case '🔥': weatherIcon = Icons.whatshot; break;
      case '☁️': weatherIcon = Icons.cloud; break;
      case '🌧️': weatherIcon = Icons.umbrella; break;
      default: weatherIcon = Icons.wb_cloudy;
    }
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/rice_field_bg.png',
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(weatherIcon, color: Colors.white, size: 32),
                          const SizedBox(width: 8),
                          Text(
                            '$_suhu°C',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _kondisiCuaca,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          shadows: [Shadow(color: Colors.black38, blurRadius: 2, offset: Offset(0, 1))],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.water_drop, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text('Kelembaban: $_kelembaban%', style: const TextStyle(fontSize: 12, color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(_iconCuaca, style: const TextStyle(fontSize: 60, shadows: [Shadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3))])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== RINGKASAN KEBUN DENGAN 3D CRYSTAL / iOS STYLE ====================
  
  Widget _buildGardenSummaryGrid() {
    final List<SummaryItem> summaryItems = [
      SummaryItem(title: 'Total Tanaman', value: '$_totalTanaman', icon: Icons.eco, color: const Color(0xFF4CAF50)),
      SummaryItem(title: 'Tanaman Sehat', value: '$_tanamanSehat', icon: Icons.health_and_safety, color: const Color(0xFF66BB6A)),
      SummaryItem(title: 'Perlu Perhatian', value: '$_tanamanPerluPerhatian', icon: Icons.warning_amber, color: const Color(0xFFFFA726)),
      SummaryItem(title: 'Penyakit Terdeteksi', value: '$_penyakitTerdeteksi', icon: Icons.sick, color: const Color(0xFFEF5350)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0, // Diubah agar tidak overflow
      ),
      itemCount: summaryItems.length,
      itemBuilder: (context, index) {
        final item = summaryItems[index];
        return _buildCrystalCard(item);
      },
    );
  }

  // Widget Card dengan efek 3D Crystal / iOS Style
  Widget _buildCrystalCard(SummaryItem item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon dengan efek 3D Crystal
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 0.8,
                  colors: [
                    Colors.white.withOpacity(0.8),
                    item.color.withOpacity(0.3),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: item.color.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  item.icon,
                  size: 36,
                  color: item.color,
                  shadows: [
                    const Shadow(color: Colors.white, blurRadius: 2, offset: Offset(0, 1)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                item.value,
                key: ValueKey(item.value),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: item.color,
                  shadows: [
                    Shadow(color: Colors.white.withOpacity(0.5), blurRadius: 2, offset: Offset(0, 1)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTips(BuildContext context) {
    final currentTip = _tips[_currentTipIndex];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Row(
                    key: ValueKey(_currentTipIndex),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [(currentTip['color'] as Color).withOpacity(0.2), Colors.white],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (currentTip['color'] as Color).withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(currentTip['icon'], color: currentTip['color'], size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(currentTip['tip'], style: const TextStyle(fontSize: 14, height: 1.4))),
                    ],
                  ),
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_tips.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentTipIndex == index ? AppTheme.primaryGreen : Colors.grey.withOpacity(0.3),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                const Text('Menu Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickActionButton(
                      context: context,
                      icon: Icons.qr_code_scanner,
                      label: 'Scan',
                      color: AppTheme.primaryGreen,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanPage())),
                    ),
                    _buildQuickActionButton(
                      context: context,
                      icon: Icons.add_circle,
                      label: 'Tambah',
                      color: AppTheme.secondaryGreen,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TambahTanamanPage())).then((_) => _loadDataTanaman()),
                    ),
                    _buildQuickActionButton(
                      context: context,
                      icon: Icons.analytics,
                      label: 'Analisis',
                      color: Colors.orange,
                      onTap: () => _showMessage(context, 'Fitur analisis akan segera hadir'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.white, color.withOpacity(0.2)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class SummaryItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}