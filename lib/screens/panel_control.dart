import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/alimento_registro.dart';
import '../models/comunidad_item.dart';
import '../models/evento.dart';
import '../models/medicamento.dart';
import '../models/recomendacion.dart';
import '../models/registro_ejercicio.dart';
import '../models/registro_medicacion.dart';
import '../models/resumen_semanal.dart';
import '../models/tarea.dart';
import '../providers/alimentacion_provider.dart';
import '../providers/comunidad_provider.dart';
import '../providers/ejercicio_provider.dart';
import '../providers/eventos_provider.dart';
import '../providers/medicacion_provider.dart';
import '../providers/perfil_provider.dart';
import '../providers/resumen_semanal_provider.dart';
import '../providers/rutinas_provider.dart';
import '../providers/tareas_provider.dart';
import '../services/recomendaciones_service.dart';
import '../services/resumen_semanal_service.dart';
import '../widgets/add_event_dialog.dart';
import '../widgets/add_tarea_dialog.dart';
import '../widgets/guia_dialogo.dart';
import '../widgets/pro_guard.dart';
import '../widgets/resumen_semanal_card.dart';
import 'estadisticas/estadisticas_page.dart';

class PanelControlPage extends StatefulWidget {
  const PanelControlPage({super.key});

  @override
  State<PanelControlPage> createState() => _PanelControlPageState();
}

