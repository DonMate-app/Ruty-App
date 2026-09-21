import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/aviso.dart';

class AvisosProvider extends ChangeNotifier {
  final List<Aviso> _avisosActivos = [];
  List<Aviso> get avisosActivos => List.unmodifiable(_avisosActivos);

  /// Avisos descartados (para el historial).
  final List<Aviso> _historial = [];
  List<Aviso> get historial => List.unmodifiable(_historial);

  void mostrar(String mensaje, {TipoAviso tipo = TipoAviso.info}) {
    final aviso = Aviso(
      id: const Uuid().v4(),
      mensaje: mensaje,
      tipo: tipo,
    );
    _avisosActivos.add(aviso);
    notifyListeners();

    // Auto-descartar después de la duración
    Future.delayed(aviso.duracion, () {
      descartar(aviso.id);
    });
  }

  void descartar(String id) {
    final idx = _avisosActivos.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final aviso = _avisosActivos.removeAt(idx);
      _historial.insert(0, aviso);
      if (_historial.length > 20) {
        _historial.removeLast();
      }
      notifyListeners();
    }
  }

  void limpiarTodo() {
    _avisosActivos.clear();
    _historial.clear();
    notifyListeners();
  }
}
