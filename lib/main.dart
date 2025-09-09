// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Sunmi printer (3.x)
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// ======= Config & Session =======
final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
//TEST COMMIT 2
class AppConfig {
  static const defaultTypeVenteId = '1'; // AU COMPTANT
  static const defaultNatureVenteId = '1'; // PRESCRIPTION
}

class AppSession {
  String? jsessionCookie; // "JSESSIONID=..."
  bool useLocal = true;

  String localIp = '';
  String remoteIp = '';
  String appName = 'laborex';
  String port = '8080';

  // En-tête ticket
  String officineAuthName = '';     // OFFICINE renvoyé par /user/auth (fallback)
  String phone = '';
  String address = '';

  // /officine
  String officineNomComplet = '';   // nomComplet (nom de la pharmacie)
  String officineFullName = '';     // fullName (pharmacien / DR) - non affiché

  String baseUrl() {
    final ip = useLocal ? localIp : (remoteIp.isNotEmpty ? remoteIp : localIp);
    return 'http://$ip:$port/$appName/api/v1';
  }
}

final appSession = AppSession();

// ======= Utils =======
String formatCFA(int v) =>
    NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0)
        .format(v);

int asInt(dynamic x) {
  if (x == null) return 0;
  if (x is num) return x.toInt();
  return int.tryParse(x.toString()) ?? 0;
}

void showSnack(BuildContext context, String msg) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

class Debouncer {
  Debouncer({required this.milliseconds});
  final int milliseconds;
  Timer? _timer;
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() => _timer?.cancel();
}

// ======= Modèles =======
class Reglement {
  final String id;
  final String name;
  Reglement({required this.id, required this.name});
  factory Reglement.fromJson(Map<String, dynamic> j) =>
      Reglement(id: j['lgTYPEREGLEMENTID'].toString(), name: j['strNAME']?.toString() ?? '');
}

class TypeVente {
  final String id;
  final String name;
  TypeVente({required this.id, required this.name});
  factory TypeVente.fromJson(Map<String, dynamic> j) =>
      TypeVente(id: j['lgTYPEVENTEID'].toString(), name: j['strNAME']?.toString() ?? '');
}

class NatureVente {
  final String id;
  final String libelle;
  NatureVente({required this.id, required this.libelle});
  factory NatureVente.fromJson(Map<String, dynamic> j) =>
      NatureVente(id: j['lgNATUREVENTEID'].toString(), libelle: j['strLIBELLE']?.toString() ?? '');
}

class RemiseClient {
  final String? id; // peut être null pour "SANS REMISE"
  final String label;
  RemiseClient({required this.id, required this.label});
  factory RemiseClient.fromJson(Map<String, dynamic> j) {
    final id = j['lgREMISEID']?.toString();
    final name = j['strNAME']?.toString() ?? '';
    final code = j['strCODE']?.toString();
    return RemiseClient(id: id, label: code != null ? '$name ($code%)' : name);
  }
}

class ProduitSearch {
  final String id;
  final String name;
  final int price;
  final int stock;
  final String cip;
  ProduitSearch(
      {required this.id, required this.name, required this.price, required this.stock, required this.cip});
  factory ProduitSearch.fromJson(Map<String, dynamic> j) => ProduitSearch(
    id: j['lgFAMILLEID'].toString(),
    name: j['strNAME']?.toString() ?? '',
    price: asInt(j['intPRICE']),
    stock: asInt(j['intNUMBERAVAILABLE']),
    cip: j['intCIP']?.toString() ?? '',
  );
}

class VenteItem {
  final String itemId;
  final String produitId;
  final String name;
  final int qty;
  final int pu;
  final int total;
  VenteItem(
      {required this.itemId, required this.produitId, required this.name, required this.qty, required this.pu, required this.total});
  factory VenteItem.fromJson(Map<String, dynamic> j) => VenteItem(
    itemId: j['lgPREENREGISTREMENTDETAILID'].toString(),
    produitId: j['lgFAMILLEID'].toString(),
    name: j['strNAME']?.toString() ?? '',
    qty: asInt(j['intQUANTITY']),
    pu: asInt(j['intPRICEUNITAIR']),
    total: asInt(j['intPRICE']),
  );
}

class NetVente {
  final int montant;
  final int montantNet;
  final int remise;
  NetVente({required this.montant, required this.montantNet, required this.remise});
  factory NetVente.fromJson(Map<String, dynamic> j) {
    final d = j['data'] ?? {};
    final m = asInt(d['montant'] ?? d['montantAccount']);
    final mn = asInt(d['montantNet'] ?? d['montantAccount'] ?? d['montant']);
    final r = d['remise'] != null ? asInt(d['remise']) : (m - mn);
    return NetVente(montant: m, montantNet: mn, remise: r < 0 ? 0 : r);
  }
}

