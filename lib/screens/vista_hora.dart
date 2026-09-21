import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/evento.dart';
import '../models/ilustracion_evento.dart';
import '../providers/eventos_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/visibility_prefs.dart';
import '../widgets/add_event_dialog.dart';

class VistaHora extends StatefulWidget {
  const VistaHora({super.key});

  @override
  State<VistaHora> createState() => _VistaHoraState();
}

class _VistaHoraState extends State<VistaHora> {
  DateTime _fecha = DateTime.now();
  int? _expandida;
  bool _mostrarSuspendidos = true;
  Set<TipoEvento> _tiposVisibles = {};

  @override
  void initState() {
    super.initState();
    _cargarVisibilidad();
  }

  Future<void> _cargarVisibilidad() async {
    final tipos = await VisibilityPrefs.cargar();
    if (mounted) {
      setState(() {
        _tiposVisibles = tipos;
      });
    }
  }

  Future<void> _abrirSelectorTipos() async {
    final seleccion = await showDialog<Set<TipoEvento>>(
      context: context,
      builder: (ctx) => _DialogoTiposVisibles(
        tiposSeleccionados: _tiposVisibles,
      ),
    );
    if (seleccion != null) {
      setState(() => _tiposVisibles = seleccion);
      await VisibilityPrefs.guardar(seleccion);
    }
  }

  String _formatearFecha(DateTime d) {
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${d.day} de ${meses[d.month - 1]} de ${d.year}';
  }

