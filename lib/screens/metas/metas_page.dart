import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/meta.dart';
import '../../providers/alimentacion_provider.dart';
import '../../providers/ejercicio_provider.dart';
import '../../providers/eventos_provider.dart';
import '../../providers/medicacion_provider.dart';
import '../../providers/metas_provider.dart';
import '../../providers/notas_provider.dart';
import '../../providers/rutinas_provider.dart';
import '../../providers/tareas_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/metas_service.dart';
import '../../widgets/insignias_grid.dart';
import '../../widgets/meta_card.dart';
import '../../widgets/nivel_widget.dart';
import '../../widgets/pro_guard.dart';
import 'meta_nueva_page.dart';

class MetasPage extends StatefulWidget {
  /// Tab inicial: 0 = Activas, 1 = Completadas, 2 = Logros.
  final int initialTab;

  const MetasPage({super.key, this.initialTab = 0});

  @override
  State<MetasPage> createState() => _MetasPageState();
}

class _MetasPageState extends State<MetasPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recalcularProgresos();
    });
  }

  /// Recalcula el progreso de todas las metas automáticas.
  void _recalcularProgresos() {
    final metasProv = context.read<MetasProvider>();
    final eventosProv = context.read<EventosProvider>();
    final tareasProv = context.read<TareasProvider>();
    final ejercicioProv = context.read<EjercicioProvider>();
    final medicacionProv = context.read<MedicacionProvider>();
    final alimentacionProv = context.read<AlimentacionProvider>();
    final notasProv = context.read<NotasProvider>();
    final rutinasProv = context.read<RutinasProvider>();

    final minutosPorEjercicio = <String, int>{};
    for (final ej in ejercicioProv.ejercicios) {
      minutosPorEjercicio[ej.id] = ej.objetivoMinutos;
    }

    final progresos = <String, int>{};
    for (final meta in metasProv.metas) {
      if (meta.completada) continue;
      if (!meta.tipoProgreso.esCalculable) continue;

      progresos[meta.id] = MetasService.calcularProgreso(
        meta: meta,
        eventos: eventosProv.eventos,
        tareas: tareasProv.tareas,
        registrosEjercicio: ejercicioProv.registros,
        registrosMedicacion: medicacionProv.registros,
        registrosAlimentacion: alimentacionProv.registros,
        notas: notasProv.notasSinFiltrar,
        totalMedicamentos: medicacionProv.medicamentos.length,
        totalRutinasAplicadas: rutinasProv.contadorRutinasAplicadas,
        minutosPorEjercicioId: minutosPorEjercicio,
      );
    }

    metasProv.actualizarProgresos(progresos);
  }

  void _abrirNuevaMeta() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MetaNuevaPage(),
      ),
    ).then((_) => _recalcularProgresos());
  }

  void _opcionesMeta(Meta meta) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Detalles'),
              onTap: () {
                Navigator.pop(ctx);
                _mostrarDetalle(meta);
              },
            ),
            if (meta.tipoProgreso == TipoProgresoMeta.manual &&
                !meta.completada)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Marcar como completada'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<MetasProvider>().completarManual(meta.id);
                },
              ),
            if (meta.esPersonalizada)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar meta'),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmarEliminar(meta);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalle(Meta meta) {
    final theme = Theme.of(context);
    final fontFamily = context.read<ThemeProvider>().fontFamily;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Text(
              meta.emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                meta.titulo,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meta.descripcion,
                style: TextStyle(fontFamily: fontFamily),
              ),
              const SizedBox(height: 16),
              _fila('Dificultad', meta.dificultad.nombre, fontFamily, theme),
              _fila('Categoría', meta.categoria.nombre, fontFamily, theme),
              _fila(
                'Progreso',
                '${meta.progresoActual} de ${meta.objetivo}',
                fontFamily,
                theme,
              ),
              _fila(
                  'Recompensa', '+${meta.recompensaXP} XP', fontFamily, theme),
              if (meta.completada && meta.fechaCompletada != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Completada',
                          style: TextStyle(
                            fontFamily: fontFamily,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _fila(
    String etiqueta,
    String valor,
    String fontFamily,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            etiqueta,
            style: TextStyle(
              fontFamily: fontFamily,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(Meta meta) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar meta?'),
        content: Text('Se eliminará "${meta.titulo}" permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<MetasProvider>().eliminarMeta(meta.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MetasProvider>();

    return ProGuard(
      nombreFuncion: 'Metas y logros',
      descripcion:
          'Completa metas, gana XP, sube de nivel y desbloquea insignias. '
          'Convierte tus hábitos en un juego de progreso.',
      icono: Icons.emoji_events,
      child: DefaultTabController(
        length: 3,
        initialIndex: widget.initialTab.clamp(0, 2),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Metas'),
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.flag),
                  text: 'Activas',
                ),
                Tab(
                  icon: Icon(Icons.check_circle),
                  text: 'Completadas',
                ),
                Tab(
                  icon: Icon(Icons.emoji_events),
                  text: 'Logros',
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _tabActivas(prov),
              _tabCompletadas(prov),
              _tabLogros(prov),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _abrirNuevaMeta,
            icon: const Icon(Icons.add),
            label: const Text('Nueva meta'),
          ),
        ),
      ),
    );
  }

  Widget _tabActivas(MetasProvider prov) {
    final activas = prov.metasActivas;

    if (activas.isEmpty) {
      return _emptyState(
        icono: Icons.flag_outlined,
        titulo: 'Sin metas activas',
        mensaje: 'Crea una nueva meta personalizada o completa las existentes.',
      );
    }

    // Ordenar por dificultad
    activas.sort((a, b) {
      return a.dificultad.index.compareTo(b.dificultad.index);
    });

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: activas.length,
      itemBuilder: (_, i) {
        final meta = activas[i];
        return MetaCard(
          meta: meta,
          onTap: () => _opcionesMeta(meta),
          onEliminar:
              meta.esPersonalizada ? () => _confirmarEliminar(meta) : null,
        );
      },
    );
  }

  Widget _tabCompletadas(MetasProvider prov) {
    final completadas = prov.metasCompletadas;

    if (completadas.isEmpty) {
      return _emptyState(
        icono: Icons.emoji_events_outlined,
        titulo: 'Sin metas completadas',
        mensaje: 'Completa tus primeras metas para verlas aquí.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: completadas.length,
      itemBuilder: (_, i) {
        final meta = completadas[i];
        return MetaCard(
          meta: meta,
          onTap: () => _mostrarDetalle(meta),
        );
      },
    );
  }

  Widget _tabLogros(MetasProvider prov) {
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      children: [
        const NivelWidget(),
        const InsigniasGrid(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _emptyState({
    required IconData icono,
    required String titulo,
    required String mensaje,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