class OfficineInfo {
  final String nomComplet; // officine (nom de la pharmacie)
  final String fullName;   // pharmacien / DR
  OfficineInfo({required this.nomComplet, required this.fullName});
  factory OfficineInfo.fromJson(Map<String, dynamic> j) =>
      OfficineInfo(nomComplet: j['nomComplet']?.toString() ?? '', fullName: j['fullName']?.toString() ?? '');
}

// ======= API Service (JSESSIONID) =======
class ApiService {
  final _client = http.Client();

  Uri _u(String path, [Map<String, String>? q]) =>
      Uri.parse('${appSession.baseUrl()}/$path').replace(queryParameters: q);

  Map<String, String> get _jsonHeaders {
    final h = {'Content-Type': 'application/json'};
    final cookie = appSession.jsessionCookie;
    if (cookie != null && cookie.isNotEmpty) h['Cookie'] = cookie;
    return h;
  }

  void _captureSetCookie(http.Response r) async {
    final sc = r.headers['set-cookie'] ?? r.headers['Set-Cookie'];
    if (sc == null) return;
    final reg = RegExp(r'(JSESSIONID=[^;]+)');
    final m = reg.firstMatch(sc);
    if (m != null) {
      final cookie = m.group(1)!;
      appSession.jsessionCookie = cookie;
      final sp = await SharedPreferences.getInstance();
      await sp.setString('JSESSIONIDCookie', cookie);
    }
  }

