import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/alimento_registro.dart';
import '../providers/alimentacion_provider.dart';
import '../providers/ejercicio_provider.dart';
import '../providers/medicacion_provider.dart';
import '../providers/theme_provider.dart';

class SaludResumenPage extends StatefulWidget {
  const SaludResumenPage({super.key});

  @override
  State<SaludResumenPage> createState() => _SaludResumenPageState();
}

class _SaludResumenPageState extends State<SaludResumenPage> {
  DateTime _mesActual = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de Salud'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Mes anterior',
            onPressed: () {
              setState(() {
                _mesActual = DateTime(_mesActual.year, _mesActual.month - 1);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Mes siguiente',
            onPressed: () {
              setState(() {
                _mesActual = DateTime(_mesActual.year, _mesActual.month + 1);
              });
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _nombreMes(_mesActual),
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(height: 1),

          // Alimentación
          const _SeccionResumen(
            titulo: 'Alimentación',
            icono: Icons.restaurant,
            color: Colors.orange,
            contenido: _ResumenAlimentacion(),
          ),

          // Ejercicio
          const _SeccionResumen(
            titulo: 'Ejercicio',
            icono: Icons.fitness_center,
            color: Colors.green,
            contenido: _ResumenEjercicio(),
          ),

          // Medicación
          const _SeccionResumen(
            titulo: 'Medicación',
            icono: Icons.medication,
            color: Colors.red,
            contenido: _ResumenMedicacion(),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _nombreMes(DateTime d) {
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
}

class _SeccionResumen extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Color color;
  final Widget contenido;

  const _SeccionResumen({
    required this.titulo,
    required this.icono,
    required this.color,
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icono, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  titulo,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            contenido,
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Resumen: Alimentación
// ═══════════════════════════════════════════════════════════════

class _ResumenAlimentacion extends StatelessWidget {
  const _ResumenAlimentacion();

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AlimentacionProvider>();
    final theme = Theme.of(context);

    final ahora = DateTime.now();
    final ultimoDia = DateTime(ahora.year, ahora.month + 1, 0).day;

    int totalLiquidos = 0;
    int totalSolidos = 0;
    int totalPlatos = 0;

    for (int dia = 1; dia <= ultimoDia; dia++) {
      final fecha = DateTime(ahora.year, ahora.month, dia);
      for (final r in prov.registrosDeDia(fecha)) {
        switch (r.tipo) {
          case TipoAlimento.liquido:
            totalLiquidos++;
            break;
          case TipoAlimento.solido:
            totalSolidos++;
            break;
          case TipoAlimento.plato:
            totalPlatos++;
            break;
        }
      }
    }

    final totalGeneral = totalLiquidos + totalSolidos + totalPlatos;

    if (totalGeneral == 0) {
      return Text(
        'Sin registros este mes',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      children: [
        _filaDato('Total registros', '$totalGeneral'),
        _filaDato('Líquidos', '$totalLiquidos'),
        _filaDato('Sólidos', '$totalSolidos'),
        _filaDato('Platos', '$totalPlatos'),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Resumen: Ejercicio
// ═══════════════════════════════════════════════════════════════

class _ResumenEjercicio extends StatelessWidget {
  const _ResumenEjercicio();

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<EjercicioProvider>();
    final theme = Theme.of(context);

    final ahora = DateTime.now();
    final ultimoDia = DateTime(ahora.year, ahora.month + 1, 0).day;

    int completados = 0;
    int totalPosibles = 0;

    for (int dia = 1; dia <= ultimoDia; dia++) {
      final fecha = DateTime(ahora.year, ahora.month, dia);
      final registros = prov.registrosDeDia(fecha);
      completados += registros.where((r) => r.completado).length;
      totalPosibles += prov.ejercicios.length;
    }

    if (prov.ejercicios.isEmpty) {
      return Text(
        'Sin ejercicios definidos',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final porcentaje = totalPosibles == 0
        ? 0.0
        : (completados / totalPosibles).clamp(0.0, 1.0);

    return Column(
      children: [
        _filaDato('Ejercicios definidos', '${prov.ejercicios.length}'),
        _filaDato('Completados este mes', '$completados'),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: porcentaje,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(porcentaje * 100).toInt()}% de cumplimiento',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Resumen: Medicación
// ═══════════════════════════════════════════════════════════════

class _ResumenMedicacion extends StatelessWidget {
  const _ResumenMedicacion();

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MedicacionProvider>();
    final theme = Theme.of(context);

    if (prov.medicamentos.isEmpty) {
      return Text(
        'Sin medicamentos definidos',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final ahora = DateTime.now();
    final ultimoDia = DateTime(ahora.year, ahora.month + 1, 0).day;

    int tomados = 0;
    int totalPosibles = 0;

    for (int dia = 1; dia <= ultimoDia; dia++) {
      final fecha = DateTime(ahora.year, ahora.month, dia);
      final registros = prov.registrosDeDia(fecha);
      tomados += registros.where((r) => r.tomado).length;
      totalPosibles += prov.medicamentos.length;
    }

    final porcentaje =
        totalPosibles == 0 ? 0.0 : (tomados / totalPosibles).clamp(0.0, 1.0);

    return Column(
      children: [
        _filaDato('Medicamentos definidos', '${prov.medicamentos.length}'),
        _filaDato('Dosis tomadas este mes', '$tomados'),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: porcentaje,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(porcentaje * 100).toInt()}% de adherencia',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Helper
// ═══════════════════════════════════════════════════════════════

Widget _filaDato(String etiqueta, String valor) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(etiqueta),
        Text(
          valor,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
