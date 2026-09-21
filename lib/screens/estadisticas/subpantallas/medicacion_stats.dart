import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/medicacion_provider.dart';
import '../../../providers/theme_provider.dart';

class MedicacionStats extends StatefulWidget {
  const MedicacionStats({super.key});

  @override
  State<MedicacionStats> createState() => _MedicacionStatsState();
}

class _MedicacionStatsState extends State<MedicacionStats> {
  int _rangoDias = 7;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MedicacionProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;
    final theme = Theme.of(context);

    final hoy = DateTime.now();
    final dias = List.generate(
      _rangoDias,
      (i) => hoy.subtract(Duration(days: _rangoDias - 1 - i)),
    );

    // Tomas por día
    final tomadosPorDia = <DateTime, int>{};
    for (final dia in dias) {
      final registros = prov.registrosDeDia(dia);
      tomadosPorDia[dia] = registros.where((r) => r.tomado).length;
    }

    final totalTomados = tomadosPorDia.values.fold<int>(0, (a, b) => a + b);
    final totalPosibles = prov.medicamentos.length * _rangoDias;
    final adherencia = totalPosibles == 0
        ? 0.0
        : (totalTomados / totalPosibles).clamp(0.0, 1.0);

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
                  'Medicamentos definidos',
                  '${prov.medicamentos.length}',
                  fontFamily,
                ),
                _fila(
                  context,
                  'Dosis tomadas',
                  '$totalTomados',
                  fontFamily,
                ),
                _fila(
                  context,
                  'Dosis esperadas',
                  '$totalPosibles',
                  fontFamily,
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: adherencia,
                    minHeight: 10,
                    color: adherencia >= 0.8
                        ? Colors.green
                        : adherencia >= 0.5
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(adherencia * 100).toInt()}% de adherencia',
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

        // Gráfico de barras
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dosis tomadas por día',
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
                    tomadosPorDia,
                    fontFamily,
                    prov.medicamentos.length,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Desglose por medicamento
        if (prov.medicamentos.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adherencia por medicamento',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...prov.medicamentos.map((med) {
                    int tomados = 0;
                    for (final dia in dias) {
                      tomados += prov
                          .registrosDeDia(dia)
                          .where((r) => r.medicamentoId == med.id && r.tomado)
                          .length;
                    }
                    final adherMed = _rangoDias == 0
                        ? 0.0
                        : (tomados / _rangoDias).clamp(0.0, 1.0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: med.color,
                                radius: 8,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  med.nombre,
                                  style: TextStyle(
                                    fontFamily: fontFamily,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                '$tomados / $_rangoDias',
                                style: TextStyle(
                                  fontFamily: fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: adherMed,
                              minHeight: 6,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              color: med.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
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
    Map<DateTime, int> datos,
    String fontFamily,
    int totalMeds,
  ) {
    final theme = Theme.of(context);
    final diasLista = datos.keys.toList();

    final grupos = <BarChartGroupData>[];
    for (int i = 0; i < diasLista.length; i++) {
      final tomados = datos[diasLista[i]]!.toDouble();
      final color = tomados >= totalMeds
          ? Colors.green
          : tomados > 0
              ? Colors.orange
              : Colors.red;
      grupos.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: tomados,
              color: color,
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
        maxY: maxY == 0 ? 3 : maxY + 1,
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
        barGroups: grupos,
      ),
    );
  }
}
