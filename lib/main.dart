import 'package:flutter/material.dart';
import 'themes/app_theme.dart';
import 'services/tanaman_service.dart';
import 'screens/login_screen.dart';
import 'services/riwayat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TanamanService.loadData(); // Load data sebelum run
  await RiwayatService.loadRiwayat();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Farming',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}