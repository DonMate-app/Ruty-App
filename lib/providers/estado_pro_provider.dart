import 'package:flutter/foundation.dart';

import '../services/beta_service.dart';
import '../services/licencia_service.dart';
import 'trial_provider.dart';

class EstadoProProvider extends ChangeNotifier {
  bool _licenciaActivada = false;
  bool _betaActivado = false;
  bool _cargando = true;

  TrialProvider? _trialProvider;

  bool get licenciaActivada => _licenciaActivada;
  bool get betaActivado => _betaActivado;
  bool get cargando => _cargando;

  void setTrialProvider(TrialProvider provider) {
    _trialProvider?.removeListener(_onTrialChange);
    _trialProvider = provider;
    _trialProvider!.addListener(_onTrialChange);
    notifyListeners();
  }

  void _onTrialChange() {
    notifyListeners();
  }

  @override
  void dispose() {
    _trialProvider?.removeListener(_onTrialChange);
    super.dispose();
  }

  Future<void> cargar() async {
    _cargando = true;
    notifyListeners();

    _licenciaActivada = await LicenciaService.estaActivada();
    _betaActivado = await BetaService.estaActivado();

    _cargando = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // ACCESO
  // ─────────────────────────────────────────────────────────

  bool get esProCompleto => _licenciaActivada || _betaActivado;

  bool get tieneAccesoProPorTrial =>
      !esProCompleto && (_trialProvider?.proActivo ?? false);

  bool get tieneAccesoEstadisticas {
    if (esProCompleto) return true;
    if (tieneAccesoProPorTrial) return true;
    if (_trialProvider?.statsActivo ?? false) return true;
    return false;
  }

  bool get tieneAccesoPro => esProCompleto || tieneAccesoProPorTrial;

  bool get puedeIniciarTrial {
    if (esProCompleto) return false;
    return _trialProvider?.proDisponible ?? false;
  }

  bool get trialProviderUsado => _trialProvider?.proUsado ?? false;

  String get etiquetaEstado {
    if (_betaActivado) return 'Beta';
    if (_licenciaActivada) return 'Pro activado';
    if (tieneAccesoProPorTrial) {
      final dias = _trialProvider?.diasRestantesPro ?? 0;
      return 'Trial Pro ($dias días)';
    }
    if (_trialProvider?.statsActivo ?? false) {
      final dias = _trialProvider?.diasRestantesStats ?? 0;
      return 'Estadísticas Pro ($dias días)';
    }
    if (_trialProvider?.proUsado ?? false) {
      return 'Trial expirado';
    }
    return 'Versión gratis';
  }

  // ─────────────────────────────────────────────────────────
  // ACCIONES
  // ─────────────────────────────────────────────────────────

  Future<bool> activarLicencia(String codigo) async {
    final resultado = await LicenciaService.activar(codigo);
    if (resultado.exitoso) {
      await cargar();
      return true;
    }
    return false;
  }

  Future<bool> activarBeta(String codigo) async {
    final ok = await BetaService.activar(codigo);
    if (ok) {
      await cargar();
      return true;
    }
    return false;
  }

  Future<bool> iniciarTrial() async {
    if (_trialProvider == null) return false;
    final ok = await _trialProvider!.iniciarTrials();
    notifyListeners();
    return ok;
  }

  Future<void> reset() async {
    await LicenciaService.resetTotal();
    await BetaService.reset();
    await _trialProvider?.reset();
    await cargar();
  }
}
