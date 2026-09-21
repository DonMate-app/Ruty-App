import 'package:flutter/material.dart';

import '../models/alimento_registro.dart';
import '../models/comunidad_item.dart';
import '../models/evento.dart';
import '../models/medicamento.dart';
import '../models/perfil_usuario.dart';
import '../models/recomendacion.dart';
import '../models/registro_ejercicio.dart';
import '../models/registro_medicacion.dart';
import '../models/tarea.dart';

class RecomendacionesService {
  /// Genera recomendaciones basadas en todos los datos actuales.
  List<Recomendacion> generar({
    required PerfilUsuario perfil,
    required List<Evento> eventosHoy,
    required List<Tarea> tareasPendientes,
    required List<AlimentoRegistro> alimentacionHoy,
    required List<EjercicioDatos> ejercicioHoy,
    required List<RegistroMedicacion> medicacionHoy,
    required List<Medicamento> medicamentos,
    required List<ComunidadItem> itemsComunidad,
    required List<AlimentoRegistro> alimentacionSemana,
    required List<EjercicioDatos> ejercicioSemana,
  }) {
    final recomendaciones = <Recomendacion>[];

    // ═══ REGLAS DE HIDRATACIÓN ═══
    final liquidosHoy =
        alimentacionHoy.where((r) => r.tipo == TipoAlimento.liquido).length;
    if (liquidosHoy == 0 && alimentacionHoy.isNotEmpty) {
      recomendaciones.add(const Recomendacion(
        id: 'hidratacion_cero',
        titulo: 'Sin hidratación registrada',
        mensaje: 'Hoy no has anotado ningún líquido. '
            'Recuerda beber al menos 8 vasos de agua al día.',
        icono: Icons.local_drink,
        prioridad: PrioridadRecomendacion.alta,
        categoria: CategoriaRecomendacion.salud,
      ));
    } else if (liquidosHoy > 0 && liquidosHoy < 4) {
      recomendaciones.add(Recomendacion(
        id: 'hidratacion_baja',
        titulo: 'Hidratación baja',
        mensaje: 'Llevas $liquidosHoy registro(s) de líquidos hoy. '
            'Intenta llegar a 8 para mantenerte hidratado.',
        icono: Icons.water_drop_outlined,
        prioridad: PrioridadRecomendacion.media,
        categoria: CategoriaRecomendacion.salud,
      ));
    }

    // ═══ REGLAS DE MEDICACIÓN ═══
    if (medicamentos.isNotEmpty) {
      final tomadosHoy = medicacionHoy.where((r) => r.tomado).length;
      final totalMedicamentos = medicamentos.length;
      if (tomadosHoy == 0) {
        recomendaciones.add(Recomendacion(
          id: 'medicacion_sin_tomas',
          titulo: 'Medicación pendiente',
          mensaje: 'Aún no has registrado ninguna toma hoy. '
              'Tienes $totalMedicamentos medicamento(s) programado(s).',
          icono: Icons.medication_outlined,
          prioridad: PrioridadRecomendacion.alta,
          categoria: CategoriaRecomendacion.salud,
        ));
      } else if (tomadosHoy < totalMedicamentos) {
        recomendaciones.add(Recomendacion(
          id: 'medicacion_parcial',
          titulo: 'Faltan tomas por registrar',
          mensaje: 'Llevas $tomadosHoy de $totalMedicamentos. '
              'Completa tus tomas para mejor adherencia.',
          icono: Icons.schedule,
          prioridad: PrioridadRecomendacion.media,
          categoria: CategoriaRecomendacion.salud,
        ));
      }
    }

    // ═══ REGLAS DE EJERCICIO (según estilo de vida) ═══
    final ejercicioCompletadoHoy =
        ejercicioHoy.where((e) => e.completado).length;

    if (perfil.estiloVida == EstiloVida.deportista ||
        perfil.estiloVida == EstiloVida.activo) {
      if (ejercicioCompletadoHoy == 0 && ejercicioHoy.isNotEmpty) {
        recomendaciones.add(const Recomendacion(
          id: 'ejercicio_activo_pendiente',
          titulo: 'Día sin ejercicio completado',
          mensaje: 'Según tu perfil activo, hoy aún no has marcado '
              'ningún ejercicio. ¡Aún hay tiempo!',
          icono: Icons.fitness_center,
          prioridad: PrioridadRecomendacion.media,
          categoria: CategoriaRecomendacion.salud,
        ));
      }
    } else if (perfil.estiloVida == EstiloVida.sedentario) {
      // Sugerir actividad mínima
      if (ejercicioSemana.where((e) => e.completado).isEmpty) {
        recomendaciones.add(const Recomendacion(
          id: 'ejercicio_sedentario',
          titulo: 'Empieza con poco',
          mensaje: 'Una caminata de 15 minutos ya marca la diferencia. '
              '¿Probamos con algo sencillo hoy?',
          icono: Icons.directions_walk,
          prioridad: PrioridadRecomendacion.baja,
          categoria: CategoriaRecomendacion.bienestar,
        ));
      }
    }

    // ═══ REGLAS DE ALIMENTACIÓN ═══
    if (alimentacionHoy.isEmpty) {
      recomendaciones.add(const Recomendacion(
        id: 'sin_alimentacion_hoy',
        titulo: 'Sin comidas registradas',
        mensaje: 'Aún no has anotado ninguna comida hoy. '
            'Registrar lo que comes ayuda a crear conciencia.',
        icono: Icons.restaurant_outlined,
        prioridad: PrioridadRecomendacion.media,
        categoria: CategoriaRecomendacion.salud,
      ));
    } else if (alimentacionHoy.length == 1) {
      recomendaciones.add(const Recomendacion(
        id: 'pocas_comidas',
        titulo: 'Recuerda registrar todas tus comidas',
        mensaje: 'Solo tienes un registro hoy. '
            'Es útil anotar desayuno, almuerzo y cena.',
        icono: Icons.restaurant_menu,
        prioridad: PrioridadRecomendacion.baja,
        categoria: CategoriaRecomendacion.salud,
      ));
    }

    // ═══ REGLAS DE TAREAS ═══
    final tareasAlta = tareasPendientes
        .where((t) => t.prioridad == PrioridadTarea.alta)
        .length;
    if (tareasAlta > 0) {
      recomendaciones.add(Recomendacion(
        id: 'tareas_alta_prioridad',
        titulo: tareasAlta == 1
            ? '1 tarea de alta prioridad pendiente'
            : '$tareasAlta tareas de alta prioridad pendientes',
        mensaje: 'Concéntrate en completarlas antes que las demás.',
        icono: Icons.priority_high,
        prioridad: PrioridadRecomendacion.alta,
        categoria: CategoriaRecomendacion.tiempo,
      ));
    }

    // Tareas vencidas
    final hoy = DateTime.now();
    final inicioDia = DateTime(hoy.year, hoy.month, hoy.day);
    final tareasVencidas = tareasPendientes
        .where(
            (t) => t.fechaLimite != null && t.fechaLimite!.isBefore(inicioDia))
        .length;
    if (tareasVencidas > 0) {
      recomendaciones.add(Recomendacion(
        id: 'tareas_vencidas',
        titulo: tareasVencidas == 1
            ? '1 tarea vencida'
            : '$tareasVencidas tareas vencidas',
        mensaje: 'Revisa y actualiza tus tareas vencidas para '
            'mantener tu organización.',
        icono: Icons.warning_amber,
        prioridad: PrioridadRecomendacion.alta,
        categoria: CategoriaRecomendacion.tiempo,
      ));
    }

    // ═══ REGLAS DE EVENTOS ═══
    if (eventosHoy.length >= 6) {
      recomendaciones.add(Recomendacion(
        id: 'agenda_cargada',
        titulo: 'Agenda muy cargada',
        mensaje: 'Tienes ${eventosHoy.length} eventos hoy. '
            'Recuerda tomar pausas entre actividades.',
        icono: Icons.event_busy,
        prioridad: PrioridadRecomendacion.media,
        categoria: CategoriaRecomendacion.tiempo,
      ));
    }

    // ═══ REGLAS DE PERFIL ═══
    if (perfil.alergias.isNotEmpty) {
      final alergiasTexto = perfil.alergias.take(3).join(', ');
      recomendaciones.add(Recomendacion(
        id: 'alergias_recordatorio',
        titulo: 'Recuerda tus alergias',
        mensaje: 'Tienes alergia a: $alergiasTexto. '
            'Vigila los ingredientes al comer fuera.',
        icono: Icons.warning_amber_outlined,
        prioridad: PrioridadRecomendacion.baja,
        categoria: CategoriaRecomendacion.perfil,
      ));
    }

    if (perfil.enfermedades.contains('Diabetes')) {
      recomendaciones.add(const Recomendacion(
        id: 'perfil_diabetes',
        titulo: 'Cuida tu alimentación',
        mensaje: 'Con diabetes, es clave mantener horarios de comida '
            'regulares y evitar azúcares simples.',
        icono: Icons.health_and_safety,
        prioridad: PrioridadRecomendacion.baja,
        categoria: CategoriaRecomendacion.perfil,
      ));
    }

    if (perfil.condiciones.contains(Condicion.embarazo)) {
      recomendaciones.add(const Recomendacion(
        id: 'perfil_embarazo',
        titulo: 'Cuídate en el embarazo',
        mensaje: 'Recuerda hidratarte bien, descansar y evitar '
            'esfuerzos intensos. Consulta siempre a tu médico.',
        icono: Icons.favorite,
        prioridad: PrioridadRecomendacion.baja,
        categoria: CategoriaRecomendacion.perfil,
      ));
    }

    // ═══ REGLAS DE COMUNIDAD ═══
    if (itemsComunidad.isNotEmpty) {
      final sugerido = itemsComunidad.first;
      recomendaciones.add(Recomendacion(
        id: 'comunidad_sugerencia',
        titulo: 'Contenido de la comunidad',
        mensaje: 'Te puede interesar: "${sugerido.titulo}" '
            'por ${sugerido.autor}.',
        icono: Icons.people_outline,
        prioridad: PrioridadRecomendacion.baja,
        categoria: CategoriaRecomendacion.bienestar,
      ));
    }

    // Ordenar por prioridad (alta → media → baja)
    recomendaciones.sort((a, b) {
      return a.prioridad.index.compareTo(b.prioridad.index);
    });

    return recomendaciones;
  }
}

/// Estructura simple para combinar ejercicio + registro.
class EjercicioDatos {
  final bool completado;
  final String tipo;
  final int minutosObjetivo;

  const EjercicioDatos({
    required this.completado,
    required this.tipo,
    required this.minutosObjetivo,
  });
}
