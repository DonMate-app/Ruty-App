import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LicenciaService {
  static const String _prefActivada = 'licencia_activada';
  static const String _prefCodigoUsado = 'licencia_codigo_usado';
  static const String _prefFechaActivacion = 'licencia_fecha_activacion';
  static const String _prefCodigosQuemados = 'licencia_codigos_quemados';

  /// Secreto interno para el checksum.
  /// ⚠️ Cambia este string si quieres regenerar todos los códigos.
  static const String _secreto = 'DONMATE_HORARIO_2026_SECRET_v1';

  static const String _prefijo = 'HOR';

  // ──────────────────────────────────────────────────────────
  // GENERACIÓN (solo para el desarrollador)
  // ──────────────────────────────────────────────────────────

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

  // ──────────────────────────────────────────────────────────
  // VALIDACIÓN
  // ──────────────────────────────────────────────────────────

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

  // ──────────────────────────────────────────────────────────
  // ACTIVACIÓN
  // ──────────────────────────────────────────────────────────

  static Future<ResultadoActivacion> activar(String codigo) async {
    final codigoLimpio = codigo.trim().toUpperCase();

    if (codigoLimpio.isEmpty) {
      return ResultadoActivacion.error('Escribe un código');
    }

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

    await prefs.setBool(_prefActivada, true);
    await prefs.setString(_prefCodigoUsado, codigoLimpio);
    await prefs.setString(
      _prefFechaActivacion,
      DateTime.now().toIso8601String(),
    );

    codigosQuemados.add(codigoLimpio);
    await prefs.setStringList(_prefCodigosQuemados, codigosQuemados);

    return ResultadoActivacion.exito();
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