  void _autoLogout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('JSESSIONIDCookie');
    appSession.jsessionCookie = null;
    if (navKey.currentState != null) {
      navKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (r) => false,
      );
    }
  }

  Future<http.Response> _get(String path, [Map<String, String>? q]) async {
    final r = await _client.get(_u(path, q), headers: _jsonHeaders);
    if (r.statusCode == 401 || r.statusCode == 403) {
      _autoLogout();
      throw Exception('Session invalide');
    }
    return r;
  }

  Future<http.Response> _post(String path, {Object? body, Map<String, String>? q}) async {
    final r = await _client.post(_u(path, q), headers: _jsonHeaders, body: body);
    if (r.statusCode == 401 || r.statusCode == 403) {
      _autoLogout();
      throw Exception('Session invalide');
    }
    _captureSetCookie(r);
    return r;
  }

  Future<http.Response> _put(String path, {Object? body, Map<String, String>? q}) async {
    final r = await _client.put(_u(path, q), headers: _jsonHeaders, body: body);
    if (r.statusCode == 401 || r.statusCode == 403) {
      _autoLogout();
      throw Exception('Session invalide');
    }
    return r;
  }

  // --- Auth ---
  Future<bool> login(String login, String password) async {
    final body = jsonEncode({'login': login, 'password': password});
    final r = await _post('user/auth', body: body);
    if (r.statusCode != 200) return false;
    final j = jsonDecode(r.body);
    final ok = j['success'] == true;
    if (ok) {
      appSession.officineAuthName = (j['OFFICINE']?.toString() ?? '').trim();
      final sp = await SharedPreferences.getInstance();
      await sp.setString('officineAuthName', appSession.officineAuthName);
    }
    return ok;
  }

  Future<void> logout() async {
    try {
      await _post('user/logout');
    } catch (_) {}
    final sp = await SharedPreferences.getInstance();
    await sp.remove('JSESSIONIDCookie'); // on garde savedLogin/savedPassword si rememberMe=true
    appSession.jsessionCookie = null;
  }

  // --- Officine ---
  Future<OfficineInfo?> fetchOfficine() async {
    try {
      final r = await _get('officine');
      if (r.statusCode != 200) return null;
      final j = jsonDecode(r.body);
      if (j is List && j.isNotEmpty) {
        final info = OfficineInfo.fromJson(j.first);
        appSession.officineNomComplet = info.nomComplet;
        appSession.officineFullName = info.fullName;
        final sp = await SharedPreferences.getInstance();
        await sp.setString('officineNomComplet', info.nomComplet);
        await sp.setString('officineFullName', info.fullName);
        return info;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // --- Common ---
  Future<List<Reglement>> fetchReglements() async {
    final r = await _get('common/reglement', {'page': '1', 'start': '0', 'limit': '25'});
    final j = jsonDecode(r.body);
    final List data = j['data'] ?? [];
    return data.map((e) => Reglement.fromJson(e)).toList();
  }

  Future<List<TypeVente>> fetchTypeVentes() async {
    final r = await _get('common/typeventes', {'page': '1', 'start': '0', 'limit': '25'});
    final j = jsonDecode(r.body);
    final List data = j['data'] ?? [];
    return data.map((e) => TypeVente.fromJson(e)).toList();
  }

  Future<List<NatureVente>> fetchNatures() async {
    final r = await _get('common/natures', {'page': '1', 'start': '0', 'limit': '25'});
    final j = jsonDecode(r.body);
    final List data = j['data'] ?? [];
    return data.map((e) => NatureVente.fromJson(e)).toList();
  }

  Future<List<RemiseClient>> fetchRemises() async {
    final r = await _get('common/remises-client', {'page': '1', 'start': '0', 'limit': '25', 'query': ''});
    final j = jsonDecode(r.body);
    final List data = j['data'] ?? [];
    return data.map((e) => RemiseClient.fromJson(e)).toList();
  }

  Future<bool> autorisationPrixVente() async {
    final r = await _get('common/autorisation-prix-vente');
    final j = jsonDecode(r.body);
    return (j['data'] == true);
  }

  Future<bool> showStock() async {
    final r = await _get('common/autorisations/showstock');
    final j = jsonDecode(r.body);
    return (j['data'] == true);
  }

  // --- Recherche & Vente ---
  Future<List<ProduitSearch>> searchProduits(String query) async {
    if (query.trim().isEmpty) return [];
    final r = await _get('vente/search', {'query': query, 'page': '1', 'start': '0', 'limit': '10'});
    if (r.statusCode != 200) return [];
    final j = jsonDecode(r.body);
    final List data = j['data'] ?? [];
    return data.map((e) => ProduitSearch.fromJson(e)).toList();
  }

  Future<({String venteId, String venteRef, int newTotal})> addFirstItemVno({
    required String typeVenteId,
    required String natureVenteId,
    required String produitId,
    required int itemPu,
    required int qte,
    required int qteServie,
    bool prevente = true,
    String? remiseId,
  }) async {
    final body = jsonEncode({
      'typeVenteId': typeVenteId,
      'natureVenteId': natureVenteId,
      'produitId': produitId,
      'itemPu': itemPu,
      'qte': qte,
      'qteServie': qte,
      'devis': false,
      'remiseId': remiseId,
      'venteId': null,
      'userVendeurId': null,
      'prevente': prevente,
    });
    final r = await _post('vente/add/vno', body: body);
    if (r.statusCode != 200) throw Exception('Erreur add/vno');
    final j = jsonDecode(r.body);
    final d = j['data'] ?? {};
    return (
    venteId: d['lgPREENREGISTREMENTID'].toString(),
    venteRef: d['strREF']?.toString() ?? '',
    newTotal: asInt(d['intPRICE']),
    );
  }

  Future<({int newTotal})> addItem({
    required String typeVenteId,
    required String natureVenteId,
    required String produitId,
    required int itemPu,
    required int qte,
    required int qteServie,
    required String venteId,
    bool prevente = true,
    String? remiseId,
  }) async {
    final body = jsonEncode({
      'typeVenteId': typeVenteId,
      'natureVenteId': natureVenteId,
      'produitId': produitId,
      'itemPu': itemPu,
      'qte': qte,
      'qteServie': qte,
      'devis': false,
      'remiseId': remiseId,
      'venteId': venteId,
      'userVendeurId': null,
      'prevente': prevente,
    });
    final r = await _post('vente/add/item', body: body);
    if (r.statusCode != 200) throw Exception('Erreur add/item');
    final j = jsonDecode(r.body);
    final d = j['data'] ?? {};
    return (newTotal: asInt(d['intPRICE']));
  }

  Future<List<VenteItem>> fetchDetails(String venteId) async {
    final r = await _get('vente/deatails', {
      'venteId': venteId,
      'query': '',
      'statut': '',
      'page': '1',
      'start': '0',
      'limit': '10'
    });
    if (r.statusCode != 200) return [];
    final j = jsonDecode(r.body);
    final List data = j['data'] ?? [];
    return data.map((e) => VenteItem.fromJson(e)).toList();
  }

  Future<bool> removeItem(String itemId) async {
    final r = await _post('vente/remove/vno/item/$itemId');
    return r.statusCode == 200;
  }

  Future<bool> updateItem(
      {required String itemId,
        required String produitId,
        required int itemPu,
        required int qte,
        required int qteServie}) async {
    final body = jsonEncode({
      'itemId': itemId,
      'itemPu': itemPu,
      'qte': qte,
      'qteServie': qteServie,
      'produitId': produitId
    });
    final r = await _post('vente/update/item/vno', body: body);
    return r.statusCode == 200;
  }

  Future<NetVente?> netVno() async {
    final r = await _post('vente/net/vno');
    if (r.statusCode != 200) return null;
    return NetVente.fromJson(jsonDecode(r.body));
  }

  Future<bool> terminerPrevente(String venteId) async {
    final r = await _put('vente/terminerprevente/$venteId');
    if (r.statusCode != 200) return false;
    final j = jsonDecode(r.body);
    return j['success'] == true;
  }

  Future<bool> applyRemise({required String remiseId, required String venteId}) async {
    final body = jsonEncode({'remiseId': remiseId, 'venteId': venteId});
    final r = await _post('vente/remise', body: body);
    if (r.statusCode != 200) return false;
    final j = jsonDecode(r.body);
    return j['success'] == true;
  }
}

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
      home: const StartGate(),
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
    final sp = await SharedPreferences.getInstance();
    appSession.localIp = sp.getString('localIp') ?? '';
    appSession.remoteIp = sp.getString('remoteIp') ?? '';
    appSession.appName = sp.getString('appName') ?? 'laborex';
    appSession.port = sp.getString('port') ?? '8080';
    appSession.useLocal = sp.getBool('useLocal') ?? true;
    appSession.jsessionCookie = sp.getString('JSESSIONIDCookie');

    appSession.officineAuthName = sp.getString('officineAuthName') ?? '';
    appSession.phone = sp.getString('phone') ?? '';
    appSession.address = sp.getString('address') ?? '';

    appSession.officineNomComplet = sp.getString('officineNomComplet') ?? '';
    appSession.officineFullName = sp.getString('officineFullName') ?? '';

    if (appSession.localIp.isEmpty) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
      return;
    }
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}

