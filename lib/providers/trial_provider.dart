import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum EstadoTrialPro {
  noIniciado,
  activo,
  expirado,
}

enum EstadoTrialStats {
  noIniciado,
  activo,
  expirado,
}

class TrialProvider extends ChangeNotifier {
  static const Duration _duracionPro = Duration(days: 14);
  static const Duration _duracionStats = Duration(days: 30);

  static const String _prefProInicio = 'trial_pro_inicio';
  static const String _prefProHash = 'trial_pro_hash';
  static const String _prefProUsado = 'trial_pro_usado';

  static const String _prefStatsInicio = 'trial_stats_inicio';
  static const String _prefStatsHash = 'trial_stats_hash';
  static const String _prefStatsUsado = 'trial_stats_usado';

  static const String _prefDeviceId = 'trial_device_id';

  static const String _secreto = 'DONMATE_TRIAL_2026_v1';

  DateTime? _proInicio;
  DateTime? _statsInicio;
  bool _proUsado = false;
  bool _statsUsado = false;

  EstadoTrialPro _estadoPro = EstadoTrialPro.noIniciado;
  EstadoTrialStats _estadoStats = EstadoTrialStats.noIniciado;

  EstadoTrialPro get estadoPro => _estadoPro;
  EstadoTrialStats get estadoStats => _estadoStats;

  DateTime? get proInicio => _proInicio;
  DateTime? get statsInicio => _statsInicio;

  bool get proUsado => _proUsado;
  bool get statsUsado => _statsUsado;

  bool get proActivo => _estadoPro == EstadoTrialPro.activo;
  bool get statsActivo => _estadoStats == EstadoTrialStats.activo;

  bool get proDisponible =>
      _estadoPro == EstadoTrialPro.noIniciado && !_proUsado;

  int get diasRestantesPro {
    if (_proInicio == null) return 0;
    final fin = _proInicio!.add(_duracionPro);
    final dias = fin.difference(DateTime.now()).inDays;
    return dias > 0 ? dias : 0;
  }

  int get diasRestantesStats {
    if (_statsInicio == null) return 0;
    final fin = _statsInicio!.add(_duracionStats);
    final dias = fin.difference(DateTime.now()).inDays;
    return dias > 0 ? dias : 0;
  }

  int get horasRestantesPro {
    if (_proInicio == null) return 0;
    final fin = _proInicio!.add(_duracionPro);
    final h = fin.difference(DateTime.now()).inHours;
    return h > 0 ? h : 0;
  }

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();

    final deviceId = prefs.getString(_prefDeviceId);
    if (deviceId == null) {
      await prefs.setString(_prefDeviceId, _generarDeviceId());
    }

    final proInicioStr = prefs.getString(_prefProInicio);
    final proHashStr = prefs.getString(_prefProHash);
    final proUsadoBool = prefs.getBool(_prefProUsado) ?? false;

    if (proInicioStr != null && proHashStr != null) {
      if (_verificarHash(proInicioStr, proHashStr)) {
        _proInicio = DateTime.tryParse(proInicioStr);
      } else {
        _proUsado = true;
      }
    }
    _proUsado = _proUsado || proUsadoBool;

    final statsInicioStr = prefs.getString(_prefStatsInicio);
    final statsHashStr = prefs.getString(_prefStatsHash);
    final statsUsadoBool = prefs.getBool(_prefStatsUsado) ?? false;

    if (statsInicioStr != null && statsHashStr != null) {
      if (_verificarHash(statsInicioStr, statsHashStr)) {
        _statsInicio = DateTime.tryParse(statsInicioStr);
      } else {
        _statsUsado = true;
      }
    }
    _statsUsado = _statsUsado || statsUsadoBool;

    _recalcularEstados();
    await _verificarBackupSecundario();

