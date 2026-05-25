import 'package:flutter/material.dart';
import 'screens/beranda_screen.dart';
import 'screens/tanaman_saya_screen.dart';
import 'screens/scan_page.dart';
import 'screens/perangkat_iot_screen.dart';
import 'screens/profil_screen.dart';
import 'themes/app_theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const BerandaScreen(),
    const TanamanSayaScreen(),
    const ScanPage(),
    const PerangkatIotScreen(),
    const ProfilScreen(),
  ];
  
  final List<String> _titles = [
    'Beranda',
    'Tanaman Saya',
    'Scan Penyakit Tanaman',
    'Perangkat IoT',
    'Profil Saya',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: Colors.grey,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: 'Tanaman Saya'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'Perangkat IoT'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}