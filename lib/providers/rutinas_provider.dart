import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/grupo_rutinas.dart';
import '../models/rutina.dart';
import '../models/evento.dart';
import '../services/notification_service.dart';
import 'eventos_provider.dart';

class RutinasProvider extends ChangeNotifier {
  static const String idGrupoTodos = '__todos__';

  List<GrupoRutinas> _gruposReales = [
    GrupoRutinas(id: const Uuid().v4(), nombre: 'Salud', color: Colors.green),
    GrupoRutinas(id: const Uuid().v4(), nombre: 'Todos', color: Colors.blue),
    GrupoRutinas(
        id: const Uuid().v4(), nombre: 'Trabajo', color: Colors.orange),
  ];
  List<Rutina> _rutinas = [];

  int _contadorRutinasAplicadas = 0;
  int get contadorRutinasAplicadas => _contadorRutinasAplicadas;

  final NotificationService _notificationService;

  RutinasProvider({required NotificationService notificationService})
      : _notificationService = notificationService;

  List<GrupoRutinas> get grupos => [
        GrupoRutinas(
          id: idGrupoTodos,
          nombre: '★ Todos',
          color: Colors.purple,
        ),
        ..._gruposReales,
      ];

  List<GrupoRutinas> get gruposReales => List.from(_gruposReales);

  List<Rutina> get rutinas => _rutinas;

  List<Rutina> rutinasDeGrupo(String grupoId) {
    if (grupoId == idGrupoTodos) {
      return List.from(_rutinas);
    }
    return _rutinas.where((r) => r.grupoId == grupoId).toList();
  }

  Future<void>? _ultimaEscritura;

  void agregarGrupo(String nombre, Color color) {
    if (_gruposReales.length >= 6) return;
    _gruposReales.add(GrupoRutinas(
      id: const Uuid().v4(),
      nombre: nombre,
      color: color,
    ));
    _guardar();
    notifyListeners();
  }

  void eliminarGrupo(String id) {
    if (id == idGrupoTodos) return;
    for (final r in _rutinas.where((r) => r.grupoId == id)) {
      _cancelarNotificacionRutina(r);
    }
    _gruposReales.removeWhere((g) => g.id == id);
    _rutinas.removeWhere((r) => r.grupoId == id);
    _guardar();
    notifyListeners();
  }

  void modificarGrupo(String id, String nuevoNombre) {
    if (id == idGrupoTodos) return;
    final g = _gruposReales.firstWhere((g) => g.id == id);
    g.nombre = nuevoNombre;
    _guardar();
    notifyListeners();
  }

  void agregarRutina(
      String grupoId, String titulo, TimeOfDay hora, Color color) {
    if (grupoId == idGrupoTodos) {
      if (_gruposReales.isEmpty) return;
      grupoId = _gruposReales.first.id;
    }
    final rutina = Rutina(
      id: const Uuid().v4(),
      titulo: titulo,
      hora: hora,
      color: color,
      grupoId: grupoId,
    );
    _rutinas.add(rutina);
    _programarNotificacionRutina(rutina);
    _guardar();
    notifyListeners();
  }

  void eliminarRutina(String id) {
    final aEliminar = _rutinas.firstWhere(
      (r) => r.id == id,
      orElse: () => Rutina(
        id: '',
        titulo: '',
        hora: const TimeOfDay(hour: 0, minute: 0),
        color: Colors.transparent,
        grupoId: '',
      ),
    );
    if (aEliminar.id.isEmpty) return;

    for (final r in _rutinas.where((r) =>
        r.titulo == aEliminar.titulo &&
        r.hora.hour == aEliminar.hora.hour &&
        r.hora.minute == aEliminar.hora.minute &&
        r.grupoId == aEliminar.grupoId &&
        r.color.toARGB32() == aEliminar.color.toARGB32())) {
      _cancelarNotificacionRutina(r);
    }

    _rutinas.removeWhere((r) =>
        r.titulo == aEliminar.titulo &&
        r.hora.hour == aEliminar.hora.hour &&
        r.hora.minute == aEliminar.hora.minute &&
        r.grupoId == aEliminar.grupoId &&
        r.color.toARGB32() == aEliminar.color.toARGB32());

    _guardar();
    notifyListeners();
  }

