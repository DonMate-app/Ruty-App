import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/tarea.dart';

class TareasProvider extends ChangeNotifier {
  List<Tarea> _tareas = [];
  List<Tarea> get tareas => _tareas;

  Future<void>? _ultimaEscritura;

  List<Tarea> get pendientes => _tareas.where((t) => !t.completada).toList();

  List<Tarea> get completadas => _tareas.where((t) => t.completada).toList();

  void agregarTarea(Tarea t) {
    _tareas.add(t);
    _guardar();
    notifyListeners();
  }

  void eliminarTarea(String id) {
    _tareas.removeWhere((t) => t.id == id);
    _guardar();
    notifyListeners();
  }

  void modificarTarea(Tarea modificada) {
    final idx = _tareas.indexWhere((t) => t.id == modificada.id);
    if (idx != -1) {
      _tareas[idx] = modificada;
      _guardar();
      notifyListeners();
    }
  }

  void toggleCompletada(String id) {
    final idx = _tareas.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _tareas[idx].completada = !_tareas[idx].completada;
      _guardar();
      notifyListeners();
    }
  }

  void duplicarTarea(Tarea original) {
    final nueva = Tarea(
      id: const Uuid().v4(),
      titulo: '${original.titulo} (copia)',
      descripcion: original.descripcion,
      duracion: original.duracion,
      unidad: original.unidad,
      color: original.color,
      prioridad: original.prioridad,
      fechaLimite: original.fechaLimite,
      fechaCreacion: DateTime.now(),
    );
    _tareas.add(nueva);
    _guardar();
    notifyListeners();
  }

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tareas');
    if (data != null) {
      final lista = json.decode(data) as List;
      _tareas = lista.map((t) => Tarea.fromJson(t)).toList();
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
      'tareas',
      json.encode(_tareas.map((t) => t.toJson()).toList()),
    );
  }

  Future<void> reset() async {
    _tareas.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tareas');
    notifyListeners();
  }
}
