import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Handler de background. Se ejecuta en un isolate separado cuando el usuario
/// toca un botón de acción en una notificación con la app cerrada.
@pragma('vm:entry-point')
void notificationBackgroundHandler(NotificationResponse response) {
  debugPrint(
    '🔔 [BG] Handler ejecutado. '
    'Acción: ${response.actionId}, '
    'Payload: ${response.payload}, '
    'ID: ${response.id}',
  );
  _manejarEnBackground(response);
}

Future<void> _manejarEnBackground(NotificationResponse response) async {
  DartPluginRegistrant.ensureInitialized();
  tz.initializeTimeZones();

  final accion = response.actionId ?? '';
  final payload = response.payload ?? '';
  final notifId = response.id;

  final plugin = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: androidSettings);
  await plugin.initialize(settings);

  // Cancelar la notificación actual inmediatamente
  debugPrint('🔔 [BG] Cancelando notificación ID: $notifId');
  if (notifId != null) {
    await plugin.cancel(notifId);
  }

  if (payload.isEmpty) return;

  final partes = payload.split(':');
  if (partes.length < 2) return;
  final tipo = partes[0];
  final entidadId = partes.sublist(1).join(':');

  if (tipo != 'medicacion') return;

  // Cancelar todos los reintentos pendientes del medicamento
  debugPrint('🔔 [BG] Cancelando reintentos de medicamento: $entidadId');
  await _cancelarReintentosDelMedicamento(plugin, entidadId);

  if (accion == 'tomado') {
    debugPrint('🔔 [BG] Marcando medicamento como tomado: $entidadId');
    await _marcarMedicamentoTomadoEnBackground(entidadId);
  } else if (accion == 'posponer') {
    debugPrint('🔔 [BG] Reprogramando snooze para: $entidadId');
    await _reprogramarSnoozeEnBackground(plugin, entidadId);
  } else if (accion == 'ignorar') {
    debugPrint('🔔 [BG] Acción ignorar para: $entidadId');
  }
}

/// Cancela todas las notificaciones pendientes asociadas al medicamento.
/// Los IDs se calculan con la misma lógica que en `MedicacionProvider`.
Future<void> _cancelarReintentosDelMedicamento(
  FlutterLocalNotificationsPlugin plugin,
  String medicamentoId,
) async {
  for (int i = 0; i < 7; i++) {
    for (int j = 0; j <= 5; j++) {
      final id = (medicamentoId.hashCode + i * 10 + j) & 0x7fffffff;
      await plugin.cancel(id);
    }
  }
}

Future<void> _marcarMedicamentoTomadoEnBackground(
  String medicamentoId,
) async {
  final prefs = await SharedPreferences.getInstance();

  final data = prefs.getString('registros_medicacion');
  final List<dynamic> registros = data != null ? json.decode(data) as List : [];

  final hoy = DateTime.now();
  final idUnico = 'bg_${hoy.millisecondsSinceEpoch}';

  bool encontrado = false;
  for (int i = 0; i < registros.length; i++) {
    final r = registros[i] as Map<String, dynamic>;
    final fecha = DateTime.parse(r['fechaHora']);
    if (r['medicamentoId'] == medicamentoId &&
        fecha.year == hoy.year &&
        fecha.month == hoy.month &&
        fecha.day == hoy.day) {
      r['tomado'] = true;
      registros[i] = r;
      encontrado = true;
      break;
    }
  }

  if (!encontrado) {
    registros.add({
      'id': idUnico,
      'medicamentoId': medicamentoId,
      'fechaHora': hoy.toIso8601String(),
      'tomado': true,
    });
  }

  await prefs.setString('registros_medicacion', json.encode(registros));
  debugPrint('🔔 [BG] Medicamento marcado como tomado en SharedPreferences');
}

Future<void> _reprogramarSnoozeEnBackground(
  FlutterLocalNotificationsPlugin plugin,
  String medicamentoId,
) async {
  final prefs = await SharedPreferences.getInstance();

  int snoozeMinutos = 5;
  final prefsData = prefs.getString('notificaciones_prefs');
  if (prefsData != null) {
    try {
      final Map<String, dynamic> map = json.decode(prefsData);
      final medPref = map['medicacion'] as Map<String, dynamic>?;
      if (medPref != null) {
        snoozeMinutos = medPref['snoozeMinutos'] ?? 5;
      }
    } catch (_) {}
  }
  debugPrint('🔔 [BG] Snooze configurado: $snoozeMinutos minutos');

  final medsData = prefs.getString('medicamentos');
  if (medsData == null) {
    debugPrint('🔔 [BG] No se encontraron medicamentos en prefs');
    return;
  }
  final List<dynamic> medicamentos = json.decode(medsData) as List;

  Map<String, dynamic>? med;
  for (final m in medicamentos) {
    if ((m as Map<String, dynamic>)['id'] == medicamentoId) {
      med = m;
      break;
    }
  }
  if (med == null) {
    debugPrint('🔔 [BG] Medicamento no encontrado: $medicamentoId');
    return;
  }

  final nombre = med['nombre'] as String;
  final dosis = med['dosis'] as String;

  final nuevaFecha =
      tz.TZDateTime.now(tz.local).add(Duration(minutes: snoozeMinutos));
  final notifId = DateTime.now().millisecondsSinceEpoch & 0x7fffffff;

  debugPrint('🔔 [BG] Reprogramando para $nuevaFecha (ID: $notifId)');

  await plugin.zonedSchedule(
    notifId,
    nombre,
    'Hora de tomar tu medicamento: $dosis',
    nuevaFecha,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'horario_app_canal_medicacion_alarm',
        'Medicación',
        channelDescription: 'Recordatorios de medicamentos',
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        actions: [
          AndroidNotificationAction(
            'tomado',
            'Tomado',
            showsUserInterface: false,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            'posponer',
            'Posponer',
            showsUserInterface: false,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            'ignorar',
            'Ignorar',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      ),
    ),
    payload: 'medicacion:$medicamentoId',
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );

  debugPrint('🔔 [BG] Snooze reprogramado correctamente');
}
