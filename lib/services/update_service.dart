import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/update_info.dart';

class UpdateService {
  /// ⚠️ CAMBIA 'DonMate' por tu usuario real de GitHub cuando crees el repo.
  /// El repositorio debe llamarse 'Ruty-App'.
  static const String _urlVersionJson =
      'https://raw.githubusercontent.com/DonMate/Ruty-App/main/version.json';

  /// Intervalo mínimo entre comprobaciones automáticas.
  static const Duration _intervaloChequeo = Duration(hours: 6);

  /// Consulta si hay una nueva versión disponible.
  static Future<UpdateInfo?> verificarActualizacion() async {
    try {
      debugPrint('📦 [Update] Consultando $_urlVersionJson');

      final response = await http
          .get(Uri.parse(_urlVersionJson))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('📦 [Update] Error HTTP: ${response.statusCode}');
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final info = UpdateInfo.fromJson(json);

      final packageInfo = await PackageInfo.fromPlatform();
      final versionCodeActual = int.tryParse(packageInfo.buildNumber) ?? 1;

      debugPrint(
        '📦 [Update] Actual: $versionCodeActual, '
        'Disponible: ${info.versionCode}',
      );

      if (info.versionCode > versionCodeActual) {
        return info;
      }
      return null;
    } catch (e) {
      debugPrint('📦 [Update] Error: $e');
      return null;
    }
  }

  /// Devuelve el `versionCode` actual de la app.
  static Future<int> versionCodeActual() async {
    final info = await PackageInfo.fromPlatform();
    return int.tryParse(info.buildNumber) ?? 1;
  }

  /// Devuelve el `versionName` actual (ej. "1.0.1").
  static Future<String> versionNameActual() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  /// Comprueba si ha pasado el intervalo mínimo desde la última consulta.
  static Future<bool> debeChequear() async {
    final prefs = await SharedPreferences.getInstance();
    final ultima = prefs.getInt('update_ultima_consulta');
    if (ultima == null) return true;

    final ahora = DateTime.now().millisecondsSinceEpoch;
    final diferencia = Duration(milliseconds: ahora - ultima);
    return diferencia >= _intervaloChequeo;
  }

  /// Guarda la fecha de la última consulta.
  static Future<void> marcarConsultado() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'update_ultima_consulta',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Registra la versión que el usuario decidió posponer.
  static Future<void> posponerVersion(int versionCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('update_version_pospuesta', versionCode);
  }

  /// Devuelve la versión que el usuario pospuso (o null).
  static Future<int?> versionPospuesta() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('update_version_pospuesta');
  }

  /// Resetea el estado de update (útil en reset de datos).
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('update_ultima_consulta');
    await prefs.remove('update_version_pospuesta');
  }
}
