import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tarea.dart';
import '../providers/tareas_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/add_tarea_dialog.dart';

enum _FiltroTarea { todas, pendientes, completadas }

class VistaTareas extends StatefulWidget {
  const VistaTareas({super.key});

  @override
  State<VistaTareas> createState() => _VistaTareasState();
}

class _VistaTareasState extends State<VistaTareas> {
  _FiltroTarea _filtro = _FiltroTarea.pendientes;

  List<Tarea> _aplicarFiltro(TareasProvider prov) {
    switch (_filtro) {
      case _FiltroTarea.todas:
        return List.from(prov.tareas);
      case _FiltroTarea.pendientes:
        return prov.pendientes;
      case _FiltroTarea.completadas:
        return prov.completadas;
    }
  }

  List<Tarea> _tareasDestacadas(TareasProvider prov) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final manana = hoy.add(const Duration(days: 1));

    return prov.pendientes.where((t) {
      final esAlta = t.prioridad == PrioridadTarea.alta;
      final vencePronto = t.fechaLimite != null &&
          !t.fechaLimite!.isAfter(manana.add(const Duration(days: 1)));
      return esAlta || vencePronto;
    }).toList()
      ..sort((a, b) {
        final aVencida = a.fechaLimite != null && a.fechaLimite!.isBefore(hoy);
        final bVencida = b.fechaLimite != null && b.fechaLimite!.isBefore(hoy);
        if (aVencida != bVencida) return aVencida ? -1 : 1;
        if (a.prioridad != b.prioridad) {
          return b.prioridad.index.compareTo(a.prioridad.index);
        }
        if (a.fechaLimite != null && b.fechaLimite != null) {
          return a.fechaLimite!.compareTo(b.fechaLimite!);
        }
        return 0;
      });
  }

  void _abrirNuevaTarea() {
    showDialog(
      context: context,
      builder: (_) => const AddTareaDialog(),
    );
  }

  void _opcionesTarea(Tarea t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (t.descripcion.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.titulo,
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.descripcion,
                      style: Theme.of(ctx).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
            ],
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modificar'),
              onTap: () {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (_) => AddTareaDialog(tareaExistente: t),
                );
              },
            ),
            ListTile(
              leading: Icon(
                t.completada ? Icons.undo : Icons.check_circle_outline,
              ),
              title: Text(
                t.completada
                    ? 'Marcar como pendiente'
                    : 'Marcar como completada',
              ),
              onTap: () {
                Navigator.pop(ctx);
                context.read<TareasProvider>().toggleCompletada(t.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicar'),
              onTap: () {
                Navigator.pop(ctx);
                context.read<TareasProvider>().duplicarTarea(t);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Eliminar'),
              onTap: () {
                Navigator.pop(ctx);
                context.read<TareasProvider>().eliminarTarea(t.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _colorPrioridad(PrioridadTarea p, ColorScheme scheme) {
    switch (p) {
      case PrioridadTarea.alta:
        return scheme.error;
      case PrioridadTarea.media:
        return Colors.orange;
      case PrioridadTarea.baja:
        return Colors.green;
    }
  }

  String _etiquetaPrioridad(PrioridadTarea p) {
    switch (p) {
      case PrioridadTarea.alta:
        return 'ALTA';
      case PrioridadTarea.media:
        return 'MEDIA';
      case PrioridadTarea.baja:
        return 'BAJA';
    }
  }

  Widget _tileTarea(
    BuildContext context,
    Tarea t,
    String fontFamily, {
    bool destacada = false,
  }) {
    final theme = Theme.of(context);
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final manana = hoy.add(const Duration(days: 1));

    final vencida = t.fechaLimite != null && t.fechaLimite!.isBefore(hoy);
    final venceHoy = t.fechaLimite != null &&
        t.fechaLimite!.year == hoy.year &&
        t.fechaLimite!.month == hoy.month &&
        t.fechaLimite!.day == hoy.day;
    final venceManana = t.fechaLimite != null &&
        t.fechaLimite!.year == manana.year &&
        t.fechaLimite!.month == manana.month &&
        t.fechaLimite!.day == manana.day;

    final colorPrioridad = _colorPrioridad(t.prioridad, theme.colorScheme);

    Widget? badgeFecha;
    if (vencida) {
      badgeFecha = _badge(
        context,
        'VENCIDA',
        theme.colorScheme.error,
        theme.colorScheme.onError,
      );
    } else if (venceHoy) {
      badgeFecha = _badge(context, 'HOY', Colors.orange, Colors.white);
    } else if (venceManana) {
      badgeFecha = _badge(
        context,
        'MAÑANA',
        Colors.amber.shade700,
        Colors.white,
      );
    }

    return Card(
      elevation: destacada ? 2 : 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: destacada
              ? colorPrioridad.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant,
          width: destacada ? 1.5 : 0.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _opcionesTarea(t),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 56,
                decoration: BoxDecoration(
                  color: colorPrioridad,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Checkbox(
                value: t.completada,
                onChanged: (_) {
                  context.read<TareasProvider>().toggleCompletada(t.id);
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.titulo,
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontWeight:
                            destacada ? FontWeight.bold : FontWeight.w500,
                        decoration:
                            t.completada ? TextDecoration.lineThrough : null,
                        color: t.completada
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                            : null,
                      ),
                    ),
                    if (t.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        t.descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                          decoration:
                              t.completada ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          t.duracionFormateada,
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        _chipPrioridad(
                          context,
                          _etiquetaPrioridad(t.prioridad),
                          colorPrioridad,
                        ),
                        if (badgeFecha != null) badgeFecha,
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: t.color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipPrioridad(
    BuildContext context,
    String texto,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _badge(
    BuildContext context,
    String texto,
    Color fondo,
    Color textoColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textoColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final prov = context.watch<TareasProvider>();
    final fontFamily = themeProv.fontFamily;

    final tareas = _aplicarFiltro(prov);
    final destacadas = _tareasDestacadas(prov);
    final mostrarDestacadas =
        destacadas.isNotEmpty && _filtro != _FiltroTarea.completadas;

    final idsDestacadas = destacadas.map((t) => t.id).toSet();
    final tareasRestantes =
        tareas.where((t) => !idsDestacadas.contains(t.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
        actions: [
          PopupMenuButton<_FiltroTarea>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar',
            initialValue: _filtro,
            onSelected: (f) => setState(() => _filtro = f),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _FiltroTarea.todas,
                child: Text('Todas'),
              ),
              PopupMenuItem(
                value: _FiltroTarea.pendientes,
                child: Text('Pendientes'),
              ),
              PopupMenuItem(
                value: _FiltroTarea.completadas,
                child: Text('Completadas'),
              ),
            ],
          ),
        ],
      ),
      body: tareas.isEmpty
          ? const Center(child: Text('Sin tareas'))
          : ListView(
              children: [
                if (mostrarDestacadas) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Destacadas',
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${destacadas.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...destacadas.map(
                    (t) => _tileTarea(
                      context,
                      t,
                      fontFamily,
                      destacada: true,
                    ),
                  ),
                  if (tareasRestantes.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Text(
                        'Otras tareas',
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
                ...tareasRestantes.map(
                  (t) => _tileTarea(context, t, fontFamily),
                ),
                const SizedBox(height: 80),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nueva tarea',
        onPressed: _abrirNuevaTarea,
        child: const Icon(Icons.add),
      ),
    );
  }
}
