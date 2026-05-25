import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../themes/app_theme.dart';
import 'dart:async';

class PerangkatIotScreen extends StatefulWidget {
  const PerangkatIotScreen({super.key});

  @override
  State<PerangkatIotScreen> createState() => _PerangkatIotScreenState();
}

class _PerangkatIotScreenState extends State<PerangkatIotScreen> {
  // Data sensor simulasi dengan nilai real-time yang bisa berubah
  double _suhu = 28.1;
  double _kelembabanUdara = 69.0;
  double _kelembabanTanah = 62.0;
  double _phTanah = 6.4;
  
  // Status koneksi IoT
  bool _isConnected = true;
  
  // Timer untuk simulasi update data real-time
  late Timer _timer;
  
  @override
  void initState() {
    super.initState();
    _startRealTimeSimulation();
  }
  
  void _startRealTimeSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _suhu = 27.0 + (DateTime.now().second % 30) / 10;
          _kelembabanUdara = 65.0 + (DateTime.now().second % 20);
          _kelembabanTanah = 55.0 + (DateTime.now().second % 30);
          _phTanah = 6.0 + (DateTime.now().second % 10) / 10;
          _isConnected = (DateTime.now().second % 15) != 0;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // ==================== DATA GRAFIK LINE CHART ====================
  List<FlSpot> _getKelembabanData() {
    return [
      const FlSpot(0, 65), const FlSpot(2, 68), const FlSpot(4, 72),
      const FlSpot(6, 75), const FlSpot(8, 70), const FlSpot(10, 62),
      const FlSpot(12, 58), const FlSpot(14, 55), const FlSpot(16, 60),
      const FlSpot(18, 65), const FlSpot(20, 70), const FlSpot(22, 72),
    ];
  }

  List<FlSpot> _getSuhuData() {
    return [
      const FlSpot(0, 24), const FlSpot(2, 23), const FlSpot(4, 22),
      const FlSpot(6, 23), const FlSpot(8, 26), const FlSpot(10, 29),
      const FlSpot(12, 32), const FlSpot(14, 33), const FlSpot(16, 31),
      const FlSpot(18, 28), const FlSpot(20, 26), const FlSpot(22, 25),
    ];
  }

