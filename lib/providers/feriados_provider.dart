import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/feriados_data.dart';
import '../models/feriado.dart';

class FeriadosProvider extends ChangeNotifier {
  String _paisCodigo = 'VE';
  bool _mostrarFeriados = true;

  String get paisCodigo => _paisCodigo;
  bool get mostrarFeriados => _mostrarFeriados;

  PaisDisponible? get paisActual => FeriadosData.paisPorCodigo(_paisCodigo);

  Future<void>? _ultimaEscritura;

  /// Devuelve los feriados del país actual para un año dado.
  List<Feriado> feriadosDeAnio(int anio) {
    if (!_mostrarFeriados) return [];
    return FeriadosData.feriadosDePais(anio, _paisCodigo);
  }

  /// Devuelve los feriados que ocurren en una fecha específica.
  List<Feriado> feriadosDeFecha(DateTime fecha) {
    if (!_mostrarFeriados) return [];
    return feriadosDeAnio(fecha.year).where((f) => f.ocurreEn(fecha)).toList();
  }

  /// Devuelve true si la fecha es un feriado.
  bool esFeriado(DateTime fecha) {
    return feriadosDeFecha(fecha).isNotEmpty;
  }

  void cambiarPais(String codigo) {
    if (_paisCodigo == codigo) return;
    _paisCodigo = codigo;
    notifyListeners();
    _guardar();
  }

  void toggleMostrarFeriados(bool valor) {
    _mostrarFeriados = valor;
    notifyListeners();
    _guardar();
  }

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final codigo = prefs.getString('feriados_pais');
    if (codigo != null) {
      _paisCodigo = codigo;
    }
    final mostrar = prefs.getBool('feriados_mostrar');
    if (mostrar != null) {
      _mostrarFeriados = mostrar;
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
    await prefs.setString('feriados_pais', _paisCodigo);
    await prefs.setBool('feriados_mostrar', _mostrarFeriados);
  }

  Future<void> reset() async {
    _paisCodigo = 'VE';
    _mostrarFeriados = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('feriados_pais');
    await prefs.remove('feriados_mostrar');
  }
}
