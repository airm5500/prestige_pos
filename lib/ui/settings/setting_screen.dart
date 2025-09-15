
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prestige_pos/auth/service/Api_client.dart';
import 'package:prestige_pos/ui/login/login_screen.dart';


class SettingsScreen extends StatefulWidget {
  final ApiClient apiClient;

  const SettingsScreen({super.key, required this.apiClient});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final ApiClient apiClient;
  final _localCtl = TextEditingController();
  final _remoteCtl = TextEditingController();
  final _appCtl = TextEditingController();
  final _portCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _addrCtl = TextEditingController();

  void showSnack(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  bool isRemote = false;
  String pingLocal = '';
  String pingRemote = '';

  @override
  void initState() {
    super.initState();
    apiClient = widget.apiClient;
    _load();
  }

  Future<void> _load() async {
    _localCtl.text = apiClient.localIp ?? '';
    _remoteCtl.text = apiClient.remoteIp ?? '';
    _appCtl.text = 'proxy';
    _portCtl.text = (apiClient.port != null)
        ? apiClient.port.toString()
        : '8780';
    isRemote = apiClient.isRemote ;
    setState(() {});
  }

  Future<String> _ping(String ip) async {
    if (ip.isEmpty) return 'Adresse vide';
    final base = 'http://$ip:${_portCtl.text}/${_appCtl.text}/api/v1'; //TODO ping healcheck
    final url = Uri.parse('$base/vente/cheick-caisse');
    final sw = Stopwatch()
      ..start();
    try {
      final r = await http.get(url).timeout(const Duration(seconds: 4));
      sw.stop();
      final ok =
      (r.statusCode == 200 || r.statusCode == 401 || r.statusCode == 403);
      return ok
          ? 'OK (${sw.elapsedMilliseconds} ms)'
          : 'KO (HTTP ${r.statusCode})';
    } catch (e) {
      sw.stop();
      return 'KO (${e.runtimeType})';
    }
  }

  Future<void> _save() async {
    // Ping auto avant sauvegarde
    if (_localCtl.text.isNotEmpty) pingLocal = await _ping(_localCtl.text);
    if (_remoteCtl.text.isNotEmpty) pingRemote = await _ping(_remoteCtl.text);
    setState(() {});

    apiClient.localIp = _localCtl.text.trim();
    apiClient.remoteIp = _remoteCtl.text.trim();
    // apiClient.appName = _appCtl.text.trim();
    apiClient.port = int.tryParse(_portCtl.text.trim()) ?? 8780;
    apiClient.isRemote = isRemote;

    if (!mounted) return;
    showSnack(context, 'Configuration enregistrée');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuration')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _localCtl,
                    decoration: const InputDecoration(
                      labelText: 'Adresse IP Locale (requis)',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () async {
                    pingLocal = '...';
                    setState(() {});
                    pingLocal = await _ping(_localCtl.text);
                    setState(() {});
                  },
                  child: const Text('Ping'),
                ),
              ],
            ),
            if (pingLocal.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  'Local: $pingLocal',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _remoteCtl,
                    decoration: const InputDecoration(
                      labelText: 'Adresse IP Distante',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () async {
                    pingRemote = '...';
                    setState(() {});
                    pingRemote = await _ping(_remoteCtl.text);
                    setState(() {});
                  },
                  child: const Text('Ping'),
                ),
              ],
            ),
            if (pingRemote.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  'Distant: $pingRemote',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _appCtl,
              decoration: const InputDecoration(
                labelText: "Nom de l'application serveur (ex: laborex)",
                helperText: 'Modifiable',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _portCtl,
              decoration: const InputDecoration(labelText: 'Port'),
              keyboardType: TextInputType.number,
            ),
            const Divider(height: 32),
            TextField(
              controller: _phoneCtl,
              decoration: const InputDecoration(
                labelText: 'Téléphone officine',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addrCtl,
              decoration: const InputDecoration(labelText: 'Adresse officine'),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Utiliser le mode Local (sinon Distant)'),
              value: !isRemote,
              onChanged: (v) => setState(() => isRemote = v),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
