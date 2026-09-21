import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/nota_rapida.dart';

class NotasProvider extends ChangeNotifier {
  List<NotaRapida> _notas = [];
  String _filtroBusqueda = '';

  List<NotaRapida> get notas {
    final lista = List<NotaRapida>.from(_notas);

    // Ordenar: fijadas primero, luego por fecha de modificación
    lista.sort((a, b) {
      if (a.fijada != b.fijada) return a.fijada ? -1 : 1;
      return b.fechaModificacion.compareTo(a.fechaModificacion);
    });

    // Filtrar por búsqueda
    if (_filtroBusqueda.trim().isEmpty) return lista;
    final q = _filtroBusqueda.toLowerCase();
    return lista.where((n) => n.contenido.toLowerCase().contains(q)).toList();
  }

  List<NotaRapida> get notasSinFiltrar => List.from(_notas);

  String get filtroBusqueda => _filtroBusqueda;

  int get total => _notas.length;

  bool get estaVacio => _notas.isEmpty;

  Future<void>? _ultimaEscritura;

  void setFiltroBusqueda(String valor) {
    _filtroBusqueda = valor;
    notifyListeners();
  }

  void agregarNota(String contenido, {int? colorIndex}) {
    final colores = coloresDisponibles;
    final color = colorIndex != null && colorIndex < colores.length
        ? colores[colorIndex]
        : colores.first;

    _notas.add(NotaRapida(
      id: const Uuid().v4(),
      contenido: contenido,
      color: color,
    ));
    _guardar();
    notifyListeners();
  }

  void actualizarNota(NotaRapida modificada) {
    final idx = _notas.indexWhere((n) => n.id == modificada.id);
    if (idx == -1) return;
    modificada.fechaModificacion = DateTime.now();
    _notas[idx] = modificada;
    _guardar();
    notifyListeners();
  }

  void editarContenido(String id, String nuevoContenido) {
    final idx = _notas.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    _notas[idx].contenido = nuevoContenido;
    _notas[idx].fechaModificacion = DateTime.now();
    _guardar();
    notifyListeners();
  }

  void toggleFijada(String id) {
    final idx = _notas.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    _notas[idx].fijada = !_notas[idx].fijada;
    _guardar();
    notifyListeners();
  }

  void cambiarColor(String id, int colorIndex) {
    final colores = coloresDisponibles;
    if (colorIndex < 0 || colorIndex >= colores.length) return;
    final idx = _notas.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    _notas[idx].color = colores[colorIndex];
    _notas[idx].fechaModificacion = DateTime.now();
    _guardar();
    notifyListeners();
  }

  void eliminarNota(String id) {
    _notas.removeWhere((n) => n.id == id);
    _guardar();
    notifyListeners();
  }

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('notas_rapidas');
    if (data != null) {
      try {
        final lista = json.decode(data) as List;
        _notas = lista.map((n) => NotaRapida.fromJson(n)).toList();
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
      'notas_rapidas',
      json.encode(_notas.map((n) => n.toJson()).toList()),
    );
  }

  Future<void> reset() async {
    _notas.clear();
    _filtroBusqueda = '';
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notas_rapidas');
  }

  static const List<Color> coloresDisponibles = [
    Color(0xFFFFF59D), // Amarillo pastel
    Color(0xFFB3E5FC), // Azul pastel
    Color(0xFFC8E6C9), // Verde pastel
    Color(0xFFF8BBD0), // Rosa pastel
    Color(0xFFD1C4E9), // Lavanda
    Color(0xFFFFCCBC), // Melocotón
    Color(0xFFFFF9C4), // Limón
    Color(0xFFE1BEE7), // Lila
  ];
}
