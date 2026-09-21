import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/evento.dart';
import '../models/feriado.dart';
import '../models/ilustracion_evento.dart';
import '../providers/estado_pro_provider.dart';
import '../providers/eventos_provider.dart';
import '../providers/feriados_provider.dart';
import '../providers/licencia_provider.dart';
import '../providers/theme_provider.dart';
import '../services/trial_service.dart';
import '../utils/visibility_prefs.dart';
import '../widgets/add_event_dialog.dart';
import '../widgets/pro_dialog.dart';
import 'activacion/activacion_page.dart';
import 'vista_ajustes.dart';
import 'panel_control.dart';
import 'acerca_de.dart';
import 'vista_anual.dart';
import 'comunidad/comunidad_page.dart';
import 'estadisticas/estadisticas_page.dart';
import 'notas/notas_page.dart';
import 'ayuda/ayuda_page.dart';
import 'pro/info_pro_page.dart';
import 'metas/metas_page.dart';

class VistaMes extends StatefulWidget {
  const VistaMes({super.key});

  @override
  State<VistaMes> createState() => _VistaMesState();
}

class _VistaMesState extends State<VistaMes> {
  DateTime _diaSel = DateTime.now();
  CalendarFormat _formato = CalendarFormat.month;
  bool _mostrarSuspendidos = true;
  Set<TipoEvento> _tiposVisibles = {};
  bool _mostrandoAnual = false;
  String _versionApp = '...';

  @override
  void initState() {
    super.initState();
    _cargarVisibilidad();
    _cargarVersion();
  }

