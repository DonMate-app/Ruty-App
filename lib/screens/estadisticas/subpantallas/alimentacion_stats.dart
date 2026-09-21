import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/alimento_registro.dart';
import '../../../providers/alimentacion_provider.dart';
import '../../../providers/theme_provider.dart';

class AlimentacionStats extends StatefulWidget {
  const AlimentacionStats({super.key});

  @override
  State<AlimentacionStats> createState() => _AlimentacionStatsState();
}

class _AlimentacionStatsState extends State<AlimentacionStats> {
  int _rangoDias = 7;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AlimentacionProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;
    final theme = Theme.of(context);

    final hoy = DateTime.now();
    final dias = List.generate(
      _rangoDias,
      (i) => hoy.subtract(Duration(days: _rangoDias - 1 - i)),
    );

    // Conteos por día
    final datosPorDia = <DateTime, Map<TipoAlimento, int>>{};
    for (final dia in dias) {
      final registros = prov.registrosDeDia(dia);
      final conteo = <TipoAlimento, int>{
        TipoAlimento.liquido: 0,
        TipoAlimento.solido: 0,
        TipoAlimento.plato: 0,
      };
      for (final r in registros) {
        conteo[r.tipo] = (conteo[r.tipo] ?? 0) + 1;
      }
      datosPorDia[dia] = conteo;
    }

    // Totales del período
    int totalLiquidos = 0;
    int totalSolidos = 0;
    int totalPlatos = 0;
    int totalRegistros = 0;
    for (final conteo in datosPorDia.values) {
      totalLiquidos += conteo[TipoAlimento.liquido] ?? 0;
      totalSolidos += conteo[TipoAlimento.solido] ?? 0;
      totalPlatos += conteo[TipoAlimento.plato] ?? 0;
    }
    totalRegistros = totalLiquidos + totalSolidos + totalPlatos;

    final promedioDiario =
        totalRegistros == 0 ? 0.0 : totalRegistros / _rangoDias;

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
                  'Total registros',
                  '$totalRegistros',
                  fontFamily,
                ),
                _fila(
                  context,
                  'Promedio diario',
                  promedioDiario.toStringAsFixed(1),
                  fontFamily,
                ),
                _fila(
                  context,
                  'Líquidos',
                  '$totalLiquidos',
                  fontFamily,
                ),
                _fila(
                  context,
                  'Sólidos',
                  '$totalSolidos',
                  fontFamily,
                ),
                _fila(
                  context,
                  'Platos',
                  '$totalPlatos',
                  fontFamily,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Gráfico de barras
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registros por día',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: _graficoBarras(
                    context,
                    datosPorDia,
                    fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Distribución por tipo
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distribución por tipo',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (totalRegistros == 0)
                  Text(
                    'Sin registros en este período',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  SizedBox(
                    height: 200,
                    child: Row(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: [
                                if (totalLiquidos > 0)
                                  _seccionPie(
                                    'Líquidos',
                                    totalLiquidos.toDouble(),
                                    Colors.blue,
                                    totalRegistros,
                                    fontFamily,
                                  ),
                                if (totalSolidos > 0)
                                  _seccionPie(
                                    'Sólidos',
                                    totalSolidos.toDouble(),
                                    Colors.orange,
                                    totalRegistros,
                                    fontFamily,
                                  ),
                                if (totalPlatos > 0)
                                  _seccionPie(
                                    'Platos',
                                    totalPlatos.toDouble(),
                                    Colors.green,
                                    totalRegistros,
                                    fontFamily,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _leyenda(
                              context,
                              'Líquidos',
                              Colors.blue,
                              fontFamily,
                            ),
                            const SizedBox(height: 8),
                            _leyenda(
                              context,
                              'Sólidos',
                              Colors.orange,
                              fontFamily,
                            ),
                            const SizedBox(height: 8),
                            _leyenda(
                              context,
                              'Platos',
                              Colors.green,
                              fontFamily,
                            ),
                          ],
                        ),
                      ],
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

  Widget _graficoBarras(
    BuildContext context,
    Map<DateTime, Map<TipoAlimento, int>> datos,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    final diasLista = datos.keys.toList();

    final grupos = <BarChartGroupData>[];
    for (int i = 0; i < diasLista.length; i++) {
      final dia = diasLista[i];
      final conteo = datos[dia]!;
      final liquidos = (conteo[TipoAlimento.liquido] ?? 0).toDouble();
      final solidos = (conteo[TipoAlimento.solido] ?? 0).toDouble();
      final platos = (conteo[TipoAlimento.plato] ?? 0).toDouble();

      // Si el rango es 30 días, mostramos barras apiladas de todos modos
      grupos.add(
        BarChartGroupData(
          x: i,
          barsSpace: 2,
          barRods: [
            BarChartRodData(
              toY: liquidos,
              color: Colors.blue,
              width: _rangoDias > 14 ? 3 : 6,
              borderRadius: BorderRadius.circular(2),
            ),
            BarChartRodData(
              toY: solidos,
              color: Colors.orange,
              width: _rangoDias > 14 ? 3 : 6,
              borderRadius: BorderRadius.circular(2),
            ),
            BarChartRodData(
              toY: platos,
              color: Colors.green,
              width: _rangoDias > 14 ? 3 : 6,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      );
    }

    final maxY = datos.values
        .map((c) =>
            (c[TipoAlimento.liquido] ?? 0) +
            (c[TipoAlimento.solido] ?? 0) +
            (c[TipoAlimento.plato] ?? 0))
        .fold<int>(0, (a, b) => a > b ? a : b)
        .toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 5 : maxY + 1,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
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
                final dia = diasLista[idx];
                // Mostrar solo días alternos si es rango largo
                if (_rangoDias > 14 && idx % 5 != 0) {
                  return const SizedBox.shrink();
                }
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

  PieChartSectionData _seccionPie(
    String titulo,
    double valor,
    Color color,
    int total,
    String fontFamily,
  ) {
    final porcentaje = (valor / total) * 100;
    return PieChartSectionData(
      color: color,
      value: valor,
      title: '${porcentaje.toInt()}%',
      radius: 50,
      titleStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _leyenda(
    BuildContext context,
    String texto,
    Color color,
    String fontFamily,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(texto, style: TextStyle(fontFamily: fontFamily, fontSize: 12)),
      ],
    );
  }
}
