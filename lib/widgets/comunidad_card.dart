import 'package:flutter/material.dart';

import '../models/comunidad_item.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ComunidadCard extends StatelessWidget {
  final ComunidadItem item;
  final VoidCallback onTap;
  final VoidCallback onLike;

  const ComunidadCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;
    final likesTotales = item.likes + (item.meGusta ? 1 : 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado: categoría + autor
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.categoria.emoji} ${item.categoria.nombre}',
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (item.esSistema)
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  const Spacer(),
                  Text(
                    item.autor,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Título
              Text(
                item.titulo,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              // Descripción
              Text(
                item.descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              // Metadatos
              if (item.duracionMinutos > 0 || item.dificultad.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (item.duracionMinutos > 0) ...[
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.duracionMinutos} min',
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (item.esImportable) ...[
                      Icon(
                        Icons.download_outlined,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Importable',
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              // Likes
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    onPressed: onLike,
                    icon: Icon(
                      item.meGusta ? Icons.favorite : Icons.favorite_border,
                      color: item.meGusta
                          ? Colors.red
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    tooltip: 'Me gusta',
                  ),
                  Text(
                    '$likesTotales',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Ver más',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: theme.colorScheme.primary,
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
