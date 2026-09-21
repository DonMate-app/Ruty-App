import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/evento.dart';

class VisibilityPrefs {
  static const String _key = 'tipos_visibles';

  // Devuelve conjunto de tipos visibles. Si no hay nada guardado, todos son visibles.
  static Future<Set<TipoEvento>> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) {
      return TipoEvento.values.toSet();
    }
    final lista = json.decode(data) as List;
    return lista
        .map((name) => TipoEvento.values.firstWhere(
              (t) => t.name == name,
              orElse: () => TipoEvento.otro,
            ))
        .toSet();
  }

  static Future<void> guardar(Set<TipoEvento> tipos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      json.encode(tipos.map((t) => t.name).toList()),
    );
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
