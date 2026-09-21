import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/estado_pro_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/activacion/activacion_page.dart';

// ═══════════════════════════════════════════════════════════════
// ProGuard - Pantalla completa (para Estadísticas)
// ═══════════════════════════════════════════════════════════════

class ProGuard extends StatelessWidget {
  final Widget child;
  final String nombreFuncion;
  final String descripcion;
  final IconData icono;
  final bool requiereStats;

  const ProGuard({
    super.key,
    required this.child,
    required this.nombreFuncion,
    required this.descripcion,
    required this.icono,
    this.requiereStats = false,
  });

  bool _tieneAcceso(EstadoProProvider estado) {
    if (requiereStats) return estado.tieneAccesoEstadisticas;
    return estado.tieneAccesoPro;
  }

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoProProvider>();

    if (estado.cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_tieneAcceso(estado)) {
      return child;
    }

    return _PantallaBloqueada(
      nombreFuncion: nombreFuncion,
      descripcion: descripcion,
      icono: icono,
      estado: estado,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ProGuardInline - Sección dentro de un ListView
// ═══════════════════════════════════════════════════════════════

class ProGuardInline extends StatelessWidget {
  final Widget child;
  final String nombreFuncion;
  final String descripcion;
  final IconData icono;
  final bool requiereStats;

  const ProGuardInline({
    super.key,
    required this.child,
    required this.nombreFuncion,
    required this.descripcion,
    required this.icono,
    this.requiereStats = false,
  });

  bool _tieneAcceso(EstadoProProvider estado) {
    if (requiereStats) return estado.tieneAccesoEstadisticas;
    return estado.tieneAccesoPro;
  }

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoProProvider>();

    if (estado.cargando) {
      return const Card(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_tieneAcceso(estado)) {
      return child;
    }

    return _CardBloqueada(
      nombreFuncion: nombreFuncion,
      descripcion: descripcion,
      icono: icono,
      estado: estado,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Pantalla completa bloqueada
// ═══════════════════════════════════════════════════════════════

class _PantallaBloqueada extends StatelessWidget {
  final String nombreFuncion;
  final String descripcion;
  final IconData icono;
  final EstadoProProvider estado;

  const _PantallaBloqueada({
    required this.nombreFuncion,
    required this.descripcion,
    required this.icono,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;

    return Scaffold(
      appBar: AppBar(title: Text(nombreFuncion)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icono,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                nombreFuncion,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                descripcion,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 15,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _BotonesPro(estado: estado, ancho: double.infinity),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Card bloqueada (inline)
// ═══════════════════════════════════════════════════════════════

class _CardBloqueada extends StatelessWidget {
  final String nombreFuncion;
  final String descripcion;
  final IconData icono;
  final EstadoProProvider estado;

  const _CardBloqueada({
    required this.nombreFuncion,
    required this.descripcion,
    required this.icono,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
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
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icono,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    nombreFuncion,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.lock_outline,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              descripcion,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _BotonesPro(estado: estado, ancho: null),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Botones comunes (Trial / Activar)
// ═══════════════════════════════════════════════════════════════

class _BotonesPro extends StatelessWidget {
  final EstadoProProvider estado;
  final double? ancho;

  const _BotonesPro({required this.estado, this.ancho});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;
    final puedeTrial = estado.puedeIniciarTrial;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (puedeTrial) ...[
          SizedBox(
            width: ancho,
            height: 48,
            child: FilledButton.icon(
              onPressed: () => _activarTrial(context),
              icon: const Icon(Icons.card_giftcard, size: 20),
              label: Text(
                'Probar Pro gratis 14 días',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          width: ancho,
          height: 48,
          child: (puedeTrial ? OutlinedButton.icon : FilledButton.icon)(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ActivacionPage(bloqueante: false),
                ),
              );
            },
            icon: const Icon(Icons.lock_open, size: 20),
            label: Text(
              'Activar licencia Pro',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (estado.trialProviderUsado && !puedeTrial) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tu período de prueba ya fue utilizado.',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 12,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _activarTrial(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Probar Pro gratis?'),
        content: const Text(
          'Tendrás acceso completo a las funciones Pro durante '
          '14 días.\n\n'
          'Las estadísticas se mantendrán activas por 30 días.\n\n'
          'Solo puedes activar esta prueba una vez por dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Empezar prueba'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    if (!context.mounted) return;

    final ok = await context.read<EstadoProProvider>().iniciarTrial();

    if (!context.mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '¡Prueba activada! Disfruta 14 días de Pro gratis.',
          ),
        ),
      );
    }
  }
}
