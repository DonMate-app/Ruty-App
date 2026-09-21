import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notificacion_pref.dart';

class NotificacionesPrefsProvider extends ChangeNotifier {
  static const List<String> categorias = [
    'eventos',
    'tareas',
    'rutinas',
    'medicacion',
    'comunidad',
  ];

  Map<String, NotificacionPref> _prefs = {};

  NotificacionPref getPref(String categoria) {
    return _prefs[categoria] ?? NotificacionPref();
  }

  Future<void>? _ultimaEscritura;

  void actualizarPref(String categoria, NotificacionPref pref) {
    _prefs[categoria] = pref;
    _guardar();
    notifyListeners();
  }

  void toggleHabilitada(String categoria, bool valor) {
    final pref = getPref(categoria);
    pref.habilitada = valor;
    _prefs[categoria] = pref;
    _guardar();
    notifyListeners();
  }

  void cambiarSonido(String categoria, String sonido) {
    final pref = getPref(categoria);
    pref.sonido = sonido;
    if (sonido != 'custom') {
      pref.customSoundPath = null;
    }
    _prefs[categoria] = pref;
    _guardar();
    notifyListeners();
  }

  void cambiarSonidoPersonalizado(String categoria, String path) {
    final pref = getPref(categoria);
    pref.sonido = 'custom';
    pref.customSoundPath = path;
    _prefs[categoria] = pref;
    _guardar();
    notifyListeners();
  }

  void toggleVibracion(String categoria, bool valor) {
    final pref = getPref(categoria);
    pref.vibracion = valor;
    _prefs[categoria] = pref;
    _guardar();
    notifyListeners();
  }

  void togglePantallaCompleta(String categoria, bool valor) {
    final pref = getPref(categoria);
    pref.pantallaCompleta = valor;
    _prefs[categoria] = pref;
    _guardar();
    notifyListeners();
  }

  void toggleDespertarPantalla(String categoria, bool valor) {
    final pref = getPref(categoria);
    pref.despertarPantalla = valor;
    _prefs[categoria] = pref;
    _guardar();
    notifyListeners();
  }

  void toggleModoAlarma(String categoria, bool valor) {
    final pref = getPref(categoria);
    pref.modoAlarma = valor;
    _prefs[categoria] = pref;
    _guardar();
    notifyListeners();
  }

  void cambiarAnticipacion(String categoria, int minutos) {
    final pref = getPref(categoria);
    pref.anticipacionMinutos = minutos;
    _prefs[categoria] = pref;
    _guardar();
    notifyListeners();
  }

  void cambiarReintento(String categoria, int minutos) {
    final pref = getPref(categoria);
    pref.reintentoMinutos = minutos;
    _prefs[categoria] = pref;
    _guardar();
    notifyListeners();
  }

  void cambiarMaxReintentos(String categoria, int max) {
    final pref = getPref(categoria);
    pref.maxReintentos = max;
    _prefs[categoria] = pref;
    _guardar();
    notifyListeners();
  }

  void cambiarSnooze(String categoria, int minutos) {
    final pref = getPref(categoria);
    pref.snoozeMinutos = minutos;
    _prefs[categoria] = pref;
    _guardar();
    notifyListeners();
  }

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('notificaciones_prefs');
    if (data != null) {
      final Map<String, dynamic> jsonData = json.decode(data);
      _prefs = jsonData.map(
        (key, value) => MapEntry(key, NotificacionPref.fromJson(value)),
      );
      notifyListeners();
    }
  }

  Future<void> _guardar() async {
    if (_ultimaEscritura != null) {
      await _ultimaEscritura;
    }
    _ultimaEscritura = _realizarGuardado();
    await _ultimaEscritura;
  }

  Future<void> _realizarGuardado() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> data = _prefs.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await prefs.setString('notificaciones_prefs', json.encode(data));
  }

  Future<void> reset() async {
    _prefs.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notificaciones_prefs');
  }
}
