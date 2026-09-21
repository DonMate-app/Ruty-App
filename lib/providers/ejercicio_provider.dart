import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ejercicio.dart';
import '../models/registro_ejercicio.dart';

class EjercicioProvider extends ChangeNotifier {
  List<Ejercicio> _ejercicios = [];
  List<RegistroEjercicio> _registros = [];

  List<Ejercicio> get ejercicios => _ejercicios;
  List<RegistroEjercicio> get registros => _registros;

  Future<void>? _ultimaEscritura;

  void agregarEjercicio(Ejercicio e) {
    _ejercicios.add(e);
    _guardar();
    notifyListeners();
  }

  void modificarEjercicio(Ejercicio modificado) {
    final idx = _ejercicios.indexWhere((e) => e.id == modificado.id);
    if (idx != -1) {
      _ejercicios[idx] = modificado;
      _guardar();
      notifyListeners();
    }
  }

  void eliminarEjercicio(String id) {
    _ejercicios.removeWhere((e) => e.id == id);
    _registros.removeWhere((r) => r.ejercicioId == id);
    _guardar();
    notifyListeners();
  }

  void agregarRegistro(RegistroEjercicio r) {
    _registros.add(r);
    _guardar();
    notifyListeners();
  }

  void marcarCompletado(String registroId, bool completado) {
    final idx = _registros.indexWhere((r) => r.id == registroId);
    if (idx != -1) {
      _registros[idx].completado = completado;
      _guardar();
      notifyListeners();
    }
  }

  List<RegistroEjercicio> registrosDeDia(DateTime dia) {
    return _registros
        .where((r) =>
            r.fecha.year == dia.year &&
            r.fecha.month == dia.month &&
            r.fecha.day == dia.day)
        .toList();
  }

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final eData = prefs.getString('ejercicios');
    final rData = prefs.getString('registros_ejercicio');
    if (eData != null) {
      _ejercicios = (json.decode(eData) as List)
          .map((e) => Ejercicio.fromJson(e))
          .toList();
    }
    if (rData != null) {
      _registros = (json.decode(rData) as List)
          .map((r) => RegistroEjercicio.fromJson(r))
          .toList();
    }
    notifyListeners();
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
    await prefs.setString(
      'ejercicios',
      json.encode(_ejercicios.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      'registros_ejercicio',
      json.encode(_registros.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> reset() async {
    _ejercicios.clear();
    _registros.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ejercicios');
    await prefs.remove('registros_ejercicio');
    notifyListeners();
  }
}
