import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LicenciaService {
  static const String _prefActivada = 'licencia_activada';
  static const String _prefCodigoUsado = 'licencia_codigo_usado';
  static const String _prefFechaActivacion = 'licencia_fecha_activacion';
  static const String _prefCodigosQuemados = 'licencia_codigos_quemados';

  static const String _secreto = 'DONMATE_HORARIO_2026_SECRET_v1';
  static const String _prefijo = 'HOR';

  // ═══════════════════════════════════════════════════════════
  // LEMON SQUEEZY (Fase 17.4 — PLACEHOLDER)
  // ═══════════════════════════════════════════════════════════

  /// TODO 17.4: poner en `true` cuando el co-dev cree la cuenta
  /// de Lemon Squeezy y se configuren la API key y las URLs.
  static const bool _lemonSqueezyConfigurado = false;

  /// URL de validación de licencias de Lemon Squeezy.
  static const String _urlValidacionLemonSqueezy =
      'https://api.lemonsqueezy.com/v1/licenses/validate';

  /// TODO 17.4: API key de DonMate en Lemon Squeezy.
  static const String _apiKeyLemonSqueezy = 'PLACEHOLDER_API_KEY';

  /// ¿El código tiene formato de Lemon Squeezy? (XXXX-XXXX-XXXX-XXXX)
  static bool esCodigoLemonSqueezy(String codigo) {
    final regex = RegExp(r'^[A-Z0-9]{4}(-[A-Z0-9]{4}){3}$');
    return regex.hasMatch(codigo.trim().toUpperCase());
  }

  /// Valida online contra Lemon Squeezy.
  /// Devuelve `null` si no se pudo consultar (sin configurar, sin red, error).
  static Future<ResultadoActivacion?> _validarOnlineLemonSqueezy(
    String codigo,
  ) async {
    if (!_lemonSqueezyConfigurado) {
      debugPrint('🔐 [Licencia] Lemon Squeezy aún no configurado');
      return null;
    }
    try {
      final response = await http.post(
        Uri.parse(_urlValidacionLemonSqueezy),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $_apiKeyLemonSqueezy',
        },
        body: {'license_key': codigo},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('🔐 [Licencia] HTTP ${response.statusCode}');
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['valid'] == true) {
        return ResultadoActivacion.exito();
      }
      final error = json['error'] as String? ?? 'Licencia inválida';
      return ResultadoActivacion.error(error);
    } catch (e) {
      debugPrint('🔐 [Licencia] Error online: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // GENERACIÓN OFFLINE (solo para el desarrollador)
  // ═══════════════════════════════════════════════════════════

  static String generarCodigo(int seed) {
    final data = '$seed:$_secreto';
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes).toString().toUpperCase();

    final b1 = hash.substring(0, 4);
    final b2 = hash.substring(4, 8);
    final checksum = _calcularChecksum(b1, b2);

    return '$_prefijo-$b1-$b2-$checksum';
  }

  static String _calcularChecksum(String bloque1, String bloque2) {
    final data = '$bloque1$bloque2$_secreto';
    final hash = sha256.convert(utf8.encode(data)).toString().toUpperCase();
    return hash.substring(0, 2);
  }

  // ═══════════════════════════════════════════════════════════
  // VALIDACIÓN OFFLINE
  // ═══════════════════════════════════════════════════════════

  static bool validarFormato(String codigo) {
    final codigoLimpio = codigo.trim().toUpperCase();
    final regex = RegExp(r'^HOR-([A-F0-9]{4})-([A-F0-9]{4})-([A-F0-9]{2})$');
    final match = regex.firstMatch(codigoLimpio);
    if (match == null) return false;

    final b1 = match.group(1)!;
    final b2 = match.group(2)!;
    final cc = match.group(3)!;

    final ccEsperado = _calcularChecksum(b1, b2);
    return cc == ccEsperado;
  }

  // ═══════════════════════════════════════════════════════════
  // ACTIVACIÓN
  // ═══════════════════════════════════════════════════════════

  static Future<ResultadoActivacion> activar(String codigo) async {
    final codigoLimpio = codigo.trim().toUpperCase();

    if (codigoLimpio.isEmpty) {
      return ResultadoActivacion.error('Escribe un código');
    }

    // 1) Formato Lemon Squeezy → validar online
    if (esCodigoLemonSqueezy(codigoLimpio)) {
      final resultadoOnline = await _validarOnlineLemonSqueezy(codigoLimpio);
      if (resultadoOnline != null) {
        if (resultadoOnline.exitoso) {
          await _guardarActivacion(codigoLimpio, quemar: false);
        }
        return resultadoOnline;
      }
      return ResultadoActivacion.error(
        'No se pudo validar el código. Verifica tu conexión.',
      );
    }

    // 2) Formato offline (HOR-XXXX-XXXX-XX) → validar checksum
    if (!validarFormato(codigoLimpio)) {
      return ResultadoActivacion.error(
        'Código inválido. Verifica que esté bien escrito.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final codigosQuemados =
        prefs.getStringList(_prefCodigosQuemados) ?? <String>[];
    if (codigosQuemados.contains(codigoLimpio)) {
      return ResultadoActivacion.error(
        'Este código ya fue utilizado en este dispositivo.',
      );
    }

    await _guardarActivacion(codigoLimpio, quemar: true);
    return ResultadoActivacion.exito();
  }

  static Future<void> _guardarActivacion(
    String codigo, {
    required bool quemar,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefActivada, true);
    await prefs.setString(_prefCodigoUsado, codigo);
    await prefs.setString(
      _prefFechaActivacion,
      DateTime.now().toIso8601String(),
    );

    if (quemar) {
      final codigosQuemados =
          prefs.getStringList(_prefCodigosQuemados) ?? <String>[];
      if (!codigosQuemados.contains(codigo)) {
        codigosQuemados.add(codigo);
        await prefs.setStringList(_prefCodigosQuemados, codigosQuemados);
      }
    }
  }

  static Future<bool> estaActivada() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefActivada) ?? false;
  }

  static Future<String?> codigoUsado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefCodigoUsado);
  }

  static Future<DateTime?> fechaActivacion() async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString(_prefFechaActivacion);
    if (iso == null) return null;
    return DateTime.tryParse(iso);
  }

  static Future<void> desactivar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefActivada, false);
    await prefs.remove(_prefCodigoUsado);
    await prefs.remove(_prefFechaActivacion);
  }

  static Future<void> resetTotal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefActivada);
    await prefs.remove(_prefCodigoUsado);
    await prefs.remove(_prefFechaActivacion);
    await prefs.remove(_prefCodigosQuemados);
  }
}

class ResultadoActivacion {
  final bool exitoso;
  final String? mensaje;

  ResultadoActivacion._({required this.exitoso, this.mensaje});

  factory ResultadoActivacion.exito() => ResultadoActivacion._(exitoso: true);

  factory ResultadoActivacion.error(String mensaje) =>
      ResultadoActivacion._(exitoso: false, mensaje: mensaje);
}
