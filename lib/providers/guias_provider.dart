import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuiasProvider extends ChangeNotifier {
  Set<String> _vistas = {};

  bool haVisto(String id) => _vistas.contains(id);

  Future<void>? _ultimaEscritura;

  void marcarVista(String id) {
    if (_vistas.contains(id)) return;
    _vistas.add(id);
    _guardar();
    notifyListeners();
  }

  void reiniciarTodas() {
    _vistas.clear();
    _guardar();
    notifyListeners();
  }

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('guias_vistas');
    if (data != null) {
      _vistas = data.toSet();
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
    await prefs.setStringList('guias_vistas', _vistas.toList());
  }

  Future<void> reset() async {
    _vistas.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('guias_vistas');
  }
}
