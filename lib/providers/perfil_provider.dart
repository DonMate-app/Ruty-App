import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/perfil_usuario.dart';

class PerfilProvider extends ChangeNotifier {
  PerfilUsuario _perfil = PerfilUsuario();
  PerfilUsuario get perfil => _perfil;

  Future<void>? _ultimaEscritura;

  void actualizarPerfil(PerfilUsuario nuevo) {
    _perfil = nuevo;
    _guardar();
    notifyListeners();
  }

  void actualizarCampo({
    String? nombre,
    int? edad,
    Sexo? sexo,
    double? pesoKg,
    double? alturaCm,
    EstiloVida? estiloVida,
    Set<String>? enfermedades,
    Set<String>? alergias,
    Set<Condicion>? condiciones,
    String? notas,
  }) {
    if (nombre != null) _perfil.nombre = nombre;
    if (edad != null) _perfil.edad = edad;
    if (sexo != null) _perfil.sexo = sexo;
    if (pesoKg != null) _perfil.pesoKg = pesoKg;
    if (alturaCm != null) _perfil.alturaCm = alturaCm;
    if (estiloVida != null) _perfil.estiloVida = estiloVida;
    if (enfermedades != null) _perfil.enfermedades = enfermedades;
    if (alergias != null) _perfil.alergias = alergias;
    if (condiciones != null) _perfil.condiciones = condiciones;
    if (notas != null) _perfil.notas = notas;

    _guardar();
    notifyListeners();
  }

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('perfil_usuario');
    if (data != null) {
      try {
        _perfil = PerfilUsuario.fromJson(
          json.decode(data) as Map<String, dynamic>,
        );
        notifyListeners();
      } catch (e) {
        // Si hay un error de parseo, se conserva el perfil por defecto
      }
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
      'perfil_usuario',
      json.encode(_perfil.toJson()),
    );
  }

  Future<void> reset() async {
    _perfil = PerfilUsuario();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('perfil_usuario');
  }
}