  void eliminarDuplicadosDeGrupo(String grupoId) {
    final delGrupo = rutinasDeGrupo(grupoId);
    final vistos = <String>{};
    final aEliminar = <String>[];

    for (final r in delGrupo) {
      final clave =
          '${r.titulo}|${r.hora.hour}:${r.hora.minute}|${r.color.toARGB32()}';
      if (vistos.contains(clave)) {
        aEliminar.add(r.id);
        _cancelarNotificacionRutina(r);
      } else {
        vistos.add(clave);
      }
    }

    if (aEliminar.isEmpty) return;

    _rutinas.removeWhere((r) => aEliminar.contains(r.id));
    _guardar();
    notifyListeners();
  }

  void aplicarRutinasDeGrupo(
      String grupoId, DateTime fecha, EventosProvider eventosProv) {
    final delGrupo = rutinasDeGrupo(grupoId);
    for (final r in delGrupo) {
      final nuevoEvento = Evento.conDuracion(
        id: const Uuid().v4(),
        titulo: r.titulo,
        fecha: fecha,
        horaInicio: r.hora,
        duracion: const Duration(hours: 1),
        color: r.color,
      );
      eventosProv.agregarEvento(nuevoEvento);
    }
    _contadorRutinasAplicadas += delGrupo.length;
    _guardar();
    notifyListeners();
  }

  void aplicarRutinasDeGrupoRecurrente(
      String grupoId, DateTime fechaInicio, EventosProvider eventosProv) {
    final delGrupo = rutinasDeGrupo(grupoId);
    for (final r in delGrupo) {
      final nuevoEvento = Evento.conDuracion(
        id: const Uuid().v4(),
        titulo: r.titulo,
        fecha: fechaInicio,
        horaInicio: r.hora,
        duracion: const Duration(hours: 1),
        color: r.color,
        recurrencia: Recurrencia.diaria,
      );
      eventosProv.agregarEvento(nuevoEvento);
    }
    _contadorRutinasAplicadas += delGrupo.length;
    _guardar();
    notifyListeners();
  }

  // ─── Notificaciones ──────────────────────────────────────

  void _programarNotificacionRutina(Rutina rutina) {
    final id = rutina.id.hashCode & 0x7fffffff;
    _notificationService.scheduleDailyNotification(
      id: id,
      categoria: NotifCategoria.rutinas,
      title: 'Rutina: ${rutina.titulo}',
      body: 'Es hora de tu rutina "${rutina.titulo}". ¡Vamos!',
      hora: rutina.hora,
      payload: 'rutina:${rutina.id}',
    );
  }

  void _cancelarNotificacionRutina(Rutina rutina) {
    final id = rutina.id.hashCode & 0x7fffffff;
    _notificationService.cancelNotification(id);
    _notificationService.cancelarPorPayload('rutina:${rutina.id}');
  }

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final gData = prefs.getString('grupos');
    final rData = prefs.getString('rutinas');
    final contador = prefs.getInt('rutinas_aplicadas_contador');

    if (gData != null) {
      _gruposReales = (json.decode(gData) as List)
          .map((g) => GrupoRutinas.fromJson(g))
          .toList();
    }
    if (rData != null) {
      _rutinas =
          (json.decode(rData) as List).map((r) => Rutina.fromJson(r)).toList();
      for (final r in _rutinas) {
        _programarNotificacionRutina(r);
      }
    }
    if (contador != null) {
      _contadorRutinasAplicadas = contador;
    }
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
    await prefs.setString(
        'grupos', json.encode(_gruposReales.map((g) => g.toJson()).toList()));
    await prefs.setString(
        'rutinas', json.encode(_rutinas.map((r) => r.toJson()).toList()));
    await prefs.setInt('rutinas_aplicadas_contador', _contadorRutinasAplicadas);
  }

  Future<void> reset() async {
    for (final r in _rutinas) {
      _cancelarNotificacionRutina(r);
    }
    _gruposReales = [
      GrupoRutinas(id: const Uuid().v4(), nombre: 'Salud', color: Colors.green),
      GrupoRutinas(id: const Uuid().v4(), nombre: 'Todos', color: Colors.blue),
      GrupoRutinas(
          id: const Uuid().v4(), nombre: 'Trabajo', color: Colors.orange),
    ];
    _rutinas.clear();
    _contadorRutinasAplicadas = 0;
    notifyListeners();
    await _guardar();
  }
}