  Future<void> _cargarVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _versionApp = 'v${info.version}';
      });
    }
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

  void _abrirNuevoEvento() => showDialog(
        context: context,
        builder: (_) => AddEventDialog(fechaInicial: _diaSel),
      );

  void _toggleFormato() {
    setState(() {
      _formato = _formato == CalendarFormat.month
          ? CalendarFormat.week
          : CalendarFormat.month;
    });
  }

  void _periodoAnterior() {
    setState(() {
      if (_formato == CalendarFormat.month) {
        final nuevo = DateTime(_diaSel.year, _diaSel.month - 1, 1);
        final ultimo = DateTime(nuevo.year, nuevo.month + 1, 0).day;
        final dia = _diaSel.day > ultimo ? ultimo : _diaSel.day;
        _diaSel = DateTime(nuevo.year, nuevo.month, dia);
      } else {
        _diaSel = _diaSel.subtract(const Duration(days: 7));
      }
    });
  }

  void _periodoSiguiente() {
    setState(() {
      if (_formato == CalendarFormat.month) {
        final nuevo = DateTime(_diaSel.year, _diaSel.month + 1, 1);
        final ultimo = DateTime(nuevo.year, nuevo.month + 1, 0).day;
        final dia = _diaSel.day > ultimo ? ultimo : _diaSel.day;
        _diaSel = DateTime(nuevo.year, nuevo.month, dia);
      } else {
        _diaSel = _diaSel.add(const Duration(days: 7));
      }
    });
  }

  int _numeroSemanaISO(DateTime fecha) {
    final jueves = fecha.add(Duration(days: 3 - ((fecha.weekday + 6) % 7)));
    final primerJueves = DateTime(jueves.year, 1, 4);
    final ajuste = (primerJueves.weekday + 6) % 7;
    final primerJuevesAjustado =
        primerJueves.subtract(Duration(days: ajuste - 3));
    final diferencia = jueves.difference(primerJuevesAjustado).inDays;
    return (diferencia / 7).floor() + 1;
  }

  String _mesAnio(DateTime d) {
    const meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${meses[d.month - 1]} ${d.year}';
  }

  void _opcionesEvento(Evento e) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modificar'),
              onTap: () {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (_) => AddEventDialog(
                    fechaInicial: e.fecha,
                    eventoExistente: e,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Eliminar'),
              onTap: () {
                Navigator.pop(ctx);
                context.read<EventosProvider>().eliminarEvento(e.id);
              },
            ),
            ListTile(
              leading: Icon(e.suspendido ? Icons.play_arrow : Icons.pause),
              title: Text(e.suspendido ? 'Reactivar' : 'Suspender'),
              onTap: () {
                Navigator.pop(ctx);
                context.read<EventosProvider>().suspenderEvento(e.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicar'),
              onTap: () {
                Navigator.pop(ctx);
                context.read<EventosProvider>().duplicarEvento(e);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final eventosProv = context.watch<EventosProvider>();
    final feriadosProv = context.watch<FeriadosProvider>();
    final fontFamily = themeProv.fontFamily;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Abrir menú',
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text('Calendario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            tooltip: 'Filtros y tipos visibles',
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
      drawer: _drawer(context),
      body: _mostrandoAnual
          ? VistaAnualWidget(
              anioInicial: _diaSel.year,
              onMesSeleccionado: (anio, mes) {
                setState(() {
                  _diaSel = DateTime(anio, mes, 1);
                  _formato = CalendarFormat.month;
                  _mostrandoAnual = false;
                });
              },
              onCerrar: () => setState(() => _mostrandoAnual = false),
            )
          : _construirVistaMes(
              theme,
              themeProv,
              eventosProv,
              feriadosProv,
              fontFamily,
            ),
      floatingActionButton: _mostrandoAnual
          ? null
          : FloatingActionButton(
              tooltip: 'Añadir evento',
              onPressed: _abrirNuevoEvento,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _construirVistaMes(
    ThemeData theme,
    ThemeProvider themeProv,
    EventosProvider eventosProv,
    FeriadosProvider feriadosProv,
    String fontFamily,
  ) {
    final eventosDia = eventosProv
        .eventosParaDia(_diaSel)
        .where((e) => _mostrarSuspendidos || !e.suspendido)
        .where((e) => _tiposVisibles.isEmpty || _tiposVisibles.contains(e.tipo))
        .toList();

    final feriadosDia = feriadosProv.feriadosDeFecha(_diaSel);

    final listaEventos = eventosDia.isEmpty && feriadosDia.isEmpty
        ? const Center(
            key: ValueKey('sin_eventos'),
            child: Text('Sin eventos'),
          )
        : ListView.builder(
            key: ValueKey(
              'lista_eventos_${_diaSel.day}_${_diaSel.month}_${_diaSel.year}',
            ),
            itemCount: feriadosDia.length + eventosDia.length,
            itemBuilder: (_, i) {
              if (i < feriadosDia.length) {
                final f = feriadosDia[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: f.color(context).withValues(alpha: 0.2),
                    child: Icon(
                      f.icono,
                      color: f.color(context),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    f.nombre,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Feriado ${f.etiquetaTipo.toLowerCase()}',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: f.color(context),
                    ),
                  ),
                  enabled: false,
                );
              }
              final e = eventosDia[i - feriadosDia.length];
              final emoji = IlustracionesData.emojiPorId(e.ilustracion);

              return ListTile(
                leading: emoji != null
                    ? Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: e.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      )
                    : Tooltip(
                        message: e.tipo.name.toUpperCase(),
                        child: CircleAvatar(backgroundColor: e.color),
                      ),
                title: Text(
                  e.titulo,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    decoration:
                        e.suspendido ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  '${e.horaInicio.format(context)} - ${e.horaFin.format(context)} · ${e.tipo.name.toUpperCase()}${e.recurrencia != Recurrencia.ninguna ? ' · ↻' : ''}',
                  style: TextStyle(fontFamily: fontFamily),
                ),
                onTap: () => _opcionesEvento(e),
              );
            },
          );

    final semanaActual = _numeroSemanaISO(_diaSel);
    final headerPersonalizado = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: _formato == CalendarFormat.month
                ? 'Mes anterior'
                : 'Semana anterior',
            onPressed: _periodoAnterior,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _mostrandoAnual = true);
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _mesAnio(_diaSel),
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 20),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Semana $semanaActual',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: _formato == CalendarFormat.month
                ? 'Mes siguiente'
                : 'Semana siguiente',
            onPressed: _periodoSiguiente,
          ),
        ],
      ),
    );

    final botonFormato = Center(
      child: TextButton.icon(
        onPressed: _toggleFormato,
        icon: Icon(
          _formato == CalendarFormat.month
              ? Icons.view_week
              : Icons.calendar_view_month,
        ),
        label: Text(
          _formato == CalendarFormat.month ? 'Vista semanal' : 'Vista mensual',
          style: TextStyle(fontFamily: fontFamily),
        ),
      ),
    );

    return Column(
      children: [
        headerPersonalizado,
        TableCalendar(
          locale: 'es_ES',
          firstDay: DateTime.utc(2020),
          lastDay: DateTime.utc(2035),
          focusedDay: _diaSel,
          calendarFormat: _formato,
          headerVisible: false,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Mes',
            CalendarFormat.week: 'Semana',
          },
          selectedDayPredicate: (d) => isSameDay(d, _diaSel),
          onDaySelected: (sel, focused) => setState(() {
            _diaSel = sel;
          }),
          onPageChanged: (focused) {
            setState(() => _diaSel = focused);
          },
          eventLoader: (d) => eventosProv
              .eventosParaDia(d)
              .where((e) => _mostrarSuspendidos || !e.suspendido)
              .where((e) =>
                  _tiposVisibles.isEmpty || _tiposVisibles.contains(e.tipo))
              .toList(),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              return _buildDayWithFeriado(
                context,
                day,
                feriadosProv,
                theme,
                fontFamily,
              );
            },
            todayBuilder: (context, day, focusedDay) {
              return _buildDayWithFeriado(
                context,
                day,
                feriadosProv,
                theme,
                fontFamily,
                esHoy: true,
              );
            },
            selectedBuilder: (context, day, focusedDay) {
              return _buildDayWithFeriado(
                context,
                day,
                feriadosProv,
                theme,
                fontFamily,
                esSeleccionado: true,
              );
            },
            outsideBuilder: (context, day, focusedDay) {
              return Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              );
            },
            markerBuilder: (context, day, events) {
              final feriados = feriadosProv.feriadosDeFecha(day);
              final tieneFeriado = feriados.isNotEmpty;
              final tieneEventos = events.isNotEmpty;

              if (!tieneFeriado && !tieneEventos) {
                return const SizedBox.shrink();
              }

              return Positioned(
                bottom: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tieneFeriado)
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: feriados.first.color(context),
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (tieneEventos)
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          calendarStyle: CalendarStyle(
            defaultTextStyle: TextStyle(
              fontFamily: fontFamily,
              color: theme.colorScheme.onSurface,
            ),
            weekendTextStyle: TextStyle(
              fontFamily: fontFamily,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            outsideTextStyle: TextStyle(
              fontFamily: fontFamily,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            todayDecoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: theme.colorScheme.error,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 4),
        botonFormato,
        const Divider(height: 1),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: listaEventos,
          ),
        ),
      ],
    );
  }

  Widget _buildDayWithFeriado(
    BuildContext context,
    DateTime day,
    FeriadosProvider feriadosProv,
    ThemeData theme,
    String fontFamily, {
    bool esHoy = false,
    bool esSeleccionado = false,
  }) {
    final feriados = feriadosProv.feriadosDeFecha(day);
    final esFeriado = feriados.isNotEmpty;

    Color? fondo;
    Color colorTexto = theme.colorScheme.onSurface;

    if (esSeleccionado) {
      fondo = theme.colorScheme.primary;
      colorTexto = theme.colorScheme.onPrimary;
    } else if (esHoy) {
      fondo = theme.colorScheme.primary.withValues(alpha: 0.4);
    } else if (esFeriado) {
      fondo = feriados.first.color(context).withValues(alpha: 0.15);
      colorTexto = feriados.first.color(context);
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: fondo,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontFamily: fontFamily,
            color: colorTexto,
            fontWeight:
                esFeriado || esHoy || esSeleccionado ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }

  Widget _drawer(BuildContext context) {
    final theme = Theme.of(context);
    final estado = context.watch<EstadoProProvider>();

    final headerChild = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Ruty',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _versionApp,
          style: TextStyle(
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: headerChild,
          ),

          // ── Estado de licencia Pro ──
          _EstadoLicenciaDrawer(estado: estado),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Panel de Control'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PanelControlPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Comunidad'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ComunidadPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.insights),
            title: const Text('Estadísticas'),
            trailing: !estado.tieneAccesoEstadisticas
                ? Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  )
                : null,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EstadisticasPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('Metas y logros'),
            trailing: !estado.tieneAccesoPro
                ? Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  )
                : null,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MetasPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.psychology_outlined),
            title: const Text('Aclaración mental'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotasPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Ayuda'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AyudaPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium),
            title: const Text('Ruty Pro'),
            subtitle: Text(estado.etiquetaEstado),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InfoProPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Ajustes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VistaAjustesPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AcercaDePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Estado de licencia en el drawer
// ═══════════════════════════════════════════════════════════════

class _EstadoLicenciaDrawer extends StatelessWidget {
  final EstadoProProvider estado;

  const _EstadoLicenciaDrawer({required this.estado});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final proCompleto = estado.esProCompleto;
    final trial = estado.tieneAccesoProPorTrial;
    final stats = estado.tieneAccesoEstadisticas && !proCompleto && !trial;
    final puedeTrial = estado.puedeIniciarTrial;

    Color color;
    IconData icono;
    String titulo;
    String subtitulo;

    if (proCompleto) {
      color = Colors.green;
      icono = Icons.verified;
      titulo = estado.betaActivado ? 'Modo beta' : 'Pro activado';
      subtitulo = 'Todas las funciones desbloqueadas';
    } else if (trial) {
      color = Colors.purple;
      icono = Icons.card_giftcard;
      titulo = 'Trial Pro';
      subtitulo = estado.etiquetaEstado;
    } else if (stats) {
      color = Colors.blue;
      icono = Icons.insights;
      titulo = 'Estadísticas Pro';
      subtitulo = estado.etiquetaEstado;
    } else if (puedeTrial) {
      color = Colors.orange;
      icono = Icons.timer_outlined;
      titulo = 'Versión gratis';
      subtitulo = 'Prueba Pro gratis 14 días';
    } else {
      color = Colors.grey;
      icono = Icons.lock_outline;
      titulo = 'Versión gratis';
      subtitulo = 'Activa Pro para más funciones';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Material(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: proCompleto
              ? () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InfoProPage(),
                    ),
                  );
                }
              : () async {
                  Navigator.pop(context);
                  if (puedeTrial) {
                    await mostrarDialogoTrial(context);
                  } else {
                    await mostrarMenuPro(context);
                  }
                },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icono, color: color, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        subtitulo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!proCompleto)
                  Icon(
                    Icons.chevron_right,
                    color: color,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Diálogo de tipos visibles
// ═══════════════════════════════════════════════════════════════

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
