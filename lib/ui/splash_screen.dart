
import 'package:flutter/material.dart';
import 'package:prestige_pos/auth/service/api_client.dart';
import 'package:prestige_pos/auth/service/auth_service.dart';
import 'package:prestige_pos/ui/home_screen.dart';
import 'package:prestige_pos/ui/login/login_screen.dart';
import 'package:prestige_pos/ui/settings/setting_screen.dart';
import 'package:provider/provider.dart';

import '../utils/app_color.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }
  Future<void> _bootstrap() async {
    final authService = context.read<AuthService>();
    final apiClient = await ApiClient.init();

    if ((apiClient.localIp == null || apiClient.localIp!.isEmpty) &&
        (apiClient.remoteIp == null || apiClient.remoteIp!.isEmpty)) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
      return;
    }
    if (apiClient.rememberMe &&
        apiClient.username != null &&
        apiClient.password != null) {
      await authService.loginWithJwt(
        apiClient.username!.trim(),
        apiClient.password!.trim(),
      );
    }

    if (!mounted) return;
    if (authService.isAuthenticated) {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColor.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store, size: 80, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Prestige Vente',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}