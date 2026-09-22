import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/estado_pro_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/precios_service.dart';
import '../../widgets/pro_dialog.dart';

class InfoProPage extends StatelessWidget {
  const InfoProPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final estado = context.watch<EstadoProProvider>();
    final fontFamily = themeProv.fontFamily;

    // Detectar región y precio
    final region = PreciosService.detectar();
    final precioTexto = region.etiquetaPrecio;

    return Scaffold(
      appBar: AppBar(title: const Text('Horario Pro')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Header ──
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium,
                size: 56,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Desbloquea todo el potencial',
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            estado.etiquetaEstado,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // ── Funciones incluidas ──
          _titulo(context, 'Funciones incluidas en Pro', fontFamily),
          _funcion(
            context,
            icono: Icons.insights,
            titulo: 'Estadísticas completas',
            descripcion: 'Gráficos de alimentación, ejercicio y medicación con '
                'análisis de tendencias.',
            fontFamily: fontFamily,
          ),
          _funcion(
            context,
            icono: Icons.lightbulb_outline,
            titulo: 'Recomendaciones inteligentes',
            descripcion:
                'Sugerencias personalizadas según tu perfil y actividad '
                'diaria.',
            fontFamily: fontFamily,
          ),
          _funcion(
            context,
            icono: Icons.emoji_emotions_outlined,
            titulo: 'Ilustraciones de eventos',
            descripcion: 'Más de 60 emojis organizados en 10 categorías para '
                'identificar tus eventos de un vistazo.',
            fontFamily: fontFamily,
          ),
          _funcion(
            context,
            icono: Icons.auto_awesome,
            titulo: 'Resumen semanal automático',
            descripcion: 'Análisis de tus logros de la semana pasada con '
                'estadísticas y motivación.',
            fontFamily: fontFamily,
          ),
          _funcion(
            context,
            icono: Icons.emoji_events,
            titulo: 'Metas y logros',
            descripcion:
                'Sistema de XP, insignias y niveles para gamificar tus '
                'hábitos saludables.',
            fontFamily: fontFamily,
          ),
          const SizedBox(height: 24),

          // ── Botones ──
          if (estado.esProCompleto) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Colors.green, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          estado.betaActivado
                              ? 'Modo beta activado'
                              : 'Pro activado',
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                        Text(
                          'Disfrutas de todas las funciones Pro',
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            if (estado.puedeIniciarTrial)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => mostrarDialogoTrial(context),
                  icon: const Icon(Icons.card_giftcard),
                  label: const Text(
                    'Probar Pro 14 días gratis',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: (estado.puedeIniciarTrial
                  ? OutlinedButton.icon
                  : FilledButton.icon)(
                onPressed: () => abrirPantallaActivacion(context),
                icon: const Icon(Icons.lock_open),
                label: const Text(
                  'Activar licencia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Precio regional + Comprar Pro ──
            _tarjetaPrecio(context, region, fontFamily),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _abrirCheckout(context, region),
                icon: const Icon(Icons.shopping_cart_outlined),
                label: Text(
                  'Comprar Pro — $precioTexto',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          Center(
            child: Text(
              'Pago único. Sin suscripciones.',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Tarjeta de precio regional
  // ──────────────────────────────────────────────────────────

  Widget _tarjetaPrecio(
    BuildContext context,
    RegionPrecio region,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_offer_outlined,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Precio para ${region.nombre}',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  region.etiquetaPrecio,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Abrir checkout de Lemon Squeezy
  // ──────────────────────────────────────────────────────────

  Future<void> _abrirCheckout(
    BuildContext context,
    RegionPrecio region,
  ) async {
    final url = PreciosService.urlCheckout(region);

    if (url == null) {
      // Aún no configurado — placeholder
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Próximamente: compra disponible para ${region.nombre} '
            '(${region.etiquetaPrecio})',
          ),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el enlace de compra'),
        ),
      );
    }
  }

  // ──────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────

  Widget _titulo(
    BuildContext context,
    String texto,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        texto,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _funcion(
    BuildContext context, {
    required IconData icono,
    required String titulo,
    required String descripcion,
    required String fontFamily,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: Colors.green, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  descripcion,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
