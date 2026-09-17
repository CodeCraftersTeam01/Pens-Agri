import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  final int userId;
  final String name;
  final String role; // 'petani' or 'penyuluh'
  final int desaId;
  final String desaName;
  final String kecamatanName;
  final String phone;
  final String nik;
  final String email;

  const UserSession({
    required this.userId,
    required this.name,
    required this.role,
    required this.desaId,
    required this.desaName,
    required this.kecamatanName,
    this.phone = '',
    this.nik = '',
    this.email = '',
  });

  int get selectedDesaId => desaId;
  String get selectedDesaName => desaName;
  String get selectedKecamatan => kecamatanName;
}

class UserSessionService {
  static const String _keyUserId = 'user_session_user_id';
  static const String _keyName = 'user_session_name';
  static const String _keyRole = 'user_session_role';
  static const String _keyDesaId = 'user_session_desa_id';
  static const String _keyDesaName = 'user_session_desa_name';
  static const String _keyKecamatanName = 'user_session_kecamatan_name';
  static const String _keyPhone = 'user_session_phone';
  static const String _keyNik = 'user_session_nik';
  static const String _keyEmail = 'user_session_email';

  // Default fallback session for Penyuluh
  static const UserSession defaultPenyuluhSession = UserSession(
    userId: 2,
    name: 'Penyuluh Pertanian Gapura',
    role: 'penyuluh',
    desaId: 79,
    desaName: 'Gapura Barat',
    kecamatanName: 'Gapura',
    phone: '081298765432',
    nik: '3529000000000002',
    email: 'penyuluh.gapura@sumenep.go.id',
  );

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUserId) && (prefs.getInt(_keyUserId) ?? 0) > 0;
  }

  static Future<UserSession> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_keyUserId);
    if (userId == null) {
      return defaultPenyuluhSession;
    }

    return UserSession(
      userId: userId,
      name: prefs.getString(_keyName) ?? defaultPenyuluhSession.name,
      role: prefs.getString(_keyRole) ?? 'penyuluh',
      desaId: prefs.getInt(_keyDesaId) ?? defaultPenyuluhSession.desaId,
      desaName: prefs.getString(_keyDesaName) ?? defaultPenyuluhSession.desaName,
      kecamatanName: prefs.getString(_keyKecamatanName) ?? defaultPenyuluhSession.kecamatanName,
      phone: prefs.getString(_keyPhone) ?? defaultPenyuluhSession.phone,
      nik: prefs.getString(_keyNik) ?? defaultPenyuluhSession.nik,
      email: prefs.getString(_keyEmail) ?? defaultPenyuluhSession.email,
    );
  }

  static Future<bool> hasCustomSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUserId);
  }

  static Future<void> saveSession(UserSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, session.userId);
    await prefs.setString(_keyName, session.name);
    await prefs.setString(_keyRole, session.role);
    await prefs.setInt(_keyDesaId, session.desaId);
    await prefs.setString(_keyDesaName, session.desaName);
    await prefs.setString(_keyKecamatanName, session.kecamatanName);
    await prefs.setString(_keyPhone, session.phone);
    await prefs.setString(_keyNik, session.nik);
    await prefs.setString(_keyEmail, session.email);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyName);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyDesaId);
    await prefs.remove(_keyDesaName);
    await prefs.remove(_keyKecamatanName);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyNik);
    await prefs.remove(_keyEmail);
  }
}
