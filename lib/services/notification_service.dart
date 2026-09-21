import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/notificacion_pref.dart';
import '../providers/notificaciones_prefs_provider.dart';

class NotifCategoria {
  static const String eventos = 'eventos';
  static const String tareas = 'tareas';
  static const String rutinas = 'rutinas';
  static const String medicacion = 'medicacion';
  static const String comunidad = 'comunidad';
}

typedef AccionNotificacionCallback = void Function(
  String accion,
  String payload,
);

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  NotificacionesPrefsProvider? _prefsProvider;

  final Map<String, List<int>> _idsPorPayload = {};

  AccionNotificacionCallback? onAccion;

  int _limitePorHora = 6;
  int get limitePorHora => _limitePorHora;
  bool _limitadorActivo = true;
  bool get limitadorActivo => _limitadorActivo;

  static const Set<String> _categoriasPrioritarias = {
    NotifCategoria.medicacion,
    NotifCategoria.rutinas,
  };

  void setPrefsProvider(NotificacionesPrefsProvider provider) {
    _prefsProvider = provider;
  }

  void setAccionCallback(AccionNotificacionCallback callback) {
    onAccion = callback;
  }

  void configurarLimitador({required bool activo, required int limite}) {
    _limitadorActivo = activo;
    _limitePorHora = limite;
  }

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _manejarAccion,
    );

    await _cargarPayloadsProgramados();
    _initialized = true;
  }

  void _manejarAccion(NotificationResponse response) {
    final accion = response.actionId ?? '';
    final payload = response.payload ?? '';

    // Si no hay acción pero hay payload, el usuario tocó la notificación
    if (accion.isEmpty && payload.isNotEmpty) {
      onAccion?.call('tocado', payload);
      return;
    }

    if (accion.isEmpty && payload.isEmpty) return;

    onAccion?.call(accion, payload);

    if (accion == 'ignorar') return;
  }

  Future<void> _cargarPayloadsProgramados() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('notif_ids_programados');
    if (data != null) {
      try {
        final Map<String, dynamic> jsonData =
            Map<String, dynamic>.from(json.decode(data));
        jsonData.forEach((key, value) {
          _idsPorPayload[key] = List<int>.from(value);
        });
      } catch (_) {}
    }
  }

  Future<void> _guardarPayloads() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'notif_ids_programados',
      json.encode(_idsPorPayload),
    );
  }

  bool _puedeNotificar(String categoria) {
    if (!_limitadorActivo) return true;
    if (_categoriasPrioritarias.contains(categoria)) return true;
    return _idsPorPayload.values.expand((ids) => ids).length < _limitePorHora;
  }

  String _canalId(String categoria, NotificacionPref? pref) {
    final sonido = pref?.sonido ?? 'default';
    final alarma = pref?.modoAlarma ?? false;
    final sufijoAlarma = alarma ? '_alarma' : '';
    if (sonido == 'custom') {
      final path = pref?.customSoundPath ?? '';
      final hash = path.hashCode.abs() % 100000;
      return 'horario_app_canal_${categoria}_custom_${hash}$sufijoAlarma';
    }
    return 'horario_app_canal_${categoria}_$sonido$sufijoAlarma';
  }

  AndroidNotificationSound? _resolverSonido(NotificacionPref? pref) {
    final sonido = pref?.sonido ?? 'default';
    if (sonido == 'default') return null;

    if (sonido == 'custom') {
      final path = pref?.customSoundPath;
      if (path == null || path.isEmpty) return null;
      if (!File(path).existsSync()) return null;
      return UriAndroidNotificationSound(Uri.file(path).toString());
    }

    return RawResourceAndroidNotificationSound(sonido);
  }

  Future<void> scheduleNotification({
    required int id,
    required String categoria,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    List<AndroidNotificationAction>? acciones,
  }) async {
    if (!_initialized) await init();

    final prefs = _prefsProvider?.getPref(categoria);
    if (prefs != null && !prefs.habilitada) return;
    if (!_puedeNotificar(categoria)) return;

    final anticipacion = prefs?.anticipacionMinutos ?? 0;
    final fechaAjustada =
        scheduledDate.subtract(Duration(minutes: anticipacion));

    if (fechaAjustada.isBefore(DateTime.now())) return;

    final tzDateTime = tz.TZDateTime.from(fechaAjustada, tz.local);

    final sound = _resolverSonido(prefs);
    final vibracion = prefs?.vibracion ?? true;
    final despertarPantalla = prefs?.despertarPantalla ?? false;
    final modoAlarma = prefs?.modoAlarma ?? false;
    final canalId = _canalId(categoria, prefs);

    // Si modo alarma: fullScreenIntent obligatorio y categoría alarm
    final androidDetails = AndroidNotificationDetails(
      canalId,
      _nombreCanal(categoria, prefs),
      channelDescription: _descripcionCanal(categoria),
      importance:
          modoAlarma ? Importance.max : _importanciaParaCategoria(categoria),
      priority: modoAlarma ? Priority.max : _prioridadParaCategoria(categoria),
      sound: sound,
      playSound: true,
      enableVibration: vibracion,
      fullScreenIntent: modoAlarma || despertarPantalla,
      category: modoAlarma
          ? AndroidNotificationCategory.alarm
          : _androidCategory(categoria),
      styleInformation: BigTextStyleInformation(body),
      actions: acciones,
      ongoing: modoAlarma,
      autoCancel: !modoAlarma,
    );

    final details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    if (payload != null && payload.isNotEmpty) {
      _idsPorPayload.putIfAbsent(payload, () => []).add(id);
      await _guardarPayloads();
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String categoria,
    required String title,
    required String body,
    required TimeOfDay hora,
    String? payload,
    List<AndroidNotificationAction>? acciones,
  }) async {
    if (!_initialized) await init();

    final prefs = _prefsProvider?.getPref(categoria);
    if (prefs != null && !prefs.habilitada) return;
    if (!_puedeNotificar(categoria)) return;

    final ahora = DateTime.now();
    var proxima = DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
      hora.hour,
      hora.minute,
    );
    if (proxima.isBefore(ahora)) {
      proxima = proxima.add(const Duration(days: 1));
    }

    final anticipacion = prefs?.anticipacionMinutos ?? 0;
    final fechaAjustada = proxima.subtract(Duration(minutes: anticipacion));

    final tzDateTime = tz.TZDateTime.from(fechaAjustada, tz.local);

    final sound = _resolverSonido(prefs);
    final vibracion = prefs?.vibracion ?? true;
    final despertarPantalla = prefs?.despertarPantalla ?? false;
    final modoAlarma = prefs?.modoAlarma ?? false;
    final canalId = _canalId(categoria, prefs);

    final androidDetails = AndroidNotificationDetails(
      canalId,
      _nombreCanal(categoria, prefs),
      channelDescription: _descripcionCanal(categoria),
      importance:
          modoAlarma ? Importance.max : _importanciaParaCategoria(categoria),
      priority: modoAlarma ? Priority.max : _prioridadParaCategoria(categoria),
      sound: sound,
      playSound: true,
      enableVibration: vibracion,
      fullScreenIntent: modoAlarma || despertarPantalla,
      category: modoAlarma
          ? AndroidNotificationCategory.alarm
          : _androidCategory(categoria),
      styleInformation: BigTextStyleInformation(body),
      actions: acciones,
      ongoing: modoAlarma,
      autoCancel: !modoAlarma,
    );

    final details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    if (payload != null && payload.isNotEmpty) {
      _idsPorPayload.putIfAbsent(payload, () => []).add(id);
      await _guardarPayloads();
    }
  }

  Future<void> scheduleRepeatingNotification({
    required int baseId,
    required String categoria,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required int intervaloMinutos,
    int repeticiones = 3,
    String? payload,
    List<AndroidNotificationAction>? acciones,
  }) async {
    if (intervaloMinutos <= 0) {
      await scheduleNotification(
        id: baseId,
        categoria: categoria,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        payload: payload,
        acciones: acciones,
      );
      return;
    }

    for (int i = 0; i <= repeticiones; i++) {
      final fecha = scheduledDate.add(
        Duration(minutes: intervaloMinutos * i),
      );
      await scheduleNotification(
        id: baseId + i,
        categoria: categoria,
        title: i == 0 ? title : '$title (recordatorio ${i + 1})',
        body: body,
        scheduledDate: fecha,
        payload: payload,
        acciones: acciones,
      );
    }
  }

  Future<void> cancelarPorPayload(String payload) async {
    final ids = _idsPorPayload.remove(payload);
    if (ids != null) {
      for (final id in ids) {
        await _plugin.cancel(id);
      }
      await _guardarPayloads();
    }
  }

  Future<void> snooze({
    required String categoria,
    required String title,
    required String body,
    required int minutos,
    required String payload,
    List<AndroidNotificationAction>? acciones,
  }) async {
    final nuevaFecha = DateTime.now().add(Duration(minutes: minutos));
    final id = DateTime.now().millisecondsSinceEpoch & 0x7fffffff;

    await scheduleNotification(
      id: id,
      categoria: categoria,
      title: title,
      body: body,
      scheduledDate: nuevaFecha,
      payload: payload,
      acciones: acciones,
    );
  }

  Future<void> cancelNotification(int id) async {
    if (!_initialized) await init();
    await _plugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    if (!_initialized) await init();
    _idsPorPayload.clear();
    await _guardarPayloads();
    await _plugin.cancelAll();
  }

  int get notificacionesUltimaHora =>
      _idsPorPayload.values.expand((ids) => ids).length;

  String _nombreCanal(String categoria, NotificacionPref? pref) {
    final sonido = pref?.sonido ?? 'default';
    final base = _nombreCanalBase(categoria);
    if (sonido == 'default') return base;
    if (sonido == 'custom') return '$base (personalizado)';
    return '$base ($sonido)';
  }

  String _nombreCanalBase(String categoria) {
    switch (categoria) {
      case NotifCategoria.eventos:
        return 'Eventos';
      case NotifCategoria.tareas:
        return 'Tareas';
      case NotifCategoria.rutinas:
        return 'Rutinas';
      case NotifCategoria.medicacion:
        return 'Medicación';
      case NotifCategoria.comunidad:
        return 'Comunidad';
      default:
        return 'General';
    }
  }

  String _descripcionCanal(String categoria) {
    switch (categoria) {
      case NotifCategoria.eventos:
        return 'Recordatorios de eventos del calendario';
      case NotifCategoria.tareas:
        return 'Recordatorios de tareas pendientes';
      case NotifCategoria.rutinas:
        return 'Recordatorios de rutinas diarias';
      case NotifCategoria.medicacion:
        return 'Recordatorios de medicamentos';
      case NotifCategoria.comunidad:
        return 'Novedades de la comunidad';
      default:
        return 'Recordatorios generales';
    }
  }

  Importance _importanciaParaCategoria(String categoria) {
    switch (categoria) {
      case NotifCategoria.medicacion:
        return Importance.max;
      case NotifCategoria.rutinas:
      case NotifCategoria.eventos:
        return Importance.high;
      case NotifCategoria.tareas:
        return Importance.defaultImportance;
      case NotifCategoria.comunidad:
        return Importance.low;
      default:
        return Importance.defaultImportance;
    }
  }

  Priority _prioridadParaCategoria(String categoria) {
    switch (categoria) {
      case NotifCategoria.medicacion:
        return Priority.max;
      case NotifCategoria.rutinas:
      case NotifCategoria.eventos:
        return Priority.high;
      case NotifCategoria.tareas:
        return Priority.defaultPriority;
      case NotifCategoria.comunidad:
        return Priority.low;
      default:
        return Priority.defaultPriority;
    }
  }

  AndroidNotificationCategory _androidCategory(String categoria) {
    switch (categoria) {
      case NotifCategoria.eventos:
        return AndroidNotificationCategory.event;
      case NotifCategoria.medicacion:
        return AndroidNotificationCategory.alarm;
      case NotifCategoria.rutinas:
      case NotifCategoria.tareas:
        return AndroidNotificationCategory.reminder;
      case NotifCategoria.comunidad:
        return AndroidNotificationCategory.social;
      default:
        return AndroidNotificationCategory.reminder;
    }
  }
}
