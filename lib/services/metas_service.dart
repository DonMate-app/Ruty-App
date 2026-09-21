import 'package:flutter/foundation.dart';

import '../models/alimento_registro.dart';
import '../models/evento.dart';
import '../models/meta.dart';
import '../models/nota_rapida.dart';
import '../models/registro_ejercicio.dart';
import '../models/registro_medicacion.dart';
import '../models/tarea.dart';

/// Servicio que calcula el progreso actual de una meta a partir de los
/// datos que ya viven en los providers de la app.
class MetasService {
  /// Calcula el progreso de [meta] con los datos disponibles.
  static int calcularProgreso({
    required Meta meta,
    required List<Evento> eventos,
    required List<Tarea> tareas,
    required List<RegistroEjercicio> registrosEjercicio,
    required List<RegistroMedicacion> registrosMedicacion,
    required List<AlimentoRegistro> registrosAlimentacion,
    required List<NotaRapida> notas,
    required int totalMedicamentos,
    required int totalRutinasAplicadas,
    required Map<String, int> minutosPorEjercicioId,
  }) {
    switch (meta.tipoProgreso) {
      case TipoProgresoMeta.diasConsecutivos:
        return _diasConsecutivos(
          meta: meta,
          registrosEjercicio: registrosEjercicio,
          registrosMedicacion: registrosMedicacion,
          registrosAlimentacion: registrosAlimentacion,
          notas: notas,
        );
      case TipoProgresoMeta.totalRegistros:
        return _totalRegistros(
          meta: meta,
          registrosEjercicio: registrosEjercicio,
          registrosMedicacion: registrosMedicacion,
          registrosAlimentacion: registrosAlimentacion,
          notas: notas,
        );
      case TipoProgresoMeta.totalMinutos:
        return _totalMinutos(
          registrosEjercicio: registrosEjercicio,
          minutosPorEjercicioId: minutosPorEjercicioId,
        );
      case TipoProgresoMeta.adherenciaPorcentaje:
        return _adherencia(
          registrosMedicacion: registrosMedicacion,
          totalMedicamentos: totalMedicamentos,
        );
      case TipoProgresoMeta.totalTareasCompletadas:
        return tareas.where((t) => t.completada).length;
      case TipoProgresoMeta.totalEventos:
        return eventos.length;
      case TipoProgresoMeta.totalRutinasAplicadas:
        return totalRutinasAplicadas;
      case TipoProgresoMeta.manual:
        return meta.progresoActual;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // CÁLCULOS ESPECÍFICOS
  // ═══════════════════════════════════════════════════════════

  /// Cuenta días consecutivos hacia atrás desde hoy con al menos
  /// un registro del tipo indicado.
  static int _diasConsecutivos({
    required Meta meta,
    required List<RegistroEjercicio> registrosEjercicio,
    required List<RegistroMedicacion> registrosMedicacion,
    required List<AlimentoRegistro> registrosAlimentacion,
    required List<NotaRapida> notas,
  }) {
    int consecutivos = 0;
    final hoy = DateTime.now();

    // Iterar hacia atrás, máximo 365 días
    for (int i = 0; i < 365; i++) {
      final dia =
          DateTime(hoy.year, hoy.month, hoy.day).subtract(Duration(days: i));

      if (_tieneRegistroEnDia(
        meta: meta,
        dia: dia,
        registrosEjercicio: registrosEjercicio,
        registrosMedicacion: registrosMedicacion,
        registrosAlimentacion: registrosAlimentacion,
        notas: notas,
      )) {
        consecutivos++;
      } else {
        // Si es el día de hoy y no hay registro, igual cuenta lo anterior.
        // Si es un día anterior y no hay, cortamos.
        if (i == 0) {
          // Hoy no hay registro aún, pero no rompe la racha todavía.
          continue;
        }
        break;
      }
    }

    return consecutivos;
  }

  static bool _tieneRegistroEnDia({
    required Meta meta,
    required DateTime dia,
    required List<RegistroEjercicio> registrosEjercicio,
    required List<RegistroMedicacion> registrosMedicacion,
    required List<AlimentoRegistro> registrosAlimentacion,
    required List<NotaRapida> notas,
  }) {
    switch (meta.filtro) {
      case FiltroMeta.agua:
        return registrosAlimentacion.any((r) =>
            _mismoDia(r.fechaHora, dia) && r.tipo == TipoAlimento.liquido);
      case FiltroMeta.ejercicio:
        return registrosEjercicio
            .any((r) => _mismoDia(r.fecha, dia) && r.completado);
      case FiltroMeta.alimentacion:
        return registrosAlimentacion.any((r) => _mismoDia(r.fechaHora, dia));
      case FiltroMeta.notas:
        return notas.any((n) => _mismoDia(n.fechaCreacion, dia));
      case FiltroMeta.medicacion:
        return registrosMedicacion
            .any((r) => _mismoDia(r.fechaHora, dia) && r.tomado);
      case FiltroMeta.ninguno:
        return true;
    }
  }

  static int _totalRegistros({
    required Meta meta,
    required List<RegistroEjercicio> registrosEjercicio,
    required List<RegistroMedicacion> registrosMedicacion,
    required List<AlimentoRegistro> registrosAlimentacion,
    required List<NotaRapida> notas,
  }) {
    switch (meta.filtro) {
      case FiltroMeta.agua:
        return registrosAlimentacion
            .where((r) => r.tipo == TipoAlimento.liquido)
            .length;
      case FiltroMeta.ejercicio:
        return registrosEjercicio.where((r) => r.completado).length;
      case FiltroMeta.alimentacion:
        return registrosAlimentacion.length;
      case FiltroMeta.notas:
        return notas.length;
      case FiltroMeta.medicacion:
        return registrosMedicacion.where((r) => r.tomado).length;
      case FiltroMeta.ninguno:
        return 0;
    }
  }

  static int _totalMinutos({
    required List<RegistroEjercicio> registrosEjercicio,
    required Map<String, int> minutosPorEjercicioId,
  }) {
    int total = 0;
    for (final r in registrosEjercicio) {
      if (r.completado) {
        total += minutosPorEjercicioId[r.ejercicioId] ?? 0;
      }
    }
    return total;
  }

  static int _adherencia({
    required List<RegistroMedicacion> registrosMedicacion,
    required int totalMedicamentos,
  }) {
    if (totalMedicamentos == 0) return 0;

    // Calcular en los últimos 30 días
    final hace30Dias = DateTime.now().subtract(const Duration(days: 30));
    final registros = registrosMedicacion
        .where((r) => r.fechaHora.isAfter(hace30Dias) && r.tomado)
        .length;

    final esperados = totalMedicamentos * 30;
    if (esperados == 0) return 0;
    return ((registros / esperados) * 100).round();
  }

  static bool _mismoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Cuenta cuántos días seguidos desde una fecha el usuario usó la app.
  /// Útil para la racha general.
  static int calcularRachaGeneral({
    required List<Evento> eventos,
    required List<Tarea> tareas,
    required List<RegistroEjercicio> registrosEjercicio,
    required List<NotaRapida> notas,
  }) {
    int consecutivos = 0;
    final hoy = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final dia =
          DateTime(hoy.year, hoy.month, hoy.day).subtract(Duration(days: i));

      final activo = eventos.any((e) => _mismoDia(e.fecha, dia)) ||
          tareas.any((t) => t.completada && _mismoDia(t.fechaCreacion, dia)) ||
          registrosEjercicio
              .any((r) => r.completado && _mismoDia(r.fecha, dia)) ||
          notas.any((n) => _mismoDia(n.fechaCreacion, dia));

      if (activo) {
        consecutivos++;
      } else if (i > 0) {
        break;
      }
    }

    return consecutivos;
  }
}
