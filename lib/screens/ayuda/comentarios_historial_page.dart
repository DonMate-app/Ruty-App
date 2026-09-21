import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/comentario_usuario.dart';
import '../../providers/comentarios_provider.dart';
import '../../providers/theme_provider.dart';

class ComentariosHistorialPage extends StatelessWidget {
  const ComentariosHistorialPage({super.key});

  IconData _iconoTipo(TipoComentario t) {
    switch (t) {
      case TipoComentario.sugerencia:
        return Icons.lightbulb_outline;
      case TipoComentario.error:
        return Icons.bug_report_outlined;
      case TipoComentario.felicitacion:
        return Icons.favorite_outline;
      case TipoComentario.otro:
        return Icons.chat_bubble_outline;
    }
  }

  Color _colorTipo(TipoComentario t, ColorScheme scheme) {
    switch (t) {
      case TipoComentario.sugerencia:
        return Colors.amber.shade700;
      case TipoComentario.error:
        return scheme.error;
      case TipoComentario.felicitacion:
        return Colors.pink;
      case TipoComentario.otro:
        return scheme.primary;
    }
  }

  String _formatearFecha(DateTime fecha) {
    final meses = [
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
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year} · '
        '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final prov = context.watch<ComentariosProvider>();
    final fontFamily = themeProv.fontFamily;
    final comentarios = prov.comentarios;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis comentarios'),
        actions: [
          if (!prov.estaVacio)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Limpiar todo',
              onPressed: () => _confirmarLimpiar(context),
            ),
        ],
      ),
      body: prov.estaVacio
          ? _emptyState(context, fontFamily)
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: comentarios.length,
              itemBuilder: (_, i) =>
                  _tarjeta(context, comentarios[i], fontFamily),
            ),
    );
  }

  Widget _emptyState(BuildContext context, String fontFamily) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin comentarios aún',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando envíes un comentario aparecerá aquí.',
              style: TextStyle(
                fontFamily: fontFamily,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjeta(
    BuildContext context,
    ComentarioUsuario c,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    final color = _colorTipo(c.tipo, theme.colorScheme);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_iconoTipo(c.tipo), color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.etiquetaTipo,
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatearFecha(c.fecha),
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  iconSize: 20,
                  tooltip: 'Eliminar',
                  onPressed: () {
                    context
                        .read<ComentariosProvider>()
                        .eliminarComentario(c.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              c.mensaje,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            if (c.contacto.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    c.contacto,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            Text(
              'Versión: ${c.versionApp}',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 10,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarLimpiar(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Limpiar historial?'),
        content: const Text(
          'Se eliminarán todos los comentarios guardados localmente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ComentariosProvider>().limpiarTodo();
              Navigator.pop(ctx);
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}
