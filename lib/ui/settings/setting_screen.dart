import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prestige_pos/auth/service/api_client.dart';
import 'package:prestige_pos/ui/login/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final ApiClient apiClient;

  const SettingsScreen({super.key, required this.apiClient});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _localCtl = TextEditingController();
  final _remoteCtl = TextEditingController();
  final _appCtl = TextEditingController();
  final _portCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _addrCtl = TextEditingController();

  bool isRemote = false;
  String pingLocal = '';
  String pingRemote = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _localCtl.dispose();
    _remoteCtl.dispose();
    _appCtl.dispose();
    _portCtl.dispose();
    _phoneCtl.dispose();
    _addrCtl.dispose();
    super.dispose();
  }

  void showSnack(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _load() async {
    _localCtl.text = widget.apiClient.localIp ?? '';
    _remoteCtl.text = widget.apiClient.remoteIp ?? '';
    _appCtl.text = widget.apiClient.appName ?? 'proxy';
    _portCtl.text = (widget.apiClient.port != null)
        ? widget.apiClient.port.toString()
        : '8780';
    _phoneCtl.text = widget.apiClient.phone ?? '';
    _addrCtl.text = widget.apiClient.address ?? '';
    setState(() {
      isRemote = widget.apiClient.isRemote;
    });
  }

  Future<String> _ping(String ip) async {
    if (ip.isEmpty) return 'Adresse vide';
    final base = 'http://$ip:${_portCtl.text}/${_appCtl.text}/api/v1';
    final url = Uri.parse(
      '$base/vente/cheick-caisse',
    ); // TODO: Use a proper health check endpoint
    final sw = Stopwatch()..start();
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
    // Auto-ping before saving
    if (_localCtl.text.isNotEmpty) {
      pingLocal = await _ping(_localCtl.text);
    }
    if (_remoteCtl.text.isNotEmpty) {
      pingRemote = await _ping(_remoteCtl.text);
    }
    setState(() {});

    widget.apiClient.localIp = _localCtl.text.trim();
    widget.apiClient.remoteIp = _remoteCtl.text.trim();
    widget.apiClient.appName = _appCtl.text.trim();
    widget.apiClient.port = int.tryParse(_portCtl.text.trim()) ?? 8780;
    widget.apiClient.isRemote = isRemote;
    widget.apiClient.phone = _phoneCtl.text.trim();
    widget.apiClient.address = _addrCtl.text.trim();

    if (!mounted) return;
    showSnack(context, 'Configuration enregistrée');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _buildIpInputRow({
    required TextEditingController controller,
    required String label,
    required String pingResult,
    required String resultPrefix,
    required VoidCallback onPingPressed,
  }) {
    final bool isOk = pingResult.startsWith('OK');
    final Color resultColor = isOk ? Colors.green : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(labelText: label),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: onPingPressed, child: const Text('Ping')),
          ],
        ),
        if (pingResult.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              '$resultPrefix: $pingResult',
              style: TextStyle(fontSize: 12, color: resultColor),
            ),
          ),
      ],
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
            _buildIpInputRow(
              controller: _localCtl,
              label: 'Adresse IP Locale (requis)',
              pingResult: pingLocal,
              resultPrefix: 'Local',
              onPingPressed: () async {
                setState(() => pingLocal = '...');
                final result = await _ping(_localCtl.text);
                setState(() => pingLocal = result);
              },
            ),
            const SizedBox(height: 12),
            _buildIpInputRow(
              controller: _remoteCtl,
              label: 'Adresse IP Distante',
              pingResult: pingRemote,
              resultPrefix: 'Distant',
              onPingPressed: () async {
                setState(() => pingRemote = '...');
                final result = await _ping(_remoteCtl.text);
                setState(() => pingRemote = result);
              },
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
              onChanged: (v) => setState(() => isRemote = !v),
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
