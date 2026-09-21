import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/metas_catalogo.dart';
import '../models/celebracion_meta.dart';
import '../models/insignia.dart';
import '../models/meta.dart';
import '../models/nivel_usuario.dart';

class MetasProvider extends ChangeNotifier {
  List<Meta> _metas = [];
  List<Insignia> _insignias = [];
  int _xpAcumulado = 0;

  /// Cola de celebraciones pendientes de mostrar en la UI.
  final List<CelebracionMeta> _celebraciones = [];

  List<Meta> get metas => List.unmodifiable(_metas);
  List<Insignia> get insignias => List.unmodifiable(_insignias);
  int get xpAcumulado => _xpAcumulado;

  /// Metas que no están completadas ni archivadas.
  List<Meta> get metasActivas =>
      _metas.where((m) => !m.completada && !m.archivada).toList();

  /// Metas completadas.
  List<Meta> get metasCompletadas => _metas.where((m) => m.completada).toList();

  /// Metas personalizadas activas.
  List<Meta> get metasPersonalizadas =>
      _metas.where((m) => m.esPersonalizada && !m.completada).toList();

  /// Nivel actual del usuario.
  NivelUsuario get nivel => NivelUsuario.calcular(_xpAcumulado);

  /// Insignias obtenidas.
  List<Insignia> get insigniasObtenidas =>
      _insignias.where((i) => i.obtenida).toList();

  // ──────────────────────────────────────────────────────────
  // CELEBRACIONES (Fase 16.4)
  // ──────────────────────────────────────────────────────────

  /// Lista de celebraciones pendientes de mostrar, en orden.
  List<CelebracionMeta> get celebracionesPendientes =>
      List.unmodifiable(_celebraciones);

  /// Consume (elimina) la primera celebración de la cola.
  void consumirCelebracion() {
    if (_celebraciones.isEmpty) return;
    _celebraciones.removeAt(0);
  }

  void _agregarCelebracion(CelebracionMeta cel) {
    _celebraciones.add(cel);
  }

  Future<void>? _ultimaEscritura;

  // ──────────────────────────────────────────────────────────
  // INICIALIZACIÓN
  // ──────────────────────────────────────────────────────────

  MetasProvider() {
    _cargarInsigniasBase();
  }

  void _cargarInsigniasBase() {
    _insignias = InsigniasCatalogo.todas
        .map((i) => Insignia(
              id: i.id,
              nombre: i.nombre,
              descripcion: i.descripcion,
              emoji: i.emoji,
              color: i.color,
            ))
        .toList();
  }

  // ──────────────────────────────────────────────────────────
  // METAS
  // ──────────────────────────────────────────────────────────

  void agregarMeta(Meta meta) {
    _metas.add(meta);
    _guardar();
    notifyListeners();
  }

  void eliminarMeta(String id) {
    _metas.removeWhere((m) => m.id == id);
    _guardar();
    notifyListeners();
  }

  void archivarMeta(String id) {
    final idx = _metas.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    _metas[idx].archivada = true;
    _guardar();
    notifyListeners();
  }

  void actualizarMeta(Meta modificada) {
    final idx = _metas.indexWhere((m) => m.id == modificada.id);
    if (idx == -1) return;
    _metas[idx] = modificada;
    _guardar();
    notifyListeners();
  }

  /// Marca una meta manual como completada.
  void completarManual(String id) {
    final idx = _metas.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    final meta = _metas[idx];
    if (meta.tipoProgreso != TipoProgresoMeta.manual) return;

    meta.progresoActual = meta.objetivo;
    _completarMetaInterna(idx);

    // Persistir y notificar (faltaba en la versión anterior).
    _guardar();
    notifyListeners();
  }

  /// Actualiza el progreso de todas las metas con un valor calculado.
  void actualizarProgresos(Map<String, int> progresosPorId) {
    bool cambios = false;

    for (int i = 0; i < _metas.length; i++) {
      final meta = _metas[i];
      if (meta.completada) continue;
      if (!meta.tipoProgreso.esCalculable) continue;

      final nuevoProgreso = progresosPorId[meta.id];
      if (nuevoProgreso == null) continue;

      if (nuevoProgreso != meta.progresoActual) {
        meta.progresoActual = nuevoProgreso;
        cambios = true;
      }

      if (!meta.completada && meta.alcanzoObjetivo) {
        _completarMetaInterna(i);
        cambios = true;
      }
    }

    if (cambios) {
      _guardar();
      notifyListeners();
    }
  }

