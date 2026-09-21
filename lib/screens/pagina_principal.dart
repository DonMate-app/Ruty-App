import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/meta.dart';
import '../providers/avisos_provider.dart';
import '../providers/tareas_provider.dart';
import '../providers/eventos_provider.dart';
import '../providers/ejercicio_provider.dart';
import '../providers/medicacion_provider.dart';
import '../providers/alimentacion_provider.dart';
import '../providers/notas_provider.dart';
import '../providers/rutinas_provider.dart';
import '../providers/metas_provider.dart';
import '../services/metas_service.dart';
import '../widgets/aviso_banner.dart';
import '../widgets/celebracion_dialog.dart';
import 'vista_mes.dart';
import 'vista_hora.dart';
import 'mi_rutina_tab.dart';
import 'vista_salud.dart';
import 'vista_tareas.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  int _indice = 0;
  final _paginas = const [
    VistaMes(),
    VistaHora(),
    VistaTareas(),
    MiRutinaTab(),
    VistaSalud(),
  ];

  // ─── Escucha global de metas ──────────────────────────────
  MetasProvider? _metasProv;
  bool _mostrandoCelebracion = false;

  /// Providers cuyos cambios pueden afectar el progreso de las metas.
  final List<ChangeNotifier> _fuentesMetas = [];
  bool _recalculoPendiente = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _suscribirFuentes();
      _metasProv = context.read<MetasProvider>();
      _metasProv!.addListener(_onMetasChanged);
      _recalcularProgresos();
      _verificarCelebraciones();
    });
  }

  @override
  void dispose() {
    for (final p in _fuentesMetas) {
      p.removeListener(_onFuenteCambio);
    }
    _metasProv?.removeListener(_onMetasChanged);
    super.dispose();
  }

  // ─── Suscripción a providers que afectan metas ────────────

  void _suscribirFuentes() {
    final fuentes = <ChangeNotifier>[
      context.read<EventosProvider>(),
      context.read<TareasProvider>(),
      context.read<EjercicioProvider>(),
      context.read<MedicacionProvider>(),
      context.read<AlimentacionProvider>(),
      context.read<NotasProvider>(),
      context.read<RutinasProvider>(),
    ];
    _fuentesMetas.addAll(fuentes);
    for (final p in fuentes) {
      p.addListener(_onFuenteCambio);
    }
  }

  // ─── Recalcular metas cuando algún provider cambia ────────

  void _onFuenteCambio() {
    if (!mounted) return;
    if (_recalculoPendiente) return;
    _recalculoPendiente = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recalculoPendiente = false;
      if (mounted) _recalcularProgresos();
    });
  }

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

  // ─── Celebraciones ────────────────────────────────────────

  void _onMetasChanged() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _verificarCelebraciones();
    });
  }

  void _verificarCelebraciones() {
    if (!mounted || _mostrandoCelebracion) return;
    final prov = _metasProv;
    if (prov == null) return;
    if (prov.celebracionesPendientes.isEmpty) return;
    _mostrarSiguienteCelebracion();
  }

  Future<void> _mostrarSiguienteCelebracion() async {
    if (!mounted) return;
    final prov = _metasProv;
    if (prov == null) return;
    if (prov.celebracionesPendientes.isEmpty) return;

    _mostrandoCelebracion = true;
    final cel = prov.celebracionesPendientes.first;

    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Celebración',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => CelebracionDialog(celebracion: cel),
    );

    prov.consumirCelebracion();
    _mostrandoCelebracion = false;

    if (!mounted) return;
    if (prov.celebracionesPendientes.isNotEmpty) {
      _mostrarSiguienteCelebracion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tareasProv = context.watch<TareasProvider>();

    final destacadas =
        tareasProv.pendientes.where((t) => t.prioridad.name == 'alta').length;

    return AvisoBannerStack(
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: KeyedSubtree(
            key: ValueKey<int>(_indice),
            child: _paginas[_indice],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _indice,
          onDestinationSelected: (i) => setState(() => _indice = i),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Mes',
            ),
            const NavigationDestination(
              icon: Icon(Icons.view_day_outlined),
              selectedIcon: Icon(Icons.view_day),
              label: 'Hora',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: destacadas > 0,
                label: Text('$destacadas'),
                child: const Icon(Icons.checklist_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: destacadas > 0,
                label: Text('$destacadas'),
                child: const Icon(Icons.checklist),
              ),
              label: 'Tareas',
            ),
            const NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon: Icon(Icons.fitness_center),
              label: 'Rutina',
            ),
            const NavigationDestination(
              icon: Icon(Icons.health_and_safety_outlined),
              selectedIcon: Icon(Icons.health_and_safety),
              label: 'Salud',
            ),
          ],
        ),
      ),
    );
  }
}
