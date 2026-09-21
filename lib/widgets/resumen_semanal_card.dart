import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/resumen_semanal.dart';
import '../providers/theme_provider.dart';

class ResumenSemanalCard extends StatelessWidget {
  final ResumenSemanal resumen;
  final VoidCallback onCerrar;
  final VoidCallback? onVerDetalles;

  const ResumenSemanalCard({
    super.key,
    required this.resumen,
    required this.onCerrar,
    this.onVerDetalles,
  });

  String _formatFecha(DateTime d) {
    const meses = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${d.day} ${meses[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabecera ──
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen semanal',
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_formatFecha(resumen.inicioSemana)} - '
                        '${_formatFecha(resumen.finSemana)}',
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                  tooltip: 'Cerrar',
                  onPressed: onCerrar,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Mensaje motivacional ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                resumen.mensajeMotivacional,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // ── Grid de estadísticas ──
            _gridEstadisticas(context, fontFamily),
            const SizedBox(height: 12),

            // ── Adherencia medicación ──
            if (resumen.dosisEsperadas > 0) ...[
              Text(
                'Adherencia a medicación',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: resumen.adherenciaMedicacion,
                  minHeight: 8,
                  color: resumen.adherenciaMedicacion >= 0.8
                      ? Colors.green
                      : resumen.adherenciaMedicacion >= 0.5
                          ? Colors.orange
                          : theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${resumen.dosisTomadas} de ${resumen.dosisEsperadas} dosis '
                '(${(resumen.adherenciaMedicacion * 100).toInt()}%)',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ── Ejercicio ──
            if (resumen.diasConEjercicio > 0) ...[
              Text(
                'Ejercicio',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: resumen.cumplimientoEjercicio,
                  minHeight: 8,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${resumen.diasConEjercicio} de 7 días · '
                '${resumen.minutosEjercicio} minutos totales',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            // ── Botón opcional ──
            if (onVerDetalles != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onVerDetalles,
                  icon: const Icon(Icons.insights, size: 18),
                  label: const Text('Ver estadísticas completas'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _gridEstadisticas(BuildContext context, String fontFamily) {
    final theme = Theme.of(context);

    Widget tarjeta({
      required IconData icono,
      required String valor,
      required String etiqueta,
      required Color color,
    }) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              etiqueta,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.6,
      children: [
        tarjeta(
          icono: Icons.event_available,
          valor: '${resumen.eventosCompletados}',
          etiqueta: 'Eventos',
          color: Colors.indigo,
        ),
        tarjeta(
          icono: Icons.check_circle,
          valor: '${resumen.tareasCompletadas}',
          etiqueta: 'Tareas hechas',
          color: Colors.orange,
        ),
        tarjeta(
          icono: Icons.fitness_center,
          valor: '${resumen.diasConEjercicio}/7',
          etiqueta: 'Días ejercicio',
          color: Colors.green,
        ),
        tarjeta(
          icono: Icons.restaurant,
          valor: '${resumen.registrosAlimentacion}',
          etiqueta: 'Comidas',
          color: Colors.teal,
        ),
      ],
    );
  }
}
