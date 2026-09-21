import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/celebracion_meta.dart';
import '../providers/sound_provider.dart';
import '../providers/theme_provider.dart';

// ═══════════════════════════════════════════════════════════════
// DIÁLOGO DE CELEBRACIÓN
// ═══════════════════════════════════════════════════════════════

class CelebracionDialog extends StatefulWidget {
  final CelebracionMeta celebracion;

  const CelebracionDialog({super.key, required this.celebracion});

  @override
  State<CelebracionDialog> createState() => _CelebracionDialogState();
}

class _CelebracionDialogState extends State<CelebracionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;
  late List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _particles = _generarParticulas(48);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reproducirSonido();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // ─── Sonido según tipo de celebración ─────────────────────
  void _reproducirSonido() {
    try {
      final sound = context.read<SoundProvider>();
      switch (widget.celebracion.tipo) {
        case TipoCelebracion.metaCompletada:
          sound.reproducirMetaCompletada();
          break;
        case TipoCelebracion.insigniaDesbloqueada:
          sound.reproducirInsignia();
          break;
        case TipoCelebracion.subioNivel:
          sound.reproducirSubioNivel();
          break;
      }
    } catch (_) {
      // Silencioso: si no hay SoundProvider, la celebración sigue igual
    }
  }

  List<_ConfettiParticle> _generarParticulas(int cantidad) {
    final random = Random();
    final baseColor = widget.celebracion.color ?? Colors.amber;
    final colores = <Color>[
      baseColor,
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.pinkAccent,
      Colors.amber,
    ];

    return List.generate(cantidad, (_) {
      return _ConfettiParticle(
        startX: random.nextDouble(),
        startY: -0.1 - random.nextDouble() * 0.25,
        speed: 0.9 + random.nextDouble() * 0.7,
        size: 6 + random.nextDouble() * 8,
        rotationSpeed: 0.5 + random.nextDouble() * 1.8,
        phase: random.nextDouble() * 2 * pi,
        color: colores[random.nextInt(colores.length)],
        driftAmplitude: 18 + random.nextDouble() * 45,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cel = widget.celebracion;
    final color = cel.color ?? theme.colorScheme.primary;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // ── Confetti fullscreen ──
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (_, __) => CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _confettiController.value,
                  ),
                ),
              ),
            ),
          ),

          // ── Tarjeta central con pop-in ──
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: child,
              ),
              child: _tarjeta(context, cel, color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjeta(BuildContext context, CelebracionMeta cel, Color color) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji grande con fondo
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.30),
                  color.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              cel.emoji,
              style: const TextStyle(fontSize: 48),
            ),
          ),
          const SizedBox(height: 16),

          // Categoría del evento
          Text(
            _etiquetaPorTipo(cel.tipo),
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
              color: color,
            ),
          ),
          const SizedBox(height: 8),

          // Título
          Text(
            cel.titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Descripción
          Text(
            cel.descripcion,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          // Chip de XP (solo en metaCompletada)
          if (cel.valor != null &&
              cel.tipo == TipoCelebracion.metaCompletada) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                '+${cel.valor} XP',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.celebration, size: 20),
              label: Text(
                '¡Genial!',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _etiquetaPorTipo(TipoCelebracion tipo) {
    switch (tipo) {
      case TipoCelebracion.metaCompletada:
        return '¡META COMPLETADA!';
      case TipoCelebracion.insigniaDesbloqueada:
        return '¡NUEVA INSIGNIA!';
      case TipoCelebracion.subioNivel:
        return '¡SUBISTE DE NIVEL!';
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// CONFETTI CON CUSTOMPAINT
// ═══════════════════════════════════════════════════════════════

class _ConfettiParticle {
  final double startX; // 0..1
  final double startY; // relativo al alto
  final double speed; // cuánto baja durante el ciclo
  final double size;
  final double rotationSpeed;
  final double phase;
  final Color color;
  final double driftAmplitude;

  _ConfettiParticle({
    required this.startX,
    required this.startY,
    required this.speed,
    required this.size,
    required this.rotationSpeed,
    required this.phase,
    required this.color,
    required this.driftAmplitude,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress; // 0..1

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Posición vertical
      final y = (p.startY + progress * p.speed) * size.height;

      // Posición horizontal con vaivén
      final x = p.startX * size.width +
          sin(progress * 2 * pi * 1.5 + p.phase) * p.driftAmplitude;

      // Desvanecido progresivo
      final alpha = (1.0 - progress * 0.55).clamp(0.0, 1.0).toDouble();
      final paint = Paint()..color = p.color.withValues(alpha: alpha);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * p.rotationSpeed * 2 * pi);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.5,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress || old.particles != particles;
}
