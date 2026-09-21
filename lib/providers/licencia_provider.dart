import 'package:flutter/foundation.dart';

import '../services/licencia_service.dart';

class LicenciaProvider extends ChangeNotifier {
  bool _activada = false;
  String? _codigoUsado;
  DateTime? _fechaActivacion;
  bool _cargando = true;

  bool get activada => _activada;
  String? get codigoUsado => _codigoUsado;
  DateTime? get fechaActivacion => _fechaActivacion;
  bool get cargando => _cargando;

  Future<void> cargar() async {
    _cargando = true;
    notifyListeners();

    _activada = await LicenciaService.estaActivada();
    _codigoUsado = await LicenciaService.codigoUsado();
    _fechaActivacion = await LicenciaService.fechaActivacion();

    _cargando = false;
    notifyListeners();
  }

  Future<bool> activar(String codigo) async {
    final resultado = await LicenciaService.activar(codigo);
    if (resultado.exitoso) {
      await cargar();
      return true;
    }
    return false;
  }

  Future<void> desactivar() async {
    await LicenciaService.desactivar();
    await cargar();
  }

  Future<void> reset() async {
    await LicenciaService.resetTotal();
    await cargar();
  }
}
