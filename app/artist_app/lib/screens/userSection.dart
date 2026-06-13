import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  String? id;
  String? username;
  String? email;
  String? role;
  String? token;

  static const _keyId       = 'session_id';
  static const _keyUsername = 'session_username';
  static const _keyEmail    = 'session_email';
  static const _keyRole     = 'session_role';
  static const _keyToken    = 'session_token';

  Future<void> save({
    required String id,
    required String username,
    required String email,
    required String role,
    required String token,
  }) async {
    this.id       = id;
    this.username = username;
    this.email    = email;
    this.role     = role;
    this.token    = token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyId,       id);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyEmail,    email);
    await prefs.setString(_keyRole,     role);
    await prefs.setString(_keyToken,    token);
  }

  Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();
    id       = prefs.getString(_keyId);
    username = prefs.getString(_keyUsername);
    email    = prefs.getString(_keyEmail);
    role     = prefs.getString(_keyRole);
    token    = prefs.getString(_keyToken);
    return id != null && token != null;
  }

  Future<void> clear() async {
    id = username = email = role = token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyToken);
  }

  bool get isArtist => role == 'ARTIST';
  bool get isLoggedIn => id != null && token != null;
}