  // ==================== WIDGET GRAFIK LINE CHART ====================
  Widget _buildLineChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: AppTheme.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Tren Kelembaban & Suhu 24 Jam',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    horizontalInterval: 10,
                    verticalInterval: 4,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 25,
                        getTitlesWidget: (value, meta) {
                          const hours = ['00', '02', '04', '06', '08', '10', '12', '14', '16', '18', '20', '22'];
                          final index = (value / 2).round();
                          if (index >= 0 && index < hours.length) {
                            return Text(
                              hours[index],
                              style: const TextStyle(fontSize: 9),
                            );
                          }
                          return const Text('');
                        },
                        interval: 2,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 9),
                          );
                        },
                        interval: 20,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  minX: 0,
                  maxX: 22,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getKelembabanData(),
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: AppTheme.primaryGreen,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                      ),
                    ),
                    LineChartBarData(
                      spots: _getSuhuData(),
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: Colors.orange,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.orange.withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((touchedSpot) {
                          final isKelembaban = touchedSpot.barIndex == 0;
                          final value = touchedSpot.y;
                          final x = touchedSpot.x.toInt();
                          return LineTooltipItem(
                            '${x.toString().padLeft(2, '0')}:00\n'
                            '${isKelembaban ? "💧" : "🌡️"}: ${value.toStringAsFixed(1)}${isKelembaban ? "%" : "°C"}',
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                      getTooltipColor: (touchedSpot) => Colors.black87,
                      tooltipBorder: const BorderSide(color: Colors.white, width: 1),
                      tooltipRoundedRadius: 6,
                      tooltipMargin: 6,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 4),
                const Text('Kelembaban', style: TextStyle(fontSize: 10)),
                const SizedBox(width: 12),
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 4),
                const Text('Suhu', style: TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== STATUS KONEKSI CARD (PENGGANTI APPBAR) ====================
  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isConnected ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isConnected ? Colors.green.shade200 : Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isConnected ? Colors.green : Colors.red,
              boxShadow: [
                BoxShadow(
                  color: (_isConnected ? Colors.green : Colors.red).withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Koneksi IoT',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isConnected ? 'Terhubung ke server' : 'Koneksi terputus',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isConnected ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isConnected ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _isConnected ? 'ONLINE' : 'OFFLINE',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.95,
      children: [
        _buildSensorCard(
          title: 'Suhu Udara',
          value: '${_suhu.toStringAsFixed(1)} °C',
          icon: Icons.thermostat,
          color: Colors.orange,
          status: _getSuhuStatus(),
        ),
        _buildSensorCard(
          title: 'Kelembaban Udara',
          value: '${_kelembabanUdara.toStringAsFixed(0)} %',
          icon: Icons.water_drop,
          color: Colors.blue,
          status: _getKelembabanUdaraStatus(),
        ),
        _buildSensorCard(
          title: 'Kelembaban Tanah',
          value: '${_kelembabanTanah.toStringAsFixed(0)} %',
          icon: Icons.grass,
          color: Colors.green,
          status: _getKelembabanTanahStatus(),
        ),
        _buildSensorCard(
          title: 'pH Tanah',
          value: _phTanah.toStringAsFixed(1),
          icon: Icons.science,
          color: Colors.purple,
          status: _getPhStatus(),
          unit: 'pH',
        ),
      ],
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String status,
    String unit = '',
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 2),
                  Text(unit, style: TextStyle(fontSize: 11, color: color)),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(status),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 24),
                const SizedBox(width: 8),
                const Text(
                  '💡 Rekomendasi Sistem IoT',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildRecommendationItem(
              'Suhu', _suhu, 'Suhu optimal untuk tanaman: 25-30°C', Icons.thermostat,
            ),
            const SizedBox(height: 12),
            _buildRecommendationItem(
              'Kelembaban Tanah', _kelembabanTanah, 'Kelembaban ideal: 60-80%', Icons.water_drop,
            ),
            const SizedBox(height: 12),
            _buildRecommendationItem(
              'pH Tanah', _phTanah, 'pH ideal untuk sebagian besar tanaman: 6.0-7.0', Icons.science,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String title, double value, String message, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(message, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  String _getSuhuStatus() {
    if (_suhu < 25) return 'Dingin';
    if (_suhu > 30) return 'Panas';
    return 'Normal';
  }
  
  String _getKelembabanUdaraStatus() {
    if (_kelembabanUdara < 50) return 'Kering';
    if (_kelembabanUdara > 80) return 'Lembab';
    return 'Normal';
  }
  
  String _getKelembabanTanahStatus() {
    if (_kelembabanTanah < 50) return 'Kering';
    if (_kelembabanTanah > 80) return 'Terlalu Lembab';
    return 'Normal';
  }
  
  String _getPhStatus() {
    if (_phTanah < 6.0) return 'Asam';
    if (_phTanah > 7.0) return 'Basa';
    return 'Netral';
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Normal': case 'Netral': return Colors.green;
      case 'Panas': case 'Dingin': case 'Kering': case 'Asam': case 'Basa': return Colors.orange;
      case 'Terlalu Lembab': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar DIHAPUS - karena sudah ada di MainNavigation
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Koneksi (pengganti AppBar)
            _buildConnectionStatus(),
            const SizedBox(height: 20),
            
            const Text(
              '📡 Status Sensor IoT',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSensorGrid(),
            const SizedBox(height: 20),
            _buildAdditionalInfo(),
            const SizedBox(height: 20),
            _buildLineChart(),
          ],
        ),
      ),
    );
  }
}