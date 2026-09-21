import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/comunidad_item.dart';
import '../../models/rutina.dart';
import '../../providers/comunidad_provider.dart';
import '../../providers/rutinas_provider.dart';
import '../../providers/sound_provider.dart';

class ComunidadDetallePage extends StatelessWidget {
  final ComunidadItem item;

  const ComunidadDetallePage({super.key, required this.item});

  Future<void> _importarComoRutina(BuildContext context) async {
    if (item.pasos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este item no tiene pasos para importar'),
        ),
      );
      return;
    }

    final rutinasProv = context.read<RutinasProvider>();
    final gruposReales = rutinasProv.gruposReales;

    if (gruposReales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Necesitas al menos un grupo de rutinas'),
        ),
      );
      return;
    }

    // Elegir grupo destino
    final grupoId = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Importar como rutina'),
        children: gruposReales
            .map(
              (g) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, g.id),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: g.color,
                      radius: 10,
                    ),
                    const SizedBox(width: 12),
                    Text(g.nombre),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );

    if (grupoId == null) return;

    // Crear una rutina con los pasos como subtítulo concatenado
    final horaActual = TimeOfDay.now();
    rutinasProv.agregarRutina(
      grupoId,
      item.titulo,
      horaActual,
      Theme.of(context).colorScheme.primary,
    );

    if (context.mounted) {
      context.read<SoundProvider>().reproducirClick();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rutina "${item.titulo}" importada'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prov = context.watch<ComunidadProvider>();
    final likesTotales = item.likes + (item.meGusta ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        actions: [
          if (!item.esSistema)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Eliminar',
              onPressed: () async {
                final confirmar = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('¿Eliminar aporte?'),
                    content: const Text(
                      'Esta acción no se puede deshacer.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                );

                if (confirmar == true) {
                  prov.eliminarItemUsuario(item.id);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Categoría + autor
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item.categoria.emoji} ${item.categoria.nombre}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const Spacer(),
              if (item.esSistema)
                Chip(
                  avatar: Icon(
                    Icons.verified,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  label: const Text('Sistema'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Título
          Text(
            item.titulo,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Autor
          Text(
            'Por ${item.autor}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Descripción
          Text(
            item.descripcion,
            style: theme.textTheme.bodyLarge,
          ),

          // Metadatos
          if (item.duracionMinutos > 0) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text('Duración: ${item.duracionMinutos} minutos'),
              ],
            ),
          ],
          if (item.dificultad.isNotEmpty && item.dificultad != 'media') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.speed,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text('Dificultad: ${item.dificultad}'),
              ],
            ),
          ],

          // Tags
          if (item.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: item.tags
                  .map(
                    (t) => Chip(
                      label: Text('#$t'),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],

          // Pasos
          if (item.pasos.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Pasos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...item.pasos.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${entry.key + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(entry.value),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 24),

          // Botones de acción
          if (item.esImportable && item.pasos.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () => _importarComoRutina(context),
              icon: const Icon(Icons.download),
              label: const Text('Importar como rutina'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              context.read<SoundProvider>().reproducirClick();
              prov.toggleLike(item.id);
            },
            icon: Icon(
              item.meGusta ? Icons.favorite : Icons.favorite_border,
              color: item.meGusta ? Colors.red : null,
            ),
            label: Text('$likesTotales me gusta'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
