import 'package:flutter/material.dart';
import 'package:prestige_pos/auth/service/api_client.dart';
import 'package:prestige_pos/auth/service/auth_service.dart';
import 'package:prestige_pos/ui/settings/setting_screen.dart';
import 'package:prestige_pos/ui/vente/vente_screen.dart';
import 'package:prestige_pos/utils/constants.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _loginCtl = TextEditingController();
  final _pwdCtl = TextEditingController();
  bool loading = false;
  bool rememberMe = false;
  bool showPwd = false;

  @override
  void initState() {
    super.initState();
    //  _init();
  }

  Future<void> _performLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authService = context.read<AuthService>();

      await authService.loginWithJwt(
        _loginCtl.text.trim(),
        _pwdCtl.text.trim(),
      );

      if (authService.isAuthenticated && mounted) {
        Navigator.of(context).pushReplacementNamed(VenteScreen.routeName);
      } else if (mounted) {
        // Show error message from authService.errorMessage
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authService.errorMessage.isNotEmpty
                  ? authService.errorMessage
                  : 'Échec de la connexion inattendu.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) => FutureBuilder<ApiClient>(
                  future: ApiClient.init(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {

                      if (snapshot.hasData) {
                        final apiClientData = snapshot.data !;
                          return SettingsScreen(apiClient: apiClientData);

                      } else {
                        return const Center(
                          child: Text('Erreur de chargement des paramètres'),
                        );
                      }
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Bandeau: uniquement nomComplet
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "${Constants.appName} - Connexion",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _loginCtl,
              decoration: const InputDecoration(labelText: 'Login'),
              onSubmitted: (_) => _submit(authService),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pwdCtl,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                suffixIcon: IconButton(
                  icon: Icon(showPwd ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => showPwd = !showPwd),
                  tooltip: showPwd ? 'Cacher' : 'Afficher',
                ),
              ),
              obscureText: !showPwd,
              onSubmitted: (_) => _submit(authService),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Se souvenir de moi'),
              value: rememberMe,
              onChanged: (v) => setState(() => rememberMe = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => {
                  if (!loading) {_submit(authService)},
                },
                icon: const Icon(Icons.login),
                label: Text(loading ? 'Connexion...' : 'Se connecter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
