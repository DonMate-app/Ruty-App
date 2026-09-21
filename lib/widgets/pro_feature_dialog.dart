import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/estado_pro_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/activacion/activacion_page.dart';
import 'pro_dialog.dart';

/// Muestra un diálogo cuando el usuario intenta usar una función Pro.
/// Devuelve true si el usuario activó el trial, false en caso contrario.
Future<bool> mostrarDialogoFuncionPro(
  BuildContext context, {
  required String nombreFuncion,
  required String descripcion,
  required IconData icono,
}) async {
  final estado = context.read<EstadoProProvider>();
  final puedeTrial = estado.puedeIniciarTrial;

  final opcion = await showDialog<String>(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final themeProv = ctx.watch<ThemeProvider>();
      final fontFamily = themeProv.fontFamily;

      return AlertDialog(
        title: Row(
          children: [
            Icon(icono, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Función Pro'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombreFuncion,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              descripcion,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Activa Pro para usar esta función.',
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cerrar'),
            child: const Text('Cerrar'),
          ),
          if (puedeTrial)
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx, 'trial'),
              icon: const Icon(Icons.card_giftcard, size: 18),
              label: const Text('Probar 14 días'),
            ),
          if (!puedeTrial)
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx, 'activar'),
              icon: const Icon(Icons.lock_open, size: 18),
              label: const Text('Activar Pro'),
            ),
        ],
      );
    },
  );

  if (opcion == null || opcion == 'cerrar') return false;
  if (!context.mounted) return false;

  if (opcion == 'trial') {
    return await mostrarDialogoTrial(context);
  } else if (opcion == 'activar') {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ActivacionPage(bloqueante: false),
      ),
    );
    return true;
  }
  return false;
}
