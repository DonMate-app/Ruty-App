import '../models/evento.dart';
import '../models/registro_ejercicio.dart';
import '../models/registro_medicacion.dart';
import '../models/resumen_semanal.dart';
import '../models/tarea.dart';

class ResumenSemanalService {
  /// Calcula el resumen de la semana que comienza en [inicioSemana]
  /// y termina en [finSemana] (ambos inclusive).
  ResumenSemanal calcular({
    required DateTime inicioSemana,
    required DateTime finSemana,
    required List<Evento> eventos,
    required List<Tarea> tareas,
    required List<RegistroEjercicio> registrosEjercicio,
    required Map<String, int> minutosPorEjercicioId,
    required int registrosAlimentacion,
    required List<RegistroMedicacion> registrosMedicacion,
    required int totalMedicamentos,
  }) {
    // Eventos creados en el rango
    final eventosCreados = eventos.where((e) {
      return !e.fecha.isBefore(inicioSemana) && !e.fecha.isAfter(finSemana);
    }).length;

    // Eventos "completados": aproximación → los no suspendidos del rango
    final eventosCompletados = eventos.where((e) {
      return !e.suspendido &&
          !e.fecha.isBefore(inicioSemana) &&
          !e.fecha.isAfter(finSemana);
    }).length;

    // Tareas completadas con fecha límite en el rango
    final tareasCompletadas = tareas.where((t) {
      return t.completada &&
          !t.fechaCreacion.isAfter(finSemana) &&
          !t.fechaCreacion.isBefore(inicioSemana);
    }).length;

    // Tareas pendientes actuales
    final tareasPendientes = tareas.where((t) => !t.completada).length;

    // Días con ejercicio (días únicos con al menos un registro completado)
    final diasConEjercicio = <String>{};
    final minutosEjercicio = <int>[];

    for (final r in registrosEjercicio) {
      if (!r.completado) continue;
      if (r.fecha.isBefore(inicioSemana) || r.fecha.isAfter(finSemana)) {
        continue;
      }
      final clave = '${r.fecha.year}-${r.fecha.month}-${r.fecha.day}';
      diasConEjercicio.add(clave);

      final minutos = minutosPorEjercicioId[r.ejercicioId] ?? 0;
      if (minutos > 0) minutosEjercicio.add(minutos);
    }

    // Dosis de medicación
    final registrosMed = registrosMedicacion.where((r) {
      return !r.fechaHora.isBefore(inicioSemana) &&
          !r.fechaHora.isAfter(finSemana);
    }).toList();

    final dosisTomadas = registrosMed.where((r) => r.tomado).length;

    // Dosis esperadas: medicamentos × días del rango
    final diasRango = finSemana.difference(inicioSemana).inDays + 1;
    final dosisEsperadas = totalMedicamentos * diasRango;

    return ResumenSemanal(
      inicioSemana: inicioSemana,
      finSemana: finSemana,
      eventosCreados: eventosCreados,
      eventosCompletados: eventosCompletados,
      tareasCompletadas: tareasCompletadas,
      tareasPendientes: tareasPendientes,
      diasConEjercicio: diasConEjercicio.length,
      minutosEjercicio: minutosEjercicio.fold<int>(0, (a, b) => a + b),
      registrosAlimentacion: registrosAlimentacion,
      dosisTomadas: dosisTomadas,
      dosisEsperadas: dosisEsperadas,
    );
  }

  /// Devuelve el lunes de la semana anterior a [fecha] (00:00).
  static DateTime inicioSemanaPasada(DateTime fecha) {
    // Ajustamos al lunes de la semana actual
    final diaSemana = fecha.weekday; // 1 = lunes, 7 = domingo
    final lunesActual = fecha.subtract(Duration(days: diaSemana - 1));
    final lunesPasado = lunesActual.subtract(const Duration(days: 7));
    return DateTime(lunesPasado.year, lunesPasado.month, lunesPasado.day);
  }

  /// Devuelve el domingo de la semana anterior a [fecha] (23:59:59).
  static DateTime finSemanaPasada(DateTime fecha) {
    final inicio = inicioSemanaPasada(fecha);
    final domingo = inicio.add(const Duration(days: 6));
    return DateTime(
      domingo.year,
      domingo.month,
      domingo.day,
      23,
      59,
      59,
    );
  }

  /// Devuelve true si [fecha] es lunes.
  static bool esLunes(DateTime fecha) => fecha.weekday == 1;
}
