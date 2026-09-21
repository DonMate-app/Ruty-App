import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResumenSemanalProvider extends ChangeNotifier {
  /// Clave de la semana (formato YYYY-Www) del último resumen mostrado.
  String? _ultimaSemanaMostrada;

  String? get ultimaSemanaMostrada => _ultimaSemanaMostrada;

  Future<void>? _ultimaEscritura;

  /// Devuelve una clave única para la semana a la que pertenece [fecha].
  String _claveSemana(DateTime fecha) {
    final lunes = fecha.subtract(Duration(days: fecha.weekday - 1));
    final year = lunes.year;
    final month = lunes.month.toString().padLeft(2, '0');
    final day = lunes.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Comprueba si hay que mostrar el resumen esta semana.
  /// Devuelve true si nunca se ha mostrado o si la última vez fue
  /// en una semana diferente.
  bool debeMostrarResumen() {
    final claveActual = _claveSemana(DateTime.now());
    return _ultimaSemanaMostrada != claveActual;
  }

  /// Marca la semana actual como "ya mostrada".
  void marcarSemanaMostrada() {
    final claveActual = _claveSemana(DateTime.now());
    _ultimaSemanaMostrada = claveActual;
    _guardar();
    notifyListeners();
  }

  /// Permite volver a mostrar el resumen la próxima vez.
  void reiniciar() {
    _ultimaSemanaMostrada = null;
    _guardar();
    notifyListeners();
  }

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    _ultimaSemanaMostrada = prefs.getString('ultimaSemanaResumen');
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
    if (_ultimaSemanaMostrada == null) {
      await prefs.remove('ultimaSemanaResumen');
    } else {
      await prefs.setString(
        'ultimaSemanaResumen',
        _ultimaSemanaMostrada!,
      );
    }
  }

  Future<void> reset() async {
    _ultimaSemanaMostrada = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ultimaSemanaResumen');
  }
}
