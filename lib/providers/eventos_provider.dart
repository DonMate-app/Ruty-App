import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/evento.dart';
import '../services/notification_service.dart';

class EventosProvider extends ChangeNotifier {
  List<Evento> _eventos = [];
  List<Evento> get eventos => _eventos;

  final NotificationService _notificationService;

  EventosProvider({required NotificationService notificationService})
      : _notificationService = notificationService;

  Future<void>? _ultimaEscritura;

  void agregarEvento(Evento e) {
    _eventos.add(e);
    _guardar();
    _scheduleNotification(e);
    notifyListeners();
  }

  void eliminarEvento(String id) {
    final idx = _eventos.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final evento = _eventos[idx];
    _eventos.removeAt(idx);
    _guardar();
    _cancelNotification(evento);
    notifyListeners();
  }

  void modificarEvento(Evento modificado) {
    final idx = _eventos.indexWhere((e) => e.id == modificado.id);
    if (idx != -1) {
      final anterior = _eventos[idx];
      _eventos[idx] = modificado;
      _guardar();
      _cancelNotification(anterior);
      _scheduleNotification(modificado);
      notifyListeners();
    }
  }

  void suspenderEvento(String id) {
    final e = _eventos.firstWhere((e) => e.id == id);
    e.suspendido = !e.suspendido;
    _guardar();
    if (e.suspendido) {
      _cancelNotification(e);
    } else {
      _scheduleNotification(e);
    }
    notifyListeners();
  }

  void duplicarEvento(Evento original) {
    final duracion = Duration(
      hours: original.horaFin.hour - original.horaInicio.hour,
      minutes: original.horaFin.minute - original.horaInicio.minute,
    );
    final nuevo = Evento.conDuracion(
      id: const Uuid().v4(),
      titulo: '${original.titulo} (copia)',
      fecha: original.fecha,
      horaInicio: original.horaInicio,
      duracion: duracion.inMinutes > 0 ? duracion : const Duration(hours: 1),
      color: original.color,
      tipo: original.tipo,
      recurrencia: original.recurrencia,
    );
    _eventos.add(nuevo);
    _guardar();
    _scheduleNotification(nuevo);
    notifyListeners();
  }

  List<Evento> eventosParaDia(DateTime dia) {
    final resultado = <Evento>[];
    for (final e in _eventos) {
      if (e.ocurreEnFecha(dia)) {
        resultado.add(e.copiaParaFecha(dia));
      }
    }
    resultado.sort((a, b) {
      final aMin = a.horaInicio.hour * 60 + a.horaInicio.minute;
      final bMin = b.horaInicio.hour * 60 + b.horaInicio.minute;
      return aMin.compareTo(bMin);
    });
    return resultado;
  }

  List<Evento> eventosDelDia(DateTime dia) => eventosParaDia(dia);

  List<Evento> eventosDeHora(DateTime dia, int hora) =>
      eventosParaDia(dia).where((e) => e.horaInicio.hour == hora).toList();

  void _scheduleNotification(Evento evento) {
    if (evento.suspendido) return;
    if (evento.recurrencia != Recurrencia.ninguna) return;

    final fechaHora = DateTime(
      evento.fecha.year,
      evento.fecha.month,
      evento.fecha.day,
      evento.horaInicio.hour,
      evento.horaInicio.minute,
    );
    if (fechaHora.isAfter(DateTime.now())) {
      final id = evento.id.hashCode & 0x7fffffff;
      _notificationService.scheduleNotification(
        id: id,
        categoria: NotifCategoria.eventos,
        title: evento.titulo,
        body:
            'Evento programado para las ${evento.horaInicio.hour}:${evento.horaInicio.minute.toString().padLeft(2, '0')}',
        scheduledDate: fechaHora,
      );
    }
  }

  void _cancelNotification(Evento evento) {
    final id = evento.id.hashCode & 0x7fffffff;
    _notificationService.cancelNotification(id);
  }

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('eventos');
    if (data != null) {
      final lista = json.decode(data) as List;
      _eventos = lista.map((e) => Evento.fromJson(e)).toList();
      for (final e in _eventos) {
        _scheduleNotification(e);
      }
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
      'eventos',
      json.encode(_eventos.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> reset() async {
    for (final e in _eventos) {
      _cancelNotification(e);
    }
    _eventos.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('eventos');
    notifyListeners();
  }
}
