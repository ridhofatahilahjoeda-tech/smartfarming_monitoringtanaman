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
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.eco_outlined),
            activeIcon: Icon(Icons.eco),
            label: 'Tanaman Saya',
          ),
          // Icon Scan bentuk kotak/bingkai []
          BottomNavigationBarItem(
            icon: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGreen,
                      AppTheme.secondaryGreen,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.crop_free_outlined, // Bentuk kotak/bingkai []
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            activeIcon: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGreen,
                      AppTheme.secondaryGreen,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.6),
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.crop_free, // Versi aktif
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            label: 'Scan',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.sensors_outlined),
            activeIcon: Icon(Icons.sensors),
            label: 'Perangkat IoT',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}