import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_theme.dart';
import 'login_screen.dart';
import 'edit_profil_screen.dart';
import 'bantuan_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  // Data user
  String _nama = '';
  String _email = '';
  String _noHp = '';
  String? _avatarPath;
  bool _isLoading = true;

  // Key untuk SharedPreferences
  static const String _keyNama = 'user_nama';
  static const String _keyEmail = 'user_email';
  static const String _keyNoHp = 'user_noHp';
  static const String _keyAvatarPath = 'user_avatar_path';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load data dari SharedPreferences
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _nama = prefs.getString(_keyNama) ?? 'Frikitiw';
      _email = prefs.getString(_keyEmail) ?? 'frikitiw@gmail.com';
      _noHp = prefs.getString(_keyNoHp) ?? '+62 812 3456 7890';
      _avatarPath = prefs.getString(_keyAvatarPath);
      _isLoading = false;
    });
  }

  // Simpan data ke SharedPreferences
  Future<void> _saveUserData({
    String? nama,
    String? email,
    String? noHp,
    String? avatarPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (nama != null) await prefs.setString(_keyNama, nama);
    if (email != null) await prefs.setString(_keyEmail, email);
    if (noHp != null) await prefs.setString(_keyNoHp, noHp);
    if (avatarPath != null) {
      await prefs.setString(_keyAvatarPath, avatarPath);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Konfirmasi Logout'),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
          ),
        ),
      );
    }

    // Cek apakah ada foto profil
    final bool hasAvatar = _avatarPath != null && File(_avatarPath!).existsSync();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // HANYA Background Profil yang melengkung
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: Stack(
                children: [
                  // Background Blur
                  if (hasAvatar)
                    Container(
                      height: 280,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Image.file(
                            File(_avatarPath!),
                            width: double.infinity,
                            height: 280,
                            fit: BoxFit.cover,
                          ),
                          ClipRRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                height: 280,
                                width: double.infinity,
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                          ),
                          Container(
                            height: 280,
                            width: double.infinity,
                            color: Colors.black.withOpacity(0.25),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      height: 280,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryGreen,
                            AppTheme.secondaryGreen,
                          ],
                        ),
                      ),
                    ),
                  
                  // Avatar dan Info
                  Column(
                    children: [
                      const SizedBox(height: 50),
                      Stack(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: hasAvatar
                                  ? Image.file(
                                      File(_avatarPath!),
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppTheme.primaryGreen,
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfilScreen(
                                      nama: _nama,
                                      email: _email,
                                      noHp: _noHp,
                                      avatarPath: _avatarPath,
                                    ),
                                  ),
                                );
                                
                                if (result != null && result is Map<String, dynamic>) {
                                  setState(() {
                                    if (result['nama'] != null) _nama = result['nama'];
                                    if (result['email'] != null) _email = result['email'];
                                    if (result['noHp'] != null) _noHp = result['noHp'];
                                    if (result['avatarPath'] != null) {
                                      _avatarPath = result['avatarPath'];
                                    }
                                  });
                                  
                                  await _saveUserData(
                                    nama: _nama,
                                    email: _email,
                                    noHp: _noHp,
                                    avatarPath: _avatarPath,
                                  );
                                  
                                  _showMessage(context, 'Profil berhasil diperbarui!');
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _nama,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _email,
                          style: const TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phone, size: 11, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            _noHp,
                            style: const TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ],
              ),
            ),
            
            // Menu List (TANPA lengkungan - flat/lurus)
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Handle bar (opsional)
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  _buildMenuTile(
                    icon: Icons.person_outline,
                    title: 'Informasi Akun',
                    subtitle: 'Lihat dan edit data diri',
                    color: Colors.blue,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilScreen(
                            nama: _nama,
                            email: _email,
                            noHp: _noHp,
                            avatarPath: _avatarPath,
                          ),
                        ),
                      );
                      
                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          if (result['nama'] != null) _nama = result['nama'];
                          if (result['email'] != null) _email = result['email'];
                          if (result['noHp'] != null) _noHp = result['noHp'];
                          if (result['avatarPath'] != null) {
                            _avatarPath = result['avatarPath'];
                          }
                        });
                        
                        await _saveUserData(
                          nama: _nama,
                          email: _email,
                          noHp: _noHp,
                          avatarPath: _avatarPath,
                        );
                        
                        _showMessage(context, 'Profil berhasil diperbarui!');
                      }
                    },
                  ),
                  
                  _buildMenuTile(
                    icon: Icons.agriculture,
                    title: 'Kebun Saya',
                    subtitle: 'Kelola data kebun dan lahan',
                    color: Colors.green,
                    onTap: () {
                      _showMessage(context, 'Fitur Kebun Saya akan segera hadir');
                    },
                  ),
                  
                  _buildMenuTile(
                    icon: Icons.notifications_none,
                    title: 'Pengaturan Notifikasi',
                    subtitle: 'Atur notifikasi dan pengingat',
                    color: Colors.orange,
                    onTap: () {
                      _showMessage(context, 'Fitur Pengaturan Notifikasi akan segera hadir');
                    },
                  ),
                  
                  _buildMenuTile(
                    icon: Icons.language,
                    title: 'Bahasa',
                    subtitle: 'Ganti bahasa aplikasi',
                    color: Colors.purple,
                    onTap: () {
                      _showMessage(context, 'Fitur Bahasa akan segera hadir');
                    },
                  ),
                  
                  // Menu Bantuan - SEKARANG BERFUNGSI (navigasi ke halaman bantuan)
                  _buildMenuTile(
                    icon: Icons.help_outline,
                    title: 'Bantuan',
                    subtitle: 'Pusat bantuan dan FAQ',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BantuanScreen(),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tombol Logout
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showLogoutDialog,
                        icon: const Icon(Icons.logout, size: 20),
                        label: const Text(
                          'Keluar / Logout',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Smart Farming v1.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.15), Colors.white],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }
}