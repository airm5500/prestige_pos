import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static ApiClient? _instance;
  final SharedPreferences _prefs;

  String? _token;
  String? _localIp;
  String? _remoteIp;
  String? _apiBaseUrl;
  int? _port;
  bool? _isRemote;

  ApiClient._(this._prefs) {
    _token = _prefs.getString('token');
  }

  static Future<ApiClient> init() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = ApiClient._(prefs);
    }
    return _instance!;
  }

  bool get rememberMe => _prefs.getBool('rememberMe') ?? false;

  set rememberMe(bool value) {
    _prefs.setBool('rememberMe', value);
  }

  String? get username => _prefs.getString('username');

  set username(String? value) {
    if (value == null) {
      _prefs.remove('username');
    } else {
      _prefs.setString('username', value);
    }
  }

  String? get password => _prefs.getString('password');

  set password(String? value) {
    if (value == null) {
      _prefs.remove('password');
    } else {
      _prefs.setString('password', value);
    }
  }

  String? get phone => _prefs.getString('phone');

  set phone(String? value) {
    if (value == null) {
      _prefs.remove('phone');
    } else {
      _prefs.setString('phone', value);
    }
  }

  String? get address => _prefs.getString('address');

  set address(String? value) {
    if (value == null) {
      _prefs.remove('address');
    } else {
      _prefs.setString('address', value);
    }
  }

  String? get appName => _prefs.getString('appName');

  set appName(String? value) {
    if (value == null) {
      _prefs.remove('appName');
    } else {
      _prefs.setString('appName', value);
    }
  }

  String? get apiBaseUrl => _prefs.getString('apiBaseUrl');

  int? get port => _prefs.getInt('port');

  String? get localIp => _prefs.getString('localIp');

  String? get remoteIp => _prefs.getString('remoteIp');

  bool get isRemote => _prefs.getBool('isRemote') ?? false;

  set isRemote(bool value) {
    _isRemote = value;
    _prefs.setBool('isRemote', value);
  }

  set apiBaseUrl(String? value) {
    _apiBaseUrl = value;
    if (value == null) {
      _prefs.remove('apiBaseUrl');
    } else {
      _prefs.setString('apiBaseUrl', value);
    }
  }

  String? get token => _token;

  set token(String? value) {
    _token = value;
    if (value == null) {
      _prefs.remove('token');
    } else {
      _prefs.setString('token', value);
    }
  }

  Map<String, String> get headers => {
    'Content-Type': 'application/json; charset=UTF-8',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<void> clearToken() async {
    _token = null;
    await _prefs.remove('token');
  }

  set localIp(String? value) {
    _localIp = value;
    if (value == null) {
      _prefs.remove('localIp');
    } else {
      _prefs.setString('localIp', value);
    }
  }

  Future<void> saveLocalIp(String? value) async {
    _localIp = value;
    if (value == null) {
      await _prefs.remove('localIp');
    } else {
      await _prefs.setString('localIp', value);
    }
  }

  set remoteIp(String? value) {
    _remoteIp = value;
    if (value == null) {
      _prefs.remove('remoteIp');
    } else {
      _prefs.setString('remoteIp', value);
    }
  }

  set port(int? value) {
    _port = value;
    if (value == null) {
      _prefs.remove('port');
    } else {
      _prefs.setInt('port', value);
    }
  }

  String get authUrl {
    final useRemote = _isRemote ?? false;
    final baseUrl = useRemote ? _remoteIp : _localIp;
    final portPart = (_port != null) ? ':$_port' : '';
    return 'http://$baseUrl$portPart/auth/token';
  }

  String getApiUrl() {
    final useRemote = _isRemote ?? false;
    final baseUrl = useRemote ? _remoteIp : _localIp;
   // final apiPart = '/$_apiBaseUrl';
   final apiPart = '/api';
    final portPart = (_port != null) ? ':$_port' : '';
    return 'http://$baseUrl$portPart$apiPart';
  }
}
