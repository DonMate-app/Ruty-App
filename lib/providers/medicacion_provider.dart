import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/medicamento.dart';
import '../models/registro_medicacion.dart';
import '../providers/notificaciones_prefs_provider.dart';
import '../services/notification_service.dart';

class MedicacionProvider extends ChangeNotifier {
  List<Medicamento> _medicamentos = [];
  List<RegistroMedicacion> _registros = [];

  List<Medicamento> get medicamentos => _medicamentos;
  List<RegistroMedicacion> get registros => _registros;

  final NotificationService _notificationService;
  NotificacionesPrefsProvider? _prefsProvider;

  MedicacionProvider({required NotificationService notificationService})
      : _notificationService = notificationService;

  void setPrefsProvider(NotificacionesPrefsProvider provider) {
    _prefsProvider = provider;
  }

  Future<void>? _ultimaEscritura;

  void agregarMedicamento(Medicamento m) {
    _medicamentos.add(m);
    _guardar();
    _scheduleNotification(m);
    notifyListeners();
  }

  void modificarMedicamento(Medicamento modificado) {
    final idx = _medicamentos.indexWhere((m) => m.id == modificado.id);
    if (idx != -1) {
      final anterior = _medicamentos[idx];
      _medicamentos[idx] = modificado;
      _guardar();
      _cancelNotification(anterior);
      _scheduleNotification(modificado);
      notifyListeners();
    }
  }

  void eliminarMedicamento(String id) {
    final idx = _medicamentos.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    final med = _medicamentos[idx];
    _medicamentos.removeAt(idx);
    _registros.removeWhere((r) => r.medicamentoId == id);
    _guardar();
    _cancelNotification(med);
    notifyListeners();
  }

  void agregarRegistro(RegistroMedicacion r) {
    _registros.add(r);
    _guardar();
    notifyListeners();
  }

  void marcarTomado(String registroId, bool tomado) {
    final idx = _registros.indexWhere((r) => r.id == registroId);
    if (idx != -1) {
      _registros[idx].tomado = tomado;
      _guardar();

      if (tomado) {
        final medId = _registros[idx].medicamentoId;
        _notificationService.cancelarPorPayload('medicacion:$medId');
      }
      notifyListeners();
    }
  }

  List<RegistroMedicacion> registrosDeDia(DateTime dia) {
    return _registros
        .where((r) =>
            r.fechaHora.year == dia.year &&
            r.fechaHora.month == dia.month &&
            r.fechaHora.day == dia.day)
        .toList();
  }

  void _scheduleNotification(Medicamento med) {
    final prefs = _prefsProvider?.getPref(NotifCategoria.medicacion);
    final reintento = prefs?.reintentoMinutos ?? 0;
    final maxReintentos = prefs?.maxReintentos ?? 3;

    final now = DateTime.now();
    final hoy = DateTime(now.year, now.month, now.day);

    final payload = 'medicacion:${med.id}';

    for (int i = 0; i < 7; i++) {
      final fechaHora = hoy.add(Duration(days: i)).add(
            Duration(hours: med.hora.hour, minutes: med.hora.minute),
          );
      if (fechaHora.isAfter(now)) {
        final id = (med.id.hashCode + i * 10) & 0x7fffffff;

        final acciones = <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'tomado',
            'Tomado',
            showsUserInterface: false,
            cancelNotification: true,
          ),
          const AndroidNotificationAction(
            'posponer',
            'Posponer',
            showsUserInterface: false,
            cancelNotification: true,
          ),
          const AndroidNotificationAction(
            'ignorar',
            'Ignorar',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ];

        _notificationService.scheduleRepeatingNotification(
          baseId: id,
          categoria: NotifCategoria.medicacion,
          title: med.nombre,
          body: 'Hora de tomar tu medicamento: ${med.dosis}',
          scheduledDate: fechaHora,
          intervaloMinutos: reintento,
          repeticiones: maxReintentos,
          payload: payload,
          acciones: acciones,
        );
      }
    }
  }

  void _cancelNotification(Medicamento med) {
    _notificationService.cancelarPorPayload('medicacion:${med.id}');
  }

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final mData = prefs.getString('medicamentos');
    final rData = prefs.getString('registros_medicacion');
    if (mData != null) {
      _medicamentos = (json.decode(mData) as List)
          .map((m) => Medicamento.fromJson(m))
          .toList();
      for (final m in _medicamentos) {
        _scheduleNotification(m);
      }
    }
    if (rData != null) {
      _registros = (json.decode(rData) as List)
          .map((r) => RegistroMedicacion.fromJson(r))
          .toList();
    }
    notifyListeners();
  }

  /// Recarga los registros desde SharedPreferences.
  /// Útil cuando el handler de background modificó los datos.
  Future<void> recargarRegistros() async {
    final prefs = await SharedPreferences.getInstance();
    final rData = prefs.getString('registros_medicacion');
    if (rData != null) {
      _registros = (json.decode(rData) as List)
          .map((r) => RegistroMedicacion.fromJson(r))
          .toList();
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
      'medicamentos',
      json.encode(_medicamentos.map((m) => m.toJson()).toList()),
    );
    await prefs.setString(
      'registros_medicacion',
      json.encode(_registros.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> reset() async {
    for (final m in _medicamentos) {
      _cancelNotification(m);
    }
    _medicamentos.clear();
    _registros.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('medicamentos');
    await prefs.remove('registros_medicacion');
    notifyListeners();
  }
}