class _PanelControlPageState extends State<PanelControlPage> {
  bool _mostrarResumen = false;
  ResumenSemanal? _resumen;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mostrarGuiaSiNecesario(context, 'panel_control');
      _verificarResumenSemanal();
    });
  }

  void _verificarResumenSemanal() {
    final resumenProv = context.read<ResumenSemanalProvider>();
    if (!resumenProv.debeMostrarResumen()) return;

    final resumen = _calcularResumen();
    if (resumen == null || !resumen.tieneDatos) {
      resumenProv.marcarSemanaMostrada();
      return;
    }

    setState(() {
      _resumen = resumen;
      _mostrarResumen = true;
    });
  }

  ResumenSemanal? _calcularResumen() {
    final eventosProv = context.read<EventosProvider>();
    final tareasProv = context.read<TareasProvider>();
    final ejercicioProv = context.read<EjercicioProvider>();
    final alimentacionProv = context.read<AlimentacionProvider>();
    final medicacionProv = context.read<MedicacionProvider>();

    final ahora = DateTime.now();
    final inicio = ResumenSemanalService.inicioSemanaPasada(ahora);
    final fin = ResumenSemanalService.finSemanaPasada(ahora);

    int totalAlimentacion = 0;
    for (int i = 0; i < 7; i++) {
      final dia = inicio.add(Duration(days: i));
      totalAlimentacion += alimentacionProv.registrosDeDia(dia).length;
    }

    final minutosPorEjercicio = <String, int>{};
    for (final ej in ejercicioProv.ejercicios) {
      minutosPorEjercicio[ej.id] = ej.objetivoMinutos;
    }

    return ResumenSemanalService().calcular(
      inicioSemana: inicio,
      finSemana: fin,
      eventos: eventosProv.eventos,
      tareas: tareasProv.tareas,
      registrosEjercicio: ejercicioProv.registros,
      minutosPorEjercicioId: minutosPorEjercicio,
      registrosAlimentacion: totalAlimentacion,
      registrosMedicacion: medicacionProv.registros,
      totalMedicamentos: medicacionProv.medicamentos.length,
    );
  }

  void _cerrarResumen() {
    context.read<ResumenSemanalProvider>().marcarSemanaMostrada();
    setState(() {
      _mostrarResumen = false;
      _resumen = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            tooltip: 'Ver estadísticas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EstadisticasPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          if (_mostrarResumen && _resumen != null)
            ProGuardInline(
              nombreFuncion: 'Resumen semanal',
              descripcion:
                  'Analiza tus logros de la semana pasada con estadísticas '
                  'detalladas y mensajes motivacionales personalizados.',
              icono: Icons.auto_awesome,
              child: ResumenSemanalCard(
                resumen: _resumen!,
                onCerrar: _cerrarResumen,
                onVerDetalles: () {
                  _cerrarResumen();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EstadisticasPage(),
                    ),
                  );
                },
              ),
            ),
          const _SeccionRecomendacionesProtegida(),
          const _SeccionExpandible(
            key: ValueKey('eventos'),
            icono: Icons.calendar_month,
            titulo: 'Eventos',
            color: Colors.indigo,
            contenido: _ContenidoEventos(),
          ),
          const _SeccionExpandible(
            key: ValueKey('tareas'),
            icono: Icons.checklist,
            titulo: 'Tareas',
            color: Colors.orange,
            contenido: _ContenidoTareas(),
          ),
          const _SeccionExpandible(
            key: ValueKey('rutinas'),
            icono: Icons.fitness_center,
            titulo: 'Rutinas',
            color: Colors.teal,
            contenido: _ContenidoRutinas(),
          ),
          const _SeccionExpandible(
            key: ValueKey('salud'),
            icono: Icons.health_and_safety,
            titulo: 'Salud',
            color: Colors.red,
            contenido: _ContenidoSalud(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Sección de Recomendaciones con ProGuardInline
// ═══════════════════════════════════════════════════════════════

class _SeccionRecomendacionesProtegida extends StatelessWidget {
  const _SeccionRecomendacionesProtegida();

  @override
  Widget build(BuildContext context) {
    return ProGuardInline(
      nombreFuncion: 'Recomendaciones inteligentes',
      descripcion: 'Recibe consejos personalizados según tu perfil de salud, '
          'alergias, condiciones y actividad diaria.',
      icono: Icons.lightbulb_outline,
      child: const _SeccionRecomendaciones(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Sección de Recomendaciones
// ═══════════════════════════════════════════════════════════════

class _SeccionRecomendaciones extends StatelessWidget {
  const _SeccionRecomendaciones();

  @override
  Widget build(BuildContext context) {
    final perfilProv = context.watch<PerfilProvider>();
    final eventosProv = context.watch<EventosProvider>();
    final tareasProv = context.watch<TareasProvider>();
    final alimentacionProv = context.watch<AlimentacionProvider>();
    final ejercicioProv = context.watch<EjercicioProvider>();
    final medicacionProv = context.watch<MedicacionProvider>();
    final comunidadProv = context.watch<ComunidadProvider>();

    final hoy = DateTime.now();
    final haceUnaSemana = hoy.subtract(const Duration(days: 7));

    final eventosHoy = eventosProv.eventosDelDia(hoy);

    final ejerciciosDatos = <EjercicioDatos>[];
    for (final ej in ejercicioProv.ejercicios) {
      final registro = ejercicioProv
          .registrosDeDia(hoy)
          .where((r) => r.ejercicioId == ej.id)
          .toList();
      ejerciciosDatos.add(EjercicioDatos(
        completado: registro.isNotEmpty && registro.first.completado,
        tipo: ej.tipo,
        minutosObjetivo: ej.objetivoMinutos,
      ));
    }

    final ejerciciosSemana = <EjercicioDatos>[];
    for (int i = 0; i < 7; i++) {
      final dia = haceUnaSemana.add(Duration(days: i));
      for (final ej in ejercicioProv.ejercicios) {
        final registro = ejercicioProv
            .registrosDeDia(dia)
            .where((r) => r.ejercicioId == ej.id)
            .toList();
        if (registro.isNotEmpty) {
          ejerciciosSemana.add(EjercicioDatos(
            completado: registro.first.completado,
            tipo: ej.tipo,
            minutosObjetivo: ej.objetivoMinutos,
          ));
        }
      }
    }

    final alimentacionSemana = <AlimentoRegistro>[];
    for (int i = 0; i < 7; i++) {
      final dia = haceUnaSemana.add(Duration(days: i));
      alimentacionSemana.addAll(alimentacionProv.registrosDeDia(dia));
    }

    final itemsComunidad = comunidadProv.itemsPopulares.take(3).toList();

    final recomendaciones = RecomendacionesService().generar(
      perfil: perfilProv.perfil,
      eventosHoy: eventosHoy,
      tareasPendientes: tareasProv.pendientes,
      alimentacionHoy: alimentacionProv.registrosDeDia(hoy),
      ejercicioHoy: ejerciciosDatos,
      medicacionHoy: medicacionProv.registrosDeDia(hoy),
      medicamentos: medicacionProv.medicamentos,
      itemsComunidad: itemsComunidad,
      alimentacionSemana: alimentacionSemana,
      ejercicioSemana: ejerciciosSemana,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recomendaciones',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${recomendaciones.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recomendaciones.isEmpty)
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '¡Todo en orden! Sin recomendaciones por ahora.',
                    ),
                  ),
                ],
              )
            else
              ...recomendaciones.map(
                (r) => _tarjetaRecomendacion(context, r),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaRecomendacion(
    BuildContext context,
    Recomendacion r,
  ) {
    final theme = Theme.of(context);
    final color = r.color(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(color: color, width: 4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(r.icono, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          r.etiquetaPrioridad,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        r.etiquetaCategoria,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.titulo,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    r.mensaje,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Sección expandible genérica
// ═══════════════════════════════════════════════════════════════

class _SeccionExpandible extends StatefulWidget {
  final IconData icono;
  final String titulo;
  final Color color;
  final Widget contenido;

  const _SeccionExpandible({
    super.key,
    required this.icono,
    required this.titulo,
    required this.color,
    required this.contenido,
  });

  @override
  State<_SeccionExpandible> createState() => _SeccionExpandibleState();
}

class _SeccionExpandibleState extends State<_SeccionExpandible> {
  bool _expandida = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expandida = !_expandida),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.icono,
                      color: widget.color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.titulo,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expandida ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: widget.contenido,
            secondChild: const SizedBox.shrink(),
            crossFadeState: _expandida
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Contenido: Eventos
// ═══════════════════════════════════════════════════════════════

class _ContenidoEventos extends StatelessWidget {
  const _ContenidoEventos();

  @override
  Widget build(BuildContext context) {
    final eventosProv = context.watch<EventosProvider>();
    final hoy = DateTime.now();
    final eventosHoy = eventosProv.eventosDelDia(hoy);
    final proximos = eventosProv.eventos
        .where((e) => e.fecha.isAfter(hoy) && !e.suspendido)
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    final eventosPorTipo = <TipoEvento, int>{};
    for (final e in eventosProv.eventos) {
      eventosPorTipo[e.tipo] = (eventosPorTipo[e.tipo] ?? 0) + 1;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _filaEstadistica(
            context,
            'Hoy',
            '${eventosHoy.length} evento(s)',
          ),
          _filaEstadistica(
            context,
            'Próximos',
            proximos.isEmpty
                ? 'Sin eventos futuros'
                : '${proximos.length} programado(s)',
          ),
          if (proximos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text(
                'Siguiente: ${proximos.first.titulo}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: eventosPorTipo.entries
                .map(
                  (e) => Chip(
                    label: Text(
                      '${e.key.name} (${e.value})',
                      style: const TextStyle(fontSize: 11),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddEventDialog(fechaInicial: hoy),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nuevo evento'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Contenido: Tareas
// ═══════════════════════════════════════════════════════════════

class _ContenidoTareas extends StatelessWidget {
  const _ContenidoTareas();

  @override
  Widget build(BuildContext context) {
    final tareasProv = context.watch<TareasProvider>();
    final pendientes = tareasProv.pendientes;
    final completadas = tareasProv.completadas;

    final porPrioridad = <PrioridadTarea, int>{};
    for (final t in pendientes) {
      porPrioridad[t.prioridad] = (porPrioridad[t.prioridad] ?? 0) + 1;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _filaEstadistica(
            context,
            'Pendientes',
            '${pendientes.length}',
          ),
          _filaEstadistica(
            context,
            'Completadas',
            '${completadas.length}',
          ),
          if (pendientes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: porPrioridad.entries
                  .map(
                    (e) => Chip(
                      label: Text(
                        '${e.key.name} (${e.value})',
                        style: const TextStyle(fontSize: 11),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AddTareaDialog(),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nueva tarea'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Contenido: Rutinas
// ═══════════════════════════════════════════════════════════════

class _ContenidoRutinas extends StatelessWidget {
  const _ContenidoRutinas();

  @override
  Widget build(BuildContext context) {
    final rutinasProv = context.watch<RutinasProvider>();
    final grupos = rutinasProv.grupos;
    final totalRutinas = rutinasProv.rutinas.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _filaEstadistica(
            context,
            'Grupos activos',
            '${grupos.length}',
          ),
          _filaEstadistica(
            context,
            'Rutinas registradas',
            '$totalRutinas',
          ),
          if (grupos.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: grupos
                  .map(
                    (g) => Chip(
                      avatar: CircleAvatar(
                        backgroundColor: g.color,
                        radius: 8,
                      ),
                      label: Text(
                        '${g.nombre} (${rutinasProv.rutinasDeGrupo(g.id).length})',
                        style: const TextStyle(fontSize: 11),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Contenido: Salud
// ═══════════════════════════════════════════════════════════════

class _ContenidoSalud extends StatelessWidget {
  const _ContenidoSalud();

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final alimentacion = context.watch<AlimentacionProvider>();
    final ejercicio = context.watch<EjercicioProvider>();
    final medicacion = context.watch<MedicacionProvider>();

    final registrosAlimentacionHoy = alimentacion.registrosDeDia(hoy).length;
    final registrosEjercicioHoy = ejercicio.registrosDeDia(hoy).length;

    final totalMedicamentos = medicacion.medicamentos.length;
    final tomadosHoy =
        medicacion.registrosDeDia(hoy).where((r) => r.tomado).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _filaEstadistica(
            context,
            'Alimentación hoy',
            '$registrosAlimentacionHoy registro(s)',
          ),
          _filaEstadistica(
            context,
            'Ejercicio hoy',
            '$registrosEjercicioHoy registro(s)',
          ),
          _filaEstadistica(
            context,
            'Medicación hoy',
            totalMedicamentos == 0
                ? 'Sin medicamentos'
                : '$tomadosHoy de $totalMedicamentos tomados',
          ),
          const SizedBox(height: 12),
          if (totalMedicamentos > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: totalMedicamentos == 0
                      ? 0
                      : tomadosHoy / totalMedicamentos,
                  minHeight: 8,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Helper: fila estadística
// ═══════════════════════════════════════════════════════════════

Widget _filaEstadistica(
  BuildContext context,
  String etiqueta,
  String valor,
) {
  final theme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          etiqueta,
          style: theme.textTheme.bodyMedium,
        ),
        Text(
          valor,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