  String _formatoHora(int h) {
    if (h == 0) return '12 AM';
    if (h == 12) return '12 PM';
    return h < 12 ? '$h AM' : '${h - 12} PM';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final eventosProv = context.watch<EventosProvider>();
    final fontFamily = themeProv.fontFamily;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hora'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            tooltip: 'Elegir tipos visibles',
            onPressed: _abrirSelectorTipos,
          ),
          IconButton(
            icon: Icon(
                _mostrarSuspendidos ? Icons.visibility : Icons.visibility_off),
            tooltip: _mostrarSuspendidos
                ? 'Ocultar suspendidos'
                : 'Mostrar suspendidos',
            onPressed: () {
              setState(() {
                _mostrarSuspendidos = !_mostrarSuspendidos;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Día anterior',
                  onPressed: () => setState(() {
                    _fecha = _fecha.subtract(const Duration(days: 1));
                    _expandida = null;
                  }),
                ),
                Expanded(
                  child: Text(
                    _formatearFecha(_fecha),
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Día siguiente',
                  onPressed: () => setState(() {
                    _fecha = _fecha.add(const Duration(days: 1));
                    _expandida = null;
                  }),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AM',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _construirGrilla(eventosProv, 0, 11, fontFamily),
                  const SizedBox(height: 16),
                  Text(
                    'PM',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _construirGrilla(eventosProv, 12, 23, fontFamily),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Añadir evento',
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AddEventDialog(fechaInicial: _fecha),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _construirGrilla(
    EventosProvider eventosProv,
    int inicio,
    int fin,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    final horas = List.generate(fin - inicio + 1, (i) => inicio + i);
    return Wrap(
      children: horas.map((hora) {
        final expandida = _expandida == hora;
        final eventosHora = eventosProv
            .eventosDeHora(_fecha, hora)
            .where((e) => _mostrarSuspendidos || !e.suspendido)
            .where((e) =>
                _tiposVisibles.isEmpty || _tiposVisibles.contains(e.tipo))
            .toList();
        final anchoTotal = MediaQuery.of(context).size.width - 16;
        final anchoCelda = expandida ? anchoTotal : (anchoTotal / 4) - 8;

        return Padding(
          padding: const EdgeInsets.all(2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: anchoCelda,
            decoration: BoxDecoration(
              color: expandida
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: expandida
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
              ),
              boxShadow: expandida
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Tooltip(
              message: eventosHora.isEmpty
                  ? 'Sin eventos'
                  : eventosHora.map((e) => e.titulo).join('\n'),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    setState(() {
                      _expandida = expandida ? null : hora;
                    });
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: expandida
                        ? _detalleExpandido(hora, eventosHora, fontFamily)
                        : AspectRatio(
                            key: ValueKey('colapsado_$hora'),
                            aspectRatio: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _formatoHora(hora),
                                    style: TextStyle(
                                      fontFamily: fontFamily,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // Emojis de eventos
                                  if (eventosHora.isNotEmpty)
                                    Wrap(
                                      spacing: 2,
                                      children: eventosHora.take(3).map((e) {
                                        final emoji =
                                            IlustracionesData.emojiPorId(
                                                e.ilustracion);
                                        return Text(
                                          emoji ?? '•',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                emoji == null ? e.color : null,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ...eventosHora.take(2).map(
                                        (e) => Text(
                                          e.titulo,
                                          style: TextStyle(
                                            fontFamily: fontFamily,
                                            fontSize: 8,
                                            decoration: e.suspendido
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: e.suspendido
                                                ? theme.colorScheme.onSurface
                                                    .withValues(alpha: 0.4)
                                                : null,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _detalleExpandido(
    int hora,
    List<Evento> eventos,
    String fontFamily,
  ) {
    return Padding(
      key: ValueKey('expandido_$hora'),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatoHora(hora),
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Cerrar',
                onPressed: () {
                  setState(() {
                    _expandida = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (eventos.isEmpty)
            Text('Sin eventos', style: TextStyle(fontFamily: fontFamily))
          else
            ...eventos.map((e) {
              final eventosProv = context.read<EventosProvider>();
              final emoji = IlustracionesData.emojiPorId(e.ilustracion);
              return ListTile(
                dense: true,
                leading: emoji != null
                    ? Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: e.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                      )
                    : Tooltip(
                        message: e.tipo.name.toUpperCase(),
                        child: CircleAvatar(
                          backgroundColor: e.color,
                          radius: 12,
                        ),
                      ),
                title: Text(
                  e.titulo,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 14,
                    decoration:
                        e.suspendido ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  '${e.horaInicio.format(context)} - ${e.horaFin.format(context)} · ${e.tipo.name.toUpperCase()}',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 12,
                  ),
                ),
                trailing: PopupMenuButton<String>(
                  tooltip: 'Opciones',
                  onSelected: (v) {
                    switch (v) {
                      case 'edit':
                        showDialog(
                          context: context,
                          builder: (_) => AddEventDialog(
                            fechaInicial: _fecha,
                            eventoExistente: e,
                          ),
                        );
                        break;
                      case 'delete':
                        eventosProv.eliminarEvento(e.id);
                        break;
                      case 'suspend':
                        eventosProv.suspenderEvento(e.id);
                        break;
                      case 'dup':
                        eventosProv.duplicarEvento(e);
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'edit', child: Text('Modificar')),
                    const PopupMenuItem(
                        value: 'delete', child: Text('Eliminar')),
                    PopupMenuItem(
                      value: 'suspend',
                      child: Text(e.suspendido ? 'Reactivar' : 'Suspender'),
                    ),
                    const PopupMenuItem(value: 'dup', child: Text('Duplicar')),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AddEventDialog(
                    fechaInicial: _fecha,
                    horaInicioPredefinida: TimeOfDay(hour: hora, minute: 0),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(
                'Añadir evento',
                style: TextStyle(fontFamily: fontFamily),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogoTiposVisibles extends StatefulWidget {
  final Set<TipoEvento> tiposSeleccionados;

  const _DialogoTiposVisibles({required this.tiposSeleccionados});

  @override
  State<_DialogoTiposVisibles> createState() => _DialogoTiposVisiblesState();
}

class _DialogoTiposVisiblesState extends State<_DialogoTiposVisibles> {
  late Set<TipoEvento> _seleccion;

  @override
  void initState() {
    super.initState();
    _seleccion = Set.from(widget.tiposSeleccionados);
  }

  @override
  Widget build(BuildContext context) {
    final checkboxes = TipoEvento.values.map((tipo) {
      return CheckboxListTile(
        title: Text(tipo.name.toUpperCase()),
        value: _seleccion.contains(tipo),
        onChanged: (checked) {
          setState(() {
            if (checked == true) {
              _seleccion.add(tipo);
            } else {
              _seleccion.remove(tipo);
            }
          });
        },
      );
    }).toList();

    return AlertDialog(
      title: const Text('Elegir tipos visibles'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: checkboxes,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _seleccion),
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}
