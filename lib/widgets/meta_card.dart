import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/meta.dart';
import '../providers/theme_provider.dart';

class MetaCard extends StatelessWidget {
  final Meta meta;
  final VoidCallback? onTap;
  final VoidCallback? onEliminar;

  const MetaCard({
    super.key,
    required this.meta,
    this.onTap,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    // Pop-in suave al aparecer por primera vez (o al cambiar de estado).
    return TweenAnimationBuilder<double>(
      key: ValueKey('${meta.id}_${meta.completada}'),
      tween: Tween(begin: 0.94, end: 1.0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: child,
      ),
      child: _card(context),
    );
  }

  Widget _card(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;
    final colorDificultad = meta.dificultad.color;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: meta.completada
              ? Colors.green.withValues(alpha: 0.4)
              : colorDificultad.withValues(alpha: 0.3),
          width: meta.completada ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Encabezado ──
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorDificultad.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      meta.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meta.titulo,
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            decoration: meta.completada
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              meta.dificultad.icono,
                              size: 12,
                              color: colorDificultad,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              meta.dificultad.nombre,
                              style: TextStyle(
                                fontFamily: fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorDificultad,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+${meta.recompensaXP} XP',
                              style: TextStyle(
                                fontFamily: fontFamily,
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (meta.completada)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 28,
                    )
                  else if (onEliminar != null)
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onEliminar,
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Descripción ──
              Text(
                meta.descripcion,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              // ── Progreso ──
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: meta.porcentajeProgreso,
                        minHeight: 8,
                        color: meta.completada ? Colors.green : colorDificultad,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${meta.progresoActual}/${meta.objetivo}',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: meta.completada ? Colors.green : colorDificultad,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
