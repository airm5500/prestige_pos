import 'package:flutter/material.dart';
import 'package:prestige_pos/auth/service/api_client.dart';
import 'package:prestige_pos/auth/service/auth_service.dart';
import 'package:prestige_pos/ui/home_screen.dart';
import 'package:prestige_pos/ui/settings/setting_screen.dart';
import 'package:prestige_pos/ui/vente/vente_screen.dart';
import 'package:prestige_pos/utils/constants.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
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

  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = context.read<AuthService>();
    _initLogin();
  }

  Future<void> _initLogin() async {
    final apiClient = await ApiClient.init();


    if (apiClient.rememberMe) {
      _loginCtl.text = apiClient.username ?? '';
      _pwdCtl.text = apiClient.password ?? '';
      rememberMe = apiClient.rememberMe;


      if (_loginCtl.text.isNotEmpty && _pwdCtl.text.isNotEmpty) {
        await _performLogin(auto: true);
      }
    }
  }

  Future<void> _saveCredentials() async {
    final apiClient = await ApiClient.init();
    apiClient.rememberMe = rememberMe;
    if (rememberMe) {
      apiClient.username = _loginCtl.text.trim();
      apiClient.password = _pwdCtl.text.trim();
    } else {
      apiClient.username = null;
      apiClient.password = null;
    }
  }

  Future<void> _performLogin({bool auto = false}) async {
    if (!auto && !(_formKey.currentState?.validate() ?? false)) return;

    setState(() => loading = true);

    await _authService.loginWithJwt(
      _loginCtl.text.trim(),
      _pwdCtl.text.trim(),
    );

    setState(() => loading = false);

    if (_authService.isAuthenticated) {
      await _saveCredentials();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      }
    } else if (!auto) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _authService.errorMessage.isNotEmpty
                ? _authService.errorMessage
                : 'Échec de la connexion inattendu.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _loginCtl.dispose();
    _pwdCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>   const SettingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "${Constants.appName} - Connexion",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _loginCtl,
                decoration: const InputDecoration(labelText: 'Login'),
                onFieldSubmitted: (_) => _performLogin(),
                validator: (v) => (v == null || v.isEmpty) ? 'Veuillez saisir votre login' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
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
                onFieldSubmitted: (_) => _performLogin(),
                validator: (v) => (v == null || v.isEmpty) ? 'Veuillez saisir votre mot de passe' : null,
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
                  onPressed: loading ? null : () => _performLogin(),
                  icon: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.login),
                  label: Text(loading ? 'Connexion...' : 'Se connecter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
