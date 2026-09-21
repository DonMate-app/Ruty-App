import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/insignia.dart';
import '../providers/metas_provider.dart';
import '../providers/theme_provider.dart';

class InsigniasGrid extends StatelessWidget {
  const InsigniasGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final metas = context.watch<MetasProvider>();
    final fontFamily = themeProv.fontFamily;
    final insignias = metas.insignias;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.military_tech,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Insignias',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${metas.insigniasObtenidas.length}/${insignias.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: insignias.length,
              itemBuilder: (_, i) =>
                  _tarjetaInsignia(context, insignias[i], fontFamily),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaInsignia(
    BuildContext context,
    Insignia insignia,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    final obtenida = insignia.obtenida;

    return GestureDetector(
      onTap: () => _mostrarDetalle(context, insignia, fontFamily),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: obtenida
                  ? insignia.color.withValues(alpha: 0.2)
                  : theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(
                color: obtenida
                    ? insignia.color
                    : theme.colorScheme.outlineVariant,
                width: obtenida ? 2 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: obtenida
                ? Text(
                    insignia.emoji,
                    style: const TextStyle(fontSize: 26),
                  )
                : Icon(
                    Icons.lock_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            insignia.nombre,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 9,
              fontWeight: obtenida ? FontWeight.bold : FontWeight.normal,
              color: obtenida
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _mostrarDetalle(
    BuildContext context,
    Insignia insignia,
    String fontFamily,
  ) {
    final obtenida = insignia.obtenida;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Text(
              insignia.emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                insignia.nombre,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              insignia.descripcion,
              style: TextStyle(fontFamily: fontFamily),
            ),
            if (obtenida && insignia.fechaObtenida != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: insignia.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: insignia.color,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Obtenida el ${_formatearFecha(insignia.fechaObtenida!)}',
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 12,
                          color: insignia.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Aún no desbloqueada',
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
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
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }
}