// ======= Settings =======
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _localCtl = TextEditingController();
  final _remoteCtl = TextEditingController();
  final _appCtl = TextEditingController(text: 'laborex');
  final _portCtl = TextEditingController(text: '8080');
  final _phoneCtl = TextEditingController();
  final _addrCtl = TextEditingController();

  bool useLocal = true;
  String pingLocal = '';
  String pingRemote = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    _localCtl.text = sp.getString('localIp') ?? '';
    _remoteCtl.text = sp.getString('remoteIp') ?? '';
    _appCtl.text = sp.getString('appName') ?? 'laborex';
    _portCtl.text = sp.getString('port') ?? '8080';
    _phoneCtl.text = sp.getString('phone') ?? '';
    _addrCtl.text = sp.getString('address') ?? '';
    useLocal = sp.getBool('useLocal') ?? true;
    setState(() {});
  }

  Future<String> _ping(String ip) async {
    if (ip.isEmpty) return 'Adresse vide';
    final base = 'http://$ip:${_portCtl.text}/${_appCtl.text}/api/v1';
    final url = Uri.parse('$base/vente/cheick-caisse');
    final sw = Stopwatch()..start();
    try {
      final r = await http.get(url).timeout(const Duration(seconds: 4));
      sw.stop();
      final ok = (r.statusCode == 200 || r.statusCode == 401 || r.statusCode == 403);
      return ok ? 'OK (${sw.elapsedMilliseconds} ms)' : 'KO (HTTP ${r.statusCode})';
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

    final sp = await SharedPreferences.getInstance();
    await sp.setString('localIp', _localCtl.text.trim());
    await sp.setString('remoteIp', _remoteCtl.text.trim());
    await sp.setString('appName', _appCtl.text.trim());
    await sp.setString('port', _portCtl.text.trim());
    await sp.setBool('useLocal', useLocal);
    await sp.setString('phone', _phoneCtl.text.trim());
    await sp.setString('address', _addrCtl.text.trim());

    appSession.localIp = _localCtl.text.trim();
    appSession.remoteIp = _remoteCtl.text.trim();
    appSession.appName = _appCtl.text.trim();
    appSession.port = _portCtl.text.trim();
    appSession.useLocal = useLocal;
    appSession.phone = _phoneCtl.text.trim();
    appSession.address = _addrCtl.text.trim();

    if (!mounted) return;
    showSnack(context, 'Configuration enregistrée');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuration')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _localCtl,
                  decoration: const InputDecoration(labelText: 'Adresse IP Locale (requis)'),
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
            ]),
            if (pingLocal.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text('Local: $pingLocal', style: const TextStyle(fontSize: 12)),
              ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _remoteCtl,
                  decoration: const InputDecoration(labelText: 'Adresse IP Distante'),
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
            ]),
            if (pingRemote.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text('Distant: $pingRemote', style: const TextStyle(fontSize: 12)),
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
              decoration: const InputDecoration(labelText: 'Téléphone officine'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addrCtl,
              decoration: const InputDecoration(labelText: 'Adresse officine'),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Utiliser le mode Local (sinon Distant)'),
              value: useLocal,
              onChanged: (v) => setState(() => useLocal = v),
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

// ======= Login =======
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginCtl = TextEditingController();
  final _pwdCtl = TextEditingController();
  final _api = ApiService();

  bool loading = false;
  bool rememberMe = false;
  bool showPwd = false;

  OfficineInfo? _off;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final sp = await SharedPreferences.getInstance();
    rememberMe = sp.getBool('rememberMe') ?? false;

    // Charger /officine
    _off = await _api.fetchOfficine();
    setState(() {});

    // Préremplir si l'utilisateur avait coché "Se souvenir de moi"
    if (rememberMe) {
      _loginCtl.text = sp.getString('savedLogin') ?? '';
      _pwdCtl.text   = sp.getString('savedPassword') ?? '';
    }

    // Auto-login si cookie + rememberMe (pas après un logout car on supprime le cookie)
    if (rememberMe && (appSession.jsessionCookie?.isNotEmpty ?? false)) {
      try {
        await _api.fetchTypeVentes();
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PreventePage()));
        return;
      } catch (_) {}
    }
  }

  Future<void> _submit() async {
    setState(() => loading = true);
    try {
      final ok = await _api.login(_loginCtl.text.trim(), _pwdCtl.text);
      if (!ok) {
        showSnack(context, 'Échec connexion');
      } else {
        final sp = await SharedPreferences.getInstance();
        await sp.setBool('rememberMe', rememberMe);

        // Sauvegarde conditionnelle des identifiants
        if (rememberMe) {
          await sp.setString('savedLogin', _loginCtl.text.trim());
          await sp.setString('savedPassword', _pwdCtl.text);
        } else {
          await sp.remove('savedLogin');
          await sp.remove('savedPassword');
        }

        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PreventePage()));
      }
    } catch (e) {
      showSnack(context, 'Erreur: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final officineName = _off?.nomComplet.isNotEmpty == true
        ? _off!.nomComplet
        : (appSession.officineNomComplet.isNotEmpty ? appSession.officineNomComplet : 'Officine');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          )
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
                child: Text(officineName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _loginCtl,
              decoration: const InputDecoration(labelText: 'Login'),
              onSubmitted: (_) => _submit(),
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
              onSubmitted: (_) => _submit(),
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
                onPressed: loading ? null : _submit,
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

// ======= Prévente / Vente =======
class PreventePage extends StatefulWidget {
  const PreventePage({super.key});
  @override
  State<PreventePage> createState() => _PreventePageState();
}

class _PreventePageState extends State<PreventePage> {
  final api = ApiService();

  // Recherche
  final searchCtl = TextEditingController();
  final searchFocus = FocusNode();
  final debouncer = Debouncer(milliseconds: 400);
  List<ProduitSearch> results = [];
  bool _sheetOpen = false;

  // Listes
  List<TypeVente> typeVentes = [];
  List<NatureVente> natures = [];
  List<Reglement> reglements = [];
  List<RemiseClient> remises = [];

  // Sélection
  String selectedTypeVenteId = AppConfig.defaultTypeVenteId;
  String selectedNatureVenteId = AppConfig.defaultNatureVenteId;
  String? selectedRemiseId;

  // Vente courante
  String? venteId;
  String? venteRef;
  List<VenteItem> panier = [];
  NetVente? net;

  // Autorisations
  bool canEditPrice = true;
  bool showStocks = true;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _initAll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(searchFocus);
    });
  }

  Future<void> _initAll() async {
    setState(() => loading = true);
    try {
      if (appSession.officineNomComplet.isEmpty || appSession.officineFullName.isEmpty) {
        await api.fetchOfficine();
      }

      final tv = await api.fetchTypeVentes();
      final nv = await api.fetchNatures();
      final rg = await api.fetchReglements();
      final rm = await api.fetchRemises();
      bool can = true;
      bool ss = true;
      try {
        can = await api.autorisationPrixVente();
      } catch (_) {}
      try {
        ss = await api.showStock();
      } catch (_) {}
      setState(() {
        typeVentes = tv;
        natures = nv;
        reglements = rg;
        remises = rm;
        canEditPrice = can;
        showStocks = ss;
      });
    } catch (e) {
      showSnack(context, 'Init: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _search(String q) async {
    debouncer.run(() async {
      final r = await api.searchProduits(q);
      if (!mounted) return;
      setState(() => results = r);
      if (results.isNotEmpty && !_sheetOpen) {
        _openResultsSheet();
      }
    });
  }

  Color _chipBg(BuildContext context) =>
      Theme.of(context).colorScheme.primaryContainer.withOpacity(0.18);

  Widget _resultCard(ProduitSearch p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await _addProduit(p);
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        },
        child: Container(
          decoration: BoxDecoration(
            color: _chipBg(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    'CIP: ${p.cip}${showStocks ? '  •  Stock: ${p.stock}' : ''}',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              Text(formatCFA(p.price), style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  void _openResultsSheet() {
    if (_sheetOpen || results.isEmpty) return;
    _sheetOpen = true;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return Material(
              child: ListView.builder(
                controller: controller,
                itemCount: results.length + 1,
                itemBuilder: (c, i) {
                  if (i == 0) {
                    return const ListTile(
                      title: Text('Résultats de recherche'),
                      subtitle: Text('Touchez un article pour l’ajouter'),
                    );
                  }
                  final p = results[i - 1];
                  return _resultCard(p);
                },
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _sheetOpen = false;
      FocusScope.of(context).requestFocus(searchFocus);
      setState(() => results = []);
    });
  }

  Future<void> _addProduit(ProduitSearch p, {int qte = 1}) async {
    try {
      if (venteId == null) {
        final r = await api.addFirstItemVno(
          typeVenteId: selectedTypeVenteId,
          natureVenteId: selectedNatureVenteId,
          produitId: p.id,
          itemPu: p.price,
          qte: qte,
          qteServie: qte,
          prevente: true,
          remiseId: selectedRemiseId,
        );
        venteId = r.venteId;
        venteRef = r.venteRef;
      } else {
        await api.addItem(
          typeVenteId: selectedTypeVenteId,
          natureVenteId: selectedNatureVenteId,
          produitId: p.id,
          itemPu: p.price,
          qte: qte,
          qteServie: qte,
          venteId: venteId!,
          prevente: true,
          remiseId: selectedRemiseId,
        );
      }
      await _reloadPanier();
      searchCtl.clear();
      FocusScope.of(context).requestFocus(searchFocus);
    } catch (e) {
      showSnack(context, 'Ajout produit: $e');
    }
  }

  Future<void> _reloadPanier() async {
    if (venteId == null) {
      setState(() {
        panier = [];
        net = null;
      });
      return;
    }
    final items = await api.fetchDetails(venteId!);
    final n = await api.netVno();
    setState(() {
      panier = items;
      net = n;
    });
  }

  Future<void> _removeItem(VenteItem it) async {
    final ok = await api.removeItem(it.itemId);
    if (ok) {
      await _reloadPanier();
    } else {
      showSnack(context, 'Suppression échouée');
    }
  }

  Future<void> _editItem(VenteItem it) async {
    final qCtl = TextEditingController(text: it.qty.toString());
    final puCtl = TextEditingController(text: it.pu.toString());
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier article'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(it.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
              controller: qCtl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantité')),
          const SizedBox(height: 8),
          TextField(
              controller: puCtl,
              enabled: canEditPrice,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'PU',
                  helperText: canEditPrice ? null : 'Modification du prix non autorisée')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Valider')),
        ],
      ),
    );
    if (ok != true) return;
    final newQty = int.tryParse(qCtl.text.trim()) ?? it.qty;
    final newPu = int.tryParse(puCtl.text.trim()) ?? it.pu;
    final success = await api.updateItem(
        itemId: it.itemId, produitId: it.produitId, itemPu: newPu, qte: newQty, qteServie: newQty);
    if (!success) {
      showSnack(context, 'Échec modification');
      return;
    }
    await _reloadPanier();
  }

  Future<bool> _ensurePrinter() async {
    try {
      final ok = await SunmiPrinter.bindingPrinter();
      if (!ok!) {
        showSnack(context, "Impossible de se lier à l'imprimante Sunmi");
        return false;
      }
      try {
        await SunmiPrinter.initPrinter();
      } catch (_) {}
      return true;
    } catch (e) {
      showSnack(context, 'Sunmi non disponible: $e');
      return false;
    }
  }

  Future<void> _testPrint() async {
    if (!await _ensurePrinter()) return;
    try {
      await SunmiPrinter.startTransactionPrint(true);
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printText('*** TEST IMPRESSION ***',
          style: SunmiStyle(bold: true, fontSize: SunmiFontSize.MD));
      await SunmiPrinter.printText('Modèle interne Sunmi', style: SunmiStyle());
      await SunmiPrinter.lineWrap(3);
    } catch (e) {
      showSnack(context, 'Test impression: $e');
    } finally {
      try {
        await SunmiPrinter.exitTransactionPrint(true);
      } catch (_) {}
    }
  }

  Future<void> _printTicket() async {
    if (!await _ensurePrinter()) return;
    try {
      const int cols = 32;
      String line([String ch = '-']) => List.filled(cols, ch).join();
      String fit(String s, int len) {
        final t = s.replaceAll("\n", " ");
        if (t.runes.length <= len) return t.padRight(len);
        return String.fromCharCodes(t.runes.take(len));
      }
      String r(int v, int len) => v.toString().padLeft(len);

      await SunmiPrinter.startTransactionPrint(true);

      final now = DateTime.now();
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      // >>> Entête: NOM PHARMACIE (nomComplet), pas le pharmacien
      final head = appSession.officineNomComplet.isNotEmpty
          ? appSession.officineNomComplet
          : (appSession.officineAuthName.isNotEmpty ? appSession.officineAuthName : 'PHARMACIE');
      await SunmiPrinter.printText(head.toUpperCase(),
          style: SunmiStyle(bold: true, fontSize: SunmiFontSize.MD));
      if (appSession.address.isNotEmpty) {
        await SunmiPrinter.printText(appSession.address, style: SunmiStyle());
      }
      if (appSession.phone.isNotEmpty) {
        await SunmiPrinter.printText('Tél: ${appSession.phone}', style: SunmiStyle());
      }

      await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      await SunmiPrinter.printText(line());
      await SunmiPrinter.printText("Date: ${DateFormat("dd/MM/yyyy HH:mm").format(now)}");
      await SunmiPrinter.printText(line());

      // En-têtes colonnes (32: 18 | 2 | 5 | 7) — nous affichons Qt sur la 1ère ligne avec *(n)
      await SunmiPrinter.printText(
        fit('Article', 18) + fit('Qt', 2) + fit('PU', 5) + fit('Total', 7),
        style: SunmiStyle(bold: true),
      );

      final items = panier.isEmpty && (venteId != null) ? await api.fetchDetails(venteId!) : panier;
      for (final it in items) {
        // Ligne 1: Nom + *(qte)
        final tag = ' *(${it.qty})';
        final maxName = cols - tag.length;
        final name = fit(it.name, maxName);
        await SunmiPrinter.printText(name + tag, style: SunmiStyle(fontSize: SunmiFontSize.SM));
        // Ligne 2: colonnes PU/Total alignées (18|2|5|7)
        final left = ' ' * 20;
        final pu = r(it.pu, 5);
        final tot = r(it.total, 7);
        await SunmiPrinter.printText(left + pu + tot);
      }

      await SunmiPrinter.printText(line());

      // Totaux
      final n = await api.netVno();
      final montant = n?.montant ?? items.fold<int>(0, (a, b) => a + b.total);
      final remise = n?.remise ?? 0;
      final netAPayer = (n?.montantNet ?? (montant - remise));

      await SunmiPrinter.setAlignment(SunmiPrintAlign.RIGHT);
      await SunmiPrinter.printText('Montant: ${formatCFA(montant)}');
      await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      await SunmiPrinter.printText('Remise:  ${formatCFA(remise)}');
      await SunmiPrinter.setAlignment(SunmiPrintAlign.RIGHT);
      await SunmiPrinter.printText('NET À PAYER: ${formatCFA(netAPayer)}',
          style: SunmiStyle(bold: true));

      // QR code: afficher la référence/ID sans préfixe
      final code = (venteRef != null && venteRef!.isNotEmpty) ? venteRef! : (venteId ?? 'VENTE');
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printQRCode(code);
      await SunmiPrinter.printText(code);

      await SunmiPrinter.lineWrap(3);
      try {
        await SunmiPrinter.cut();
      } catch (_) {}
    } catch (e) {
      showSnack(context, 'Impression: $e');
    } finally {
      try {
        await SunmiPrinter.exitTransactionPrint(true);
      } catch (_) {}
    }
  }

  Future<void> _chooseRemiseFlow() async {
    if (remises.isEmpty) {
      try {
        remises = await api.fetchRemises();
      } catch (_) {}
    }

    String? tmpId = selectedRemiseId;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('Choisir une remise'),
                subtitle: Text('La remise s’applique à la vente en cours'),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: remises.length,
                  itemBuilder: (c, i) {
                    final r = remises[i];
                    return RadioListTile<String?>(
                      title: Text(r.label),
                      value: r.id,
                      groupValue: tmpId,
                      onChanged: (v) => setState(() => tmpId = v),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Annuler'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Appliquer'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (ok != true) return;

    selectedRemiseId = tmpId;

    if (venteId != null) {
      if (selectedRemiseId != null) {
        final applied = await api.applyRemise(remiseId: selectedRemiseId!, venteId: venteId!);
        if (!applied) {
          showSnack(context, 'Application de la remise échouée');
        }
      }
      await _reloadPanier();
    } else {
      showSnack(context, 'Remise sélectionnée: elle sera appliquée au premier ajout.');
    }
  }

  Future<void> _terminerPrevente() async {
    if (venteId == null) return;
    final ok = await api.terminerPrevente(venteId!);
    if (!ok) {
      showSnack(context, 'Échec terminer prévente');
      return;
    }

    final wantPrint = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Impression'),
        content: const Text('Voulez-vous imprimer le ticket ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Non')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Oui')),
        ],
      ),
    );

    if (wantPrint == true) await _printTicket();

    setState(() {
      venteId = null;
      venteRef = null;
      panier = [];
      net = null;
      selectedTypeVenteId = AppConfig.defaultTypeVenteId;
      selectedNatureVenteId = AppConfig.defaultNatureVenteId;
      selectedRemiseId = null;
      results = [];
    });
    await _initAll();
    searchCtl.clear();
    FocusScope.of(context).requestFocus(searchFocus);
  }

  @override
  void dispose() {
    searchCtl.dispose();
    searchFocus.dispose();
    debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topBar = Row(children: [
      Expanded(
        child: DropdownButtonFormField<String>(
          value: selectedTypeVenteId,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Type de vente'),
          items: typeVentes
              .map((e) => DropdownMenuItem(
              value: e.id, child: Text(e.name, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: null, // grisé
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: DropdownButtonFormField<String>(
          value: selectedNatureVenteId,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Nature de vente'),
          items: natures
              .map((e) => DropdownMenuItem(
              value: e.id, child: Text(e.libelle, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: null, // grisé
        ),
      ),
    ]);

    final searchBox = TextField(
      controller: searchCtl,
      focusNode: searchFocus,
      autofocus: true,
      decoration: InputDecoration(
        labelText: 'Recherche produit (CIP / nom)',
        suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            tooltip: 'Voir résultats',
            icon: const Icon(Icons.list),
            onPressed: results.isEmpty ? null : _openResultsSheet,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              searchCtl.clear();
              setState(() => results = []);
              FocusScope.of(context).requestFocus(searchFocus);
            },
          ),
        ]),
      ),
      onChanged: _search,
      onSubmitted: (v) {
        if (results.length == 1) {
          _addProduit(results.first);
        } else {
          _openResultsSheet();
        }
      },
    );

    // ==== Corps scrollable ====
    final List<Widget> listChildren = [
      // (Demandé) Pas d'affichage nomComplet + fullName sur la page Prévente
      topBar,
      const SizedBox(height: 12),
      searchBox,
      const SizedBox(height: 12),

      // Panier
      if (panier.isEmpty)
        Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Panier vide'),
        )
      else
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              for (final it in panier) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ligne 1: nom
                      Text(it.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      // Ligne 2: QTE/PU + actions
                      Row(
                        children: [
                          Text('QTE: ${it.qty}  /  PU: ${formatCFA(it.pu)}'),
                          const Spacer(),
                          IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              tooltip: 'Modifier',
                              onPressed: () => _editItem(it)),
                          IconButton(
                              icon: const Icon(Icons.delete_forever, size: 20),
                              tooltip: 'Supprimer',
                              onPressed: () => _removeItem(it)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ]
            ],
          ),
        ),

      const SizedBox(height: 12),

      // Totaux
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Montant', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(formatCFA(net?.montant ?? panier.fold<int>(0, (a, b) => a + b.total))),
            ]),
            const Divider(),
            Row(
              children: [
                const Expanded(
                  child: Text('Net à payer',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Text(
                  formatCFA(net?.montantNet ??
                      ((net?.montant ?? panier.fold<int>(0, (a, b) => a + b.total)) -
                          (net?.remise ?? 0))),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ]),
        ),
      ),

      const SizedBox(height: 8),

      // Actions : Remise + Terminer
      Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.percent),
            label: Text(selectedRemiseId == null ? 'Remise' : 'Remise (appliquée)'),
            onPressed: _chooseRemiseFlow,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('Terminer prévente'),
            onPressed: (venteId == null) ? null : _terminerPrevente,
          ),
        ),
      ]),
      const SizedBox(height: 12),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prévente / Vente'),
        actions: [
          IconButton(icon: const Icon(Icons.print), onPressed: _testPrint, tooltip: 'Test imprimante'),
          IconButton(
            tooltip: appSession.useLocal ? 'Basculer vers Distant' : 'Basculer vers Local',
            icon: Icon(appSession.useLocal ? Icons.wifi : Icons.public),
            onPressed: () async {
              appSession.useLocal = !appSession.useLocal;
              final sp = await SharedPreferences.getInstance();
              await sp.setBool('useLocal', appSession.useLocal);
              searchCtl.clear();
              setState(() {
                results = [];
                venteId = null;
                venteRef = null;
                panier = [];
                net = null;
              });
              _initAll();
            },
          ),
          if (venteRef != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(child: Text('Réf: $venteRef')),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await api.logout(); // supprime cookie, garde login/pwd si rememberMe=true
              Navigator.pushAndRemoveUntil(
                  context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ListView(children: listChildren),
        ),
      ),
    );
  }
}
