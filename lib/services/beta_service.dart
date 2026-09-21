import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BetaService {
  static const String _prefBetaActivado = 'beta_activado';
  static const String _prefBetaFecha = 'beta_fecha_activacion';

  /// Códigos beta válidos. Se los das a tus testers.
  static const List<String> codigosBetaValidos = [
    'BETA-DONMATE-2026-A1',
    'BETA-DONMATE-2026-A2',
    'BETA-DONMATE-2026-A3',
    'BETA-DONMATE-2026-A4',
    'BETA-DONMATE-2026-A5',
  ];

  static Future<bool> estaActivado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefBetaActivado) ?? false;
  }

  static Future<DateTime?> fechaActivacion() async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString(_prefBetaFecha);
    if (iso == null) return null;
    return DateTime.tryParse(iso);
  }

  static Future<bool> activar(String codigo) async {
    final codigoLimpio = codigo.trim().toUpperCase();
    if (!codigosBetaValidos.contains(codigoLimpio)) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefBetaActivado, true);
    await prefs.setString(
      _prefBetaFecha,
      DateTime.now().toIso8601String(),
    );
    return true;
  }

  static Future<void> desactivar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefBetaActivado, false);
    await prefs.remove(_prefBetaFecha);
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefBetaActivado);
    await prefs.remove(_prefBetaFecha);
  }

  static String hashCodigo(String codigo) {
    final bytes = utf8.encode(codigo);
    return sha256.convert(bytes).toString().substring(0, 8);
  }
}