    notifyListeners();
  }

  Future<bool> iniciarTrials() async {
    if (_proUsado || !proDisponible) return false;

    final ahora = DateTime.now();
    _proInicio = ahora;
    _statsInicio = ahora;
    _proUsado = true;
    _statsUsado = true;

    final prefs = await SharedPreferences.getInstance();
    final proIso = ahora.toIso8601String();
    final statsIso = ahora.toIso8601String();

    await prefs.setString(_prefProInicio, proIso);
    await prefs.setString(_prefProHash, _generarHash(proIso));
    await prefs.setBool(_prefProUsado, true);

    await prefs.setString(_prefStatsInicio, statsIso);
    await prefs.setString(_prefStatsHash, _generarHash(statsIso));
    await prefs.setBool(_prefStatsUsado, true);

    await _guardarBackupSecundario(proIso, statsIso);

    _recalcularEstados();
    notifyListeners();
    return true;
  }

  void _recalcularEstados() {
    final ahora = DateTime.now();

    if (_proInicio == null) {
      _estadoPro =
          _proUsado ? EstadoTrialPro.expirado : EstadoTrialPro.noIniciado;
    } else {
      final fin = _proInicio!.add(_duracionPro);
      _estadoPro =
          ahora.isBefore(fin) ? EstadoTrialPro.activo : EstadoTrialPro.expirado;
    }

    if (_statsInicio == null) {
      _estadoStats =
          _statsUsado ? EstadoTrialStats.expirado : EstadoTrialStats.noIniciado;
    } else {
      final fin = _statsInicio!.add(_duracionStats);
      _estadoStats = ahora.isBefore(fin)
          ? EstadoTrialStats.activo
          : EstadoTrialStats.expirado;
    }
  }

  Future<File> _backupFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/.trial_data_${_hashCorto()}.dat');
  }

  Future<void> _guardarBackupSecundario(
    String proIso,
    String statsIso,
  ) async {
    try {
      final file = await _backupFile();
      final data = {
        'pro': proIso,
        'stats': statsIso,
        'hash_pro': _generarHash(proIso),
        'hash_stats': _generarHash(statsIso),
        'firma': _generarHash('$proIso|$statsIso|$_secreto'),
      };
      await file.writeAsString(json.encode(data));
    } catch (_) {}
  }

  Future<void> _verificarBackupSecundario() async {
    try {
      final file = await _backupFile();
      if (!await file.exists()) return;

      final contenido = await file.readAsString();
      final data = json.decode(contenido) as Map<String, dynamic>;

      final proIso = data['pro'] as String?;
      final statsIso = data['stats'] as String?;
      final firma = data['firma'] as String?;

      if (proIso == null || statsIso == null || firma == null) return;

      final firmaEsperada = _generarHash('$proIso|$statsIso|$_secreto');
      if (firma != firmaEsperada) return;

      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_prefProInicio) == null) {
        await prefs.setString(_prefProInicio, proIso);
        await prefs.setString(_prefProHash, _generarHash(proIso));
        await prefs.setBool(_prefProUsado, true);
        _proInicio = DateTime.tryParse(proIso);
        _proUsado = true;
      }
      if (prefs.getString(_prefStatsInicio) == null) {
        await prefs.setString(_prefStatsInicio, statsIso);
        await prefs.setString(_prefStatsHash, _generarHash(statsIso));
        await prefs.setBool(_prefStatsUsado, true);
        _statsInicio = DateTime.tryParse(statsIso);
        _statsUsado = true;
      }

      _recalcularEstados();
    } catch (_) {}
  }

  String _generarHash(String valor) {
    final data = '$valor|$_secreto';
    return sha256.convert(utf8.encode(data)).toString();
  }

  bool _verificarHash(String valor, String hash) {
    return _generarHash(valor) == hash;
  }

  String _generarDeviceId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final data = 'device_$now|$_secreto';
    return sha256.convert(utf8.encode(data)).toString().substring(0, 16);
  }

  String _hashCorto() {
    final data = 'trial_$_secreto';
    return sha256.convert(utf8.encode(data)).toString().substring(0, 8);
  }

  Future<void> reset() async {
    _proInicio = null;
    _statsInicio = null;
    _proUsado = false;
    _statsUsado = false;
    _estadoPro = EstadoTrialPro.noIniciado;
    _estadoStats = EstadoTrialStats.noIniciado;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefProInicio);
    await prefs.remove(_prefProHash);
    await prefs.remove(_prefProUsado);
    await prefs.remove(_prefStatsInicio);
    await prefs.remove(_prefStatsHash);
    await prefs.remove(_prefStatsUsado);

    try {
      final file = await _backupFile();
      if (await file.exists()) await file.delete();
    } catch (_) {}

    notifyListeners();
  }
}