  void _completarMetaInterna(int idx) {
    final meta = _metas[idx];
    if (meta.completada) return;

    // Capturar nivel ANTES de sumar XP
    final nivelAntes = nivel.nivel;

    meta.completada = true;
    meta.fechaCompletada = DateTime.now();
    _xpAcumulado += meta.recompensaXP;

    // 1) Celebración de meta completada
    _agregarCelebracion(
      CelebracionMeta(
        tipo: TipoCelebracion.metaCompletada,
        titulo: meta.titulo,
        descripcion: '¡Completaste esta meta!',
        emoji: meta.emoji,
        valor: meta.recompensaXP,
        color: meta.dificultad.color,
      ),
    );

    // 2) ¿Subió de nivel?
    final nivelDespues = nivel.nivel;
    if (nivelDespues > nivelAntes) {
      _agregarCelebracion(
        CelebracionMeta(
          tipo: TipoCelebracion.subioNivel,
          titulo: 'Nivel $nivelDespues · ${nivel.nombre}',
          descripcion: '¡Has alcanzado un nuevo nivel!',
          emoji: '⭐',
          valor: nivelDespues,
        ),
      );
    }

    // 3) Verificar insignias (puede encolar más celebraciones)
    _verificarInsignias();
  }

  // ──────────────────────────────────────────────────────────
  // INSIGNIAS
  // ──────────────────────────────────────────────────────────

  void _verificarInsignias() {
    final completadas = metasCompletadas;

    if (completadas.isNotEmpty) {
      _otorgar('primer_paso');
    }

    if (completadas.length >= 10) {
      _otorgar('constante');
    }

    final salud =
        completadas.where((m) => m.categoria == CategoriaMeta.salud).length;
    final tiempo =
        completadas.where((m) => m.categoria == CategoriaMeta.tiempo).length;

    if (salud >= 3) _otorgar('deportista');
    if (tiempo >= 3) _otorgar('organizado');

    final agua = completadas.where((m) => m.filtro == FiltroMeta.agua).length;
    final alimentacion =
        completadas.where((m) => m.filtro == FiltroMeta.alimentacion).length;
    final medicacion =
        completadas.where((m) => m.filtro == FiltroMeta.medicacion).length;

    if (agua >= 3) _otorgar('hidratado');
    if (alimentacion >= 3) _otorgar('nutricionista');
    if (medicacion >= 3) _otorgar('medico_puntual');

    final n = nivel;
    if (n.nivel >= 6) _otorgar('sabio');
    if (n.nivel >= 8) _otorgar('templo');
  }

  void _otorgar(String idInsignia) {
    final idx = _insignias.indexWhere((i) => i.id == idInsignia);
    if (idx == -1) return;
    if (_insignias[idx].obtenida) return;
    _insignias[idx].obtenida = true;
    _insignias[idx].fechaObtenida = DateTime.now();

    // Encolar celebración de insignia nueva
    _agregarCelebracion(
      CelebracionMeta(
        tipo: TipoCelebracion.insigniaDesbloqueada,
        titulo: _insignias[idx].nombre,
        descripcion: _insignias[idx].descripcion,
        emoji: _insignias[idx].emoji,
        color: _insignias[idx].color,
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // PERSISTENCIA
  // ──────────────────────────────────────────────────────────

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();

    final metasData = prefs.getString('metas');
    if (metasData != null) {
      final lista = json.decode(metasData) as List;
      _metas = lista.map((m) => Meta.fromJson(m)).toList();
    } else {
      _metas = MetasCatalogo.generar();
    }

    final insigniasData = prefs.getString('insignias');
    if (insigniasData != null) {
      final lista = json.decode(insigniasData) as List;
      _insignias = lista.map((i) => Insignia.fromJson(i)).toList();
    }

    final xp = prefs.getInt('xp_acumulado');
    if (xp != null) _xpAcumulado = xp;

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
      'metas',
      json.encode(_metas.map((m) => m.toJson()).toList()),
    );
    await prefs.setString(
      'insignias',
      json.encode(_insignias.map((i) => i.toJsonCompleto()).toList()),
    );
    await prefs.setInt('xp_acumulado', _xpAcumulado);
  }

  Future<void> reset() async {
    _metas = MetasCatalogo.generar();
    _xpAcumulado = 0;
    _celebraciones.clear();
    _cargarInsigniasBase();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('metas');
    await prefs.remove('insignias');
    await prefs.remove('xp_acumulado');
  }

  // ──────────────────────────────────────────────────────────
  // METAS PERSONALIZADAS
  // ──────────────────────────────────────────────────────────

  Meta crearMetaPersonalizada({
    required String titulo,
    required String descripcion,
    required DificultadMeta dificultad,
    required CategoriaMeta categoria,
    required TipoProgresoMeta tipoProgreso,
    required FiltroMeta filtro,
    required int objetivo,
    String emoji = '🎯',
  }) {
    final meta = Meta(
      id: const Uuid().v4(),
      titulo: titulo,
      descripcion: descripcion,
      dificultad: dificultad,
      categoria: categoria,
      tipoProgreso: tipoProgreso,
      filtro: filtro,
      objetivo: objetivo,
      esPersonalizada: true,
      emoji: emoji,
    );
    _metas.add(meta);
    _guardar();
    notifyListeners();
    return meta;
  }
}
