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
/*
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
    _loadCredentials();
  }

  @override
  void dispose() {
    _loginCtl.dispose();
    _pwdCtl.dispose();
    super.dispose();
  }

  Future<void> _loadCredentials() async {
    final apiClient = await ApiClient.init();
    if (apiClient.rememberMe) {
      setState(() {
        _loginCtl.text = apiClient.username ?? '';
        _pwdCtl.text = apiClient.password ?? '';
        rememberMe = apiClient.rememberMe;
      });
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

  Future<void> _performLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      loading = true;
    });

    final authService = context.read<AuthService>();

    await authService.loginWithJwt(
      _loginCtl.text.trim(),
      _pwdCtl.text.trim(),
    );

    if (mounted) {
      setState(() {
        loading = false;
      });

      if (authService.isAuthenticated) {
        await _saveCredentials();
        Navigator.of(context).pushReplacementNamed(VenteScreen.routeName);
      } else {
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
                      if (snapshot.hasData && snapshot.data != null) {
                        final apiClientData = snapshot.data!;
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir votre login';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir votre mot de passe';
                  }
                  return null;
                },
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
                  onPressed: loading ? null : _performLogin,
                  icon: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
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
*/

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

    // Pré-remplissage si rememberMe
    if (apiClient.rememberMe) {
      _loginCtl.text = apiClient.username ?? '';
      _pwdCtl.text = apiClient.password ?? '';
      rememberMe = apiClient.rememberMe;

      // Tentative de connexion automatique
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
        Navigator.of(context).pushReplacementNamed(VenteScreen.routeName);
      }
    } else if (!auto) {
      // Montrer l'erreur uniquement si l'utilisateur a lancé la connexion manuellement
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
