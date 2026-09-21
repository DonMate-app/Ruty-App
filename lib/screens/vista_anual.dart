import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/eventos_provider.dart';
import '../providers/theme_provider.dart';

class VistaAnualWidget extends StatefulWidget {
  final int anioInicial;
  final void Function(int anio, int mes) onMesSeleccionado;
  final VoidCallback onCerrar;

  const VistaAnualWidget({
    super.key,
    required this.anioInicial,
    required this.onMesSeleccionado,
    required this.onCerrar,
  });

  @override
  State<VistaAnualWidget> createState() => _VistaAnualWidgetState();
}

class _VistaAnualWidgetState extends State<VistaAnualWidget> {
  static const int _baseYear = 2000;
  static const int _totalYears = 100;

  late final PageController _pageController;
  late int _currentPage;

  static const List<String> _meses = [
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

  @override
  void initState() {
    super.initState();
    _currentPage = widget.anioInicial - _baseYear;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _cambiarAnio(int delta) {
    final nuevo = _currentPage + delta;
    if (nuevo >= 0 && nuevo < _totalYears) {
      _pageController.animateToPage(
        nuevo,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Año anterior',
                onPressed: () => _cambiarAnio(-1),
              ),
              Expanded(
                child: Text(
                  'Año ${_baseYear + _currentPage}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Año siguiente',
                onPressed: () => _cambiarAnio(1),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Cerrar',
                onPressed: widget.onCerrar,
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _totalYears,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final anio = _baseYear + index;
              return _construirAnio(anio, fontFamily);
            },
          ),
        ),
      ],
    );
  }

  Widget _construirAnio(int anio, String fontFamily) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final mes = index + 1;
        return _MiniMes(
          anio: anio,
          mes: mes,
          nombreMes: _meses[index],
          fontFamily: fontFamily,
          onTap: () => widget.onMesSeleccionado(anio, mes),
        );
      },
    );
  }
}

class _MiniMes extends StatelessWidget {
  final int anio;
  final int mes;
  final String nombreMes;
  final String fontFamily;
  final VoidCallback onTap;

  const _MiniMes({
    required this.anio,
    required this.mes,
    required this.nombreMes,
    required this.fontFamily,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final eventosProv = context.watch<EventosProvider>();

    final ahora = DateTime.now();
    final esMesActual = ahora.year == anio && ahora.month == mes;

    final Map<int, int> conteoPorDia = {};
    final primerDia = DateTime(anio, mes, 1);
    final ultimoDia = DateTime(anio, mes + 1, 0).day;

    for (int dia = 1; dia <= ultimoDia; dia++) {
      final fecha = DateTime(anio, mes, dia);
      final eventos = eventosProv.eventosParaDia(fecha);
      if (eventos.isNotEmpty) {
        conteoPorDia[dia] = eventos.length;
      }
    }

    final primerDiaSemana = primerDia.weekday;

    final headerRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ['L', 'M', 'X', 'J', 'V', 'S', 'D'].map((d) {
        return SizedBox(
          width: 12,
          child: Text(
            d,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 8,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
    );

    final diasGrid = GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final diaDelMes = index - (primerDiaSemana - 1) + 1;
        if (diaDelMes < 1 || diaDelMes > ultimoDia) {
          return const SizedBox.shrink();
        }
        final tieneEventos = conteoPorDia.containsKey(diaDelMes);
        final cantidad = conteoPorDia[diaDelMes] ?? 0;

        double intensidad = 0.0;
        if (cantidad == 1) intensidad = 0.3;
        if (cantidad == 2) intensidad = 0.5;
        if (cantidad >= 3) intensidad = 0.8;

        return Container(
          margin: const EdgeInsets.all(0.5),
          decoration: BoxDecoration(
            color: tieneEventos
                ? colorScheme.primary.withValues(alpha: intensidad)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$diaDelMes',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 7,
                color: tieneEventos && intensidad > 0.5
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
              ),
            ),
          ),
        );
      },
    );

    final contenido = Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nombreMes,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 12,
              fontWeight: esMesActual ? FontWeight.bold : FontWeight.w500,
              color: esMesActual ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          headerRow,
          const SizedBox(height: 2),
          Expanded(child: diasGrid),
        ],
      ),
    );

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: esMesActual
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide(color: colorScheme.outlineVariant, width: 0.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: contenido,
      ),
    );
  }
}
