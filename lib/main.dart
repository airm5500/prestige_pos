import 'package:flutter/material.dart';

import 'package:prestige_pos/auth/service/api_client.dart';
import 'package:prestige_pos/auth/service/auth_service.dart';
import 'package:prestige_pos/provider/mode_reglement_provider.dart';
import 'package:prestige_pos/provider/prevente_provider.dart';
import 'package:prestige_pos/provider/produit_provider.dart';
import 'package:prestige_pos/provider/remise_provider.dart';
import 'package:prestige_pos/provider/theme_provider.dart';
import 'package:prestige_pos/provider/vente_provider.dart';

import 'package:prestige_pos/service/mode_reglement_service.dart';
import 'package:prestige_pos/service/officine_service.dart';
import 'package:prestige_pos/service/produit_service.dart';
import 'package:prestige_pos/service/receipt_service.dart';
import 'package:prestige_pos/service/remise_service.dart';
import 'package:prestige_pos/service/vente_data_service.dart';
import 'package:prestige_pos/service/vente_service.dart';
import 'package:prestige_pos/ui/home_screen.dart';
import 'package:prestige_pos/ui/login/login_screen.dart';
import 'package:prestige_pos/ui/settings/setting_screen.dart';
import 'package:prestige_pos/ui/splash_screen.dart';
import 'package:prestige_pos/ui/vente/vente_screen.dart';
import 'package:prestige_pos/utils/constants.dart';
import 'package:prestige_pos/utils/navigation_service.dart';

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
        Provider<OfficineService>(
          create: (_) => OfficineService(apiClient: apiClient),
        ),
        Provider<VenteService>(
          create: (_) => VenteService(apiClient: apiClient),
        ),
        Provider<ReceiptService>(
          create: (context) =>
              ReceiptService(officineService: context.read<OfficineService>(),authService: context.read<AuthService>()),
        ),

        Provider<VenteDataService>(
          create: (_) => VenteDataService(apiClient: apiClient),
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

        ChangeNotifierProvider(
          create: (context) => RemiseProvider(context.read<RemiseService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => PreventeProvider(context.read<VenteDataService>()),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider())
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: Constants.title,
          navigatorKey: NavigationService.navigatorKey,
          debugShowCheckedModeBanner: false,

          // theme: themeProvider.lightTheme,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blueGrey,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.blueGrey,
          ),
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            HomeScreen.routeName: (context) => const HomeScreen(),
            LoginScreen.routeName: (context) => const LoginScreen(),
            VenteScreen.routeName: (context) =>
                VenteScreen(receiptService: context.read<ReceiptService>()),
            SettingsScreen.routeName: (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}