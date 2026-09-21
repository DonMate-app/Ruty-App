import 'package:shared_preferences/shared_preferences.dart';

class TrialService {
  static const String _keyFirstLaunch = 'trial_first_launch';
  static const int _diasTrial = 2;

  /// Devuelve true si la prueba sigue activa, false si expiró.
  Future<bool> verificarTrial() async {
    final prefs = await SharedPreferences.getInstance();
    final firstLaunchMs = prefs.getInt(_keyFirstLaunch);

    if (firstLaunchMs == null) {
      await prefs.setInt(
        _keyFirstLaunch,
        DateTime.now().millisecondsSinceEpoch,
      );
      return true;
    }

    final firstLaunch = DateTime.fromMillisecondsSinceEpoch(firstLaunchMs);
    final ahora = DateTime.now();
    final diferencia = ahora.difference(firstLaunch).inDays;

    return diferencia < _diasTrial;
  }

  /// Devuelve la cantidad de días restantes (0 si ya expiró).
  Future<int> diasRestantes() async {
    final prefs = await SharedPreferences.getInstance();
    final firstLaunchMs = prefs.getInt(_keyFirstLaunch);
    if (firstLaunchMs == null) return _diasTrial;

    final firstLaunch = DateTime.fromMillisecondsSinceEpoch(firstLaunchMs);
    final ahora = DateTime.now();
    final diferencia = ahora.difference(firstLaunch).inDays;
    final restantes = _diasTrial - diferencia;
    return restantes > 0 ? restantes : 0;
  }

  /// Devuelve la fecha exacta en la que expira el trial.
  Future<DateTime> fechaExpiracion() async {
    final prefs = await SharedPreferences.getInstance();
    final firstLaunchMs = prefs.getInt(_keyFirstLaunch);
    final base = firstLaunchMs != null
        ? DateTime.fromMillisecondsSinceEpoch(firstLaunchMs)
        : DateTime.now();
    return base.add(Duration(days: _diasTrial));
  }

  /// Devuelve las horas restantes (0 si ya expiró).
  Future<int> horasRestantes() async {
    final prefs = await SharedPreferences.getInstance();
    final firstLaunchMs = prefs.getInt(_keyFirstLaunch);
    if (firstLaunchMs == null) return _diasTrial * 24;

    final firstLaunch = DateTime.fromMillisecondsSinceEpoch(firstLaunchMs);
    final ahora = DateTime.now();
    final expiracion = firstLaunch.add(Duration(days: _diasTrial));
    final horas = expiracion.difference(ahora).inHours;
    return horas > 0 ? horas : 0;
  }

  /// Devuelve una descripción amigable del tiempo restante.
  Future<String> descripcionRestante() async {
    final horas = await horasRestantes();
    if (horas <= 0) return 'Prueba finalizada';
    if (horas < 24) {
      return '$horas hora${horas == 1 ? '' : 's'} restante${horas == 1 ? '' : 's'}';
    }
    final dias = await diasRestantes();
    return '$dias día${dias == 1 ? '' : 's'} restante${dias == 1 ? '' : 's'}';
  }

  /// Reinicia el contador (útil para desarrollo o si vendes la licencia).
  Future<void> reiniciarTrial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFirstLaunch);
  }
}
