import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/comentario_usuario.dart';

class ComentariosProvider extends ChangeNotifier {
  List<ComentarioUsuario> _comentarios = [];

  List<ComentarioUsuario> get comentarios {
    final lista = List<ComentarioUsuario>.from(_comentarios);
    lista.sort((a, b) => b.fecha.compareTo(a.fecha));
    return lista;
  }

  int get total => _comentarios.length;

  bool get estaVacio => _comentarios.isEmpty;

  Future<void>? _ultimaEscritura;

  void agregarComentario({
    required TipoComentario tipo,
    required String mensaje,
    required String contacto,
    required String versionApp,
  }) {
    _comentarios.add(ComentarioUsuario(
      id: const Uuid().v4(),
      tipo: tipo,
      mensaje: mensaje,
      contacto: contacto,
      fecha: DateTime.now(),
      versionApp: versionApp,
      enviado: true,
    ));
    _guardar();
    notifyListeners();
  }

  void eliminarComentario(String id) {
    _comentarios.removeWhere((c) => c.id == id);
    _guardar();
    notifyListeners();
  }

  void limpiarTodo() {
    _comentarios.clear();
    _guardar();
    notifyListeners();
  }

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('comentarios_usuario');
    if (data != null) {
      try {
        final lista = json.decode(data) as List;
        _comentarios = lista.map((c) => ComentarioUsuario.fromJson(c)).toList();
        notifyListeners();
      } catch (_) {}
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
      'comentarios_usuario',
      json.encode(_comentarios.map((c) => c.toJson()).toList()),
    );
  }

  Future<void> reset() async {
    _comentarios.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('comentarios_usuario');
  }
}
