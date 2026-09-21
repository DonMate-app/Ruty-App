import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/alimento_registro.dart';

class AlimentacionProvider extends ChangeNotifier {
  List<AlimentoRegistro> _registros = [];
  List<AlimentoRegistro> get registros => _registros;

  Future<void>? _ultimaEscritura;

  void agregarRegistro(AlimentoRegistro r) {
    _registros.add(r);
    _guardar();
    notifyListeners();
  }

  void modificarRegistro(AlimentoRegistro modificado) {
    final idx = _registros.indexWhere((r) => r.id == modificado.id);
    if (idx != -1) {
      _registros[idx] = modificado;
      _guardar();
      notifyListeners();
    }
  }

  void eliminarRegistro(String id) {
    _registros.removeWhere((r) => r.id == id);
    _guardar();
    notifyListeners();
  }

  List<AlimentoRegistro> registrosDeDia(DateTime dia) {
    return _registros
        .where((r) =>
            r.fechaHora.year == dia.year &&
            r.fechaHora.month == dia.month &&
            r.fechaHora.day == dia.day)
        .toList()
      ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
  }

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('alimentacion');
    if (data != null) {
      final lista = json.decode(data) as List;
      _registros = lista.map((e) => AlimentoRegistro.fromJson(e)).toList();
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
    await prefs.setString(
      'alimentacion',
      json.encode(_registros.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> reset() async {
    _registros.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('alimentacion');
    notifyListeners();
  }
}
