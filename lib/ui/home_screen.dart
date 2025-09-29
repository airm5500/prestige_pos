import 'package:flutter/material.dart';
import 'package:prestige_pos/auth/service/auth_service.dart';
import 'package:prestige_pos/model/vente/officine.dart';
import 'package:prestige_pos/service/officine_service.dart';
import 'package:prestige_pos/service/receipt_service.dart';
import 'package:prestige_pos/ui/login/login_screen.dart';
import 'package:prestige_pos/ui/vente/vente_screen.dart';
import 'package:prestige_pos/utils/app_color.dart';
import 'package:prestige_pos/utils/constants.dart';
import 'package:prestige_pos/utils/responsive.dart';
import 'package:prestige_pos/widget/menu_button.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
  static const String routeName = '/home';
}

class _HomeScreenState extends State<HomeScreen> {
  Officine? _officine;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOfficine();
  }

  Future<void> _fetchOfficine() async {
    final officineService = Provider.of<OfficineService>(
      context,
      listen: false,
    );
    try {
      final officineResponse = await officineService.find();
      if (mounted) {
        setState(() {
          _officine = officineResponse.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      // Handle error, maybe show a snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthService>(context, listen: false);
    final user = authProvider.currentUser;
    final officineService = Provider.of<OfficineService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: _isLoading
            ? const Text('Chargement...')
            : Text(_officine?.name ?? 'Prestige Vente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await authProvider.logout();
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: AppColor.primary.withOpacity(0.1),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_pin_circle,
                        size: 40,
                        color: AppColor.primary,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bienvenue, ${user?.firstname ?? ''}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_isLoading)
                              const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else if (_officine != null)
                              Text(

                                _officine!.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    MenuButton(
                      icon: Icons.point_of_sale,
                      label: Constants.homeBtnVenteLabel,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => VenteScreen(
                                receiptService: ReceiptService(
                                    officineService: officineService,
                                    authService: authProvider))));
                      },
                    ),

                    // Autre boutons de menu peuvent être ajoutés ici
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
