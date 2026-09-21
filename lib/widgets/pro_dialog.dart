import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/estado_pro_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/activacion/activacion_page.dart';

/// Muestra el diálogo de "Probar Pro 14 días".
/// Devuelve true si el usuario activó el trial.
Future<bool> mostrarDialogoTrial(BuildContext context) async {
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.card_giftcard, color: Colors.green),
          SizedBox(width: 8),
          Expanded(child: Text('Probar Pro 14 días gratis')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Obtendrás acceso completo a todas las funciones Pro '
              'durante 14 días, sin pagar nada.',
            ),
            const SizedBox(height: 16),
            _lineaPro('Estadísticas completas'),
            _lineaPro('Recomendaciones personalizadas'),
            _lineaPro('Ilustraciones de eventos'),
            _lineaPro('Resumen semanal'),
            _lineaPro('Y futuras funciones Pro'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Las estadísticas se mantendrán activas por 30 días '
                      'para que puedas ver su potencial completo.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Solo puedes activar esta prueba una vez por '
                      'dispositivo.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Más tarde'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(ctx, true),
          icon: const Icon(Icons.card_giftcard),
          label: const Text('Empezar prueba'),
        ),
      ],
    ),
  );

  if (confirmar != true) return false;
  if (!context.mounted) return false;

  final ok = await context.read<EstadoProProvider>().iniciarTrial();

  if (!context.mounted) return false;

  if (ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Prueba activada! Disfruta 14 días de Pro gratis.'),
      ),
    );
  }
  return ok;
}

/// Abre la pantalla de activación de licencia.
Future<void> abrirPantallaActivacion(
  BuildContext context, {
  bool bloqueante = false,
}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ActivacionPage(bloqueante: bloqueante),
    ),
  );
}

/// Muestra un menú con opciones para hacerse Pro.
Future<void> mostrarMenuPro(BuildContext context) async {
  final estado = context.read<EstadoProProvider>();
  final puedeTrial = estado.puedeIniciarTrial;

  final opcion = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: Theme.of(ctx).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Hazte Pro',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (puedeTrial)
            ListTile(
              leading: const Icon(Icons.card_giftcard, color: Colors.green),
              title: const Text('Probar Pro 14 días gratis'),
              subtitle: const Text('Sin pagar, sin compromiso'),
              onTap: () => Navigator.pop(ctx, 'trial'),
            ),
          ListTile(
            leading: const Icon(Icons.lock_open),
            title: const Text('Activar con código'),
            subtitle: const Text('Si ya tienes tu código de compra'),
            onTap: () => Navigator.pop(ctx, 'activar'),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined),
            title: const Text('Comprar Pro'),
            subtitle: const Text('Abre el navegador para comprar'),
            onTap: () => Navigator.pop(ctx, 'comprar'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  if (opcion == null) return;
  if (!context.mounted) return;

  switch (opcion) {
    case 'trial':
      await mostrarDialogoTrial(context);
      break;
    case 'activar':
      await abrirPantallaActivacion(context);
      break;
    case 'comprar':
      // Aquí irá la URL de Lemon Squeezy (Fase 17.4)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Próximamente: enlace de compra'),
        ),
      );
      break;
  }
}

Widget _lineaPro(String texto) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(texto)),
      ],
    ),
  );
}
