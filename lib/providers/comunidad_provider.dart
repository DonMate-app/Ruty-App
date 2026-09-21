import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/comunidad_seed.dart';
import '../models/comunidad_item.dart';

class ComunidadProvider extends ChangeNotifier {
  List<ComunidadItem> _itemsSistema = [];
  List<ComunidadItem> _itemsUsuario = [];
  Set<String> _likesUsuario = {}; // IDs a los que el usuario dio like

  List<ComunidadItem> get itemsSistema => List.from(_itemsSistema);
  List<ComunidadItem> get itemsUsuario => List.from(_itemsUsuario);

  /// Todos los items (sistema + usuario) con los likes y meGusta aplicados.
  List<ComunidadItem> get todosLosItems {
    final todos = [..._itemsSistema, ..._itemsUsuario];
    for (final item in todos) {
      item.meGusta = _likesUsuario.contains(item.id);
    }
    return todos;
  }

  /// Items ordenados por likes (para la pestaña "Comunidad").
  List<ComunidadItem> get itemsPopulares {
    final lista = todosLosItems;
    lista.sort((a, b) {
      // Los del sistema con más likes primero, luego usuario
      final aTotal = a.likes + (a.meGusta ? 1 : 0);
      final bTotal = b.likes + (b.meGusta ? 1 : 0);
      return bTotal.compareTo(aTotal);
    });
    return lista;
  }

  /// El item más recomendado por la comunidad (el de más likes).
  ComunidadItem? get masRecomendado {
    final populares = itemsPopulares;
    return populares.isEmpty ? null : populares.first;
  }

  List<ComunidadItem> itemsPorCategoria(CategoriaComunidad categoria) {
    return todosLosItems.where((i) => i.categoria == categoria).toList();
  }

  Future<void>? _ultimaEscritura;

  // ─── Operaciones de usuario ────────────────────────────────

  void agregarItemUsuario(ComunidadItem item) {
    _itemsUsuario.add(item);
    _guardar();
    notifyListeners();
  }

  void eliminarItemUsuario(String id) {
    _itemsUsuario.removeWhere((i) => i.id == id);
    _likesUsuario.remove(id);
    _guardar();
    notifyListeners();
  }

  void modificarItemUsuario(ComunidadItem modificado) {
    final idx = _itemsUsuario.indexWhere((i) => i.id == modificado.id);
    if (idx != -1) {
      _itemsUsuario[idx] = modificado;
      _guardar();
      notifyListeners();
    }
  }

  /// Alterna el like del usuario en un item. Solo modifica `meGusta`;
  /// los likes del sistema son fijos (catálogo curado).
  void toggleLike(String id) {
    if (_likesUsuario.contains(id)) {
      _likesUsuario.remove(id);
    } else {
      _likesUsuario.add(id);
    }
    _guardar();
    notifyListeners();
  }

  // ─── Persistencia ──────────────────────────────────────────

  Future<void> cargar() async {
    // Siempre partimos del catálogo del sistema (puede actualizarse con cada versión)
    _itemsSistema = obtenerSeedComunidad();

    final prefs = await SharedPreferences.getInstance();

    final uData = prefs.getString('comunidad_usuario');
    if (uData != null) {
      _itemsUsuario = (json.decode(uData) as List)
          .map((i) => ComunidadItem.fromJson(i))
          .toList();
    }

    final lData = prefs.getString('comunidad_likes');
    if (lData != null) {
      _likesUsuario = Set<String>.from(json.decode(lData) as List);
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
      'comunidad_usuario',
      json.encode(_itemsUsuario.map((i) => i.toJson()).toList()),
    );
    await prefs.setString(
      'comunidad_likes',
      json.encode(_likesUsuario.toList()),
    );
  }

  Future<void> reset() async {
    _itemsUsuario.clear();
    _likesUsuario.clear();
    _itemsSistema = obtenerSeedComunidad();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('comunidad_usuario');
    await prefs.remove('comunidad_likes');
  }
}
