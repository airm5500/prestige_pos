import 'dart:async';

import 'package:flutter/material.dart';

import 'package:prestige_pos/auth/service/api_client.dart';
import 'package:prestige_pos/auth/service/auth_service.dart';
import 'package:prestige_pos/provider/mode_reglement_provider.dart';
import 'package:prestige_pos/provider/produit_provider.dart';
import 'package:prestige_pos/provider/vente_provider.dart';

import 'package:prestige_pos/service/mode_reglement_service.dart';
import 'package:prestige_pos/service/produit_service.dart';
import 'package:prestige_pos/service/remise_service.dart';
import 'package:prestige_pos/service/vente_service.dart';
import 'package:prestige_pos/ui/login/login_screen.dart';
import 'package:prestige_pos/ui/settings/setting_screen.dart';
import 'package:prestige_pos/ui/vente/vente_screen.dart';

import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiClient = await ApiClient.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<ModeReglementService>(
          create: (_) => ModeReglementService(apiClient: apiClient),
        ),
        Provider<RemiseService>(
          create: (_) => RemiseService(apiClient: apiClient),
        ),
        Provider<ProduitService>(
          create: (_) => ProduitService(apiClient: apiClient),
        ),
        Provider<VenteService>(
          create: (_) => VenteService(apiClient: apiClient),
        ),
        ChangeNotifierProvider<VenteProvider>(
          create: (context) =>
              VenteProvider(venteService: context.read<VenteService>()),
        ),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(
          create: (context) =>
              ModeReglementProvider(context.read<ModeReglementService>()),
        ),

        ChangeNotifierProvider(
          create: (context) => ProduitProvider(context.read<ProduitService>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

void showSnack(BuildContext context, String msg) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

// ======= App =======
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      darkTheme: ThemeData.dark(useMaterial3: true),
      // home: const StartGate(),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartGate(), // Default route

        VenteScreen.routeName: (context) => const VenteScreen(),

        // '/sales': (context) => SalesPage(),
      },
    );
  }
}

// ======= StartGate =======
class StartGate extends StatefulWidget {
  const StartGate({super.key});

  @override
  State<StartGate> createState() => _StartGateState();
}

class _StartGateState extends State<StartGate> {
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

    // Redirection selon l’état d’authentification
    if (!mounted) return;
    if (authService.isAuthenticated) {
      Navigator.pushReplacementNamed(context, VenteScreen.routeName);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
