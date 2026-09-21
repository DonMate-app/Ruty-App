import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/ejercicio_provider.dart';
import '../../../providers/theme_provider.dart';

class EjercicioStats extends StatefulWidget {
  const EjercicioStats({super.key});

  @override
  State<EjercicioStats> createState() => _EjercicioStatsState();
}

class _EjercicioStatsState extends State<EjercicioStats> {
  int _rangoDias = 7;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<EjercicioProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;
    final theme = Theme.of(context);

    final hoy = DateTime.now();
    final dias = List.generate(
      _rangoDias,
      (i) => hoy.subtract(Duration(days: _rangoDias - 1 - i)),
    );

    // Completados por día
    final completadosPorDia = <DateTime, int>{};
    final minutosPorDia = <DateTime, int>{};
    for (final dia in dias) {
      final registros = prov.registrosDeDia(dia);
      final completados = registros.where((r) => r.completado).length;
      completadosPorDia[dia] = completados;

      int minutos = 0;
      for (final r in registros.where((r) => r.completado)) {
        final ej = prov.ejercicios.where((e) => e.id == r.ejercicioId).toList();
        if (ej.isNotEmpty) {
          minutos += ej.first.objetivoMinutos;
        }
      }
      minutosPorDia[dia] = minutos;
    }

    final totalCompletados =
        completadosPorDia.values.fold<int>(0, (a, b) => a + b);
    final totalMinutos = minutosPorDia.values.fold<int>(0, (a, b) => a + b);
    final totalPosibles = prov.ejercicios.length * _rangoDias;
    final porcentaje = totalPosibles == 0
        ? 0.0
        : (totalCompletados / totalPosibles).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Selector de rango
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 7, label: Text('7 días')),
            ButtonSegment(value: 14, label: Text('14 días')),
            ButtonSegment(value: 30, label: Text('30 días')),
          ],
          selected: {_rangoDias},
          onSelectionChanged: (set) => setState(() => _rangoDias = set.first),
        ),
        const SizedBox(height: 16),

        // Resumen
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen del período',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _fila(
                  context,
                  'Ejercicios definidos',
                  '${prov.ejercicios.length}',
                  fontFamily,
                ),
                _fila(
                  context,
                  'Completados',
                  '$totalCompletados',
                  fontFamily,
                ),
                _fila(
                  context,
                  'Minutos totales',
                  '$totalMinutos min',
                  fontFamily,
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: porcentaje,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(porcentaje * 100).toInt()}% de cumplimiento',
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
        const SizedBox(height: 16),

        // Gráfico de barras de minutos
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minutos de ejercicio por día',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: _graficoMinutos(
                    context,
                    minutosPorDia,
                    fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Gráfico de línea de cumplimiento
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ejercicios completados por día',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _graficoLinea(
                    context,
                    completadosPorDia,
                    fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _fila(
    BuildContext context,
    String etiqueta,
    String valor,
    String fontFamily,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: TextStyle(fontFamily: fontFamily)),
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

  Widget _graficoMinutos(
    BuildContext context,
    Map<DateTime, int> datos,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    final diasLista = datos.keys.toList();

    final grupos = <BarChartGroupData>[];
    for (int i = 0; i < diasLista.length; i++) {
      final minutos = datos[diasLista[i]]!.toDouble();
      grupos.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: minutos,
              color: Colors.green,
              width: _rangoDias > 14 ? 4 : 8,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      );
    }

    final maxY = datos.values.fold<int>(0, (a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 30 : maxY + 10,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.colorScheme.outlineVariant,
            strokeWidth: 0.5,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}m',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= diasLista.length) {
                  return const SizedBox.shrink();
                }
                if (_rangoDias > 14 && idx % 5 != 0) {
                  return const SizedBox.shrink();
                }
                final dia = diasLista[idx];
                return Text(
                  '${dia.day}/${dia.month}',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 9,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: grupos,
      ),
    );
  }

  Widget _graficoLinea(
    BuildContext context,
    Map<DateTime, int> datos,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    final diasLista = datos.keys.toList();
    final spots = <FlSpot>[];
    for (int i = 0; i < diasLista.length; i++) {
      spots.add(
        FlSpot(i.toDouble(), datos[diasLista[i]]!.toDouble()),
      );
    }

    final maxY = datos.values.fold<int>(0, (a, b) => a > b ? a : b).toDouble();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY == 0 ? 3 : maxY + 1,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.colorScheme.outlineVariant,
            strokeWidth: 0.5,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value % 1 != 0) return const SizedBox.shrink();
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= diasLista.length) {
                  return const SizedBox.shrink();
                }
                if (_rangoDias > 14 && idx % 5 != 0) {
                  return const SizedBox.shrink();
                }
                final dia = diasLista[idx];
                return Text(
                  '${dia.day}/${dia.month}',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 9,
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.teal,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: Colors.teal,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.teal.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}
