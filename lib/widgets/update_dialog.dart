import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/update_info.dart';
import '../providers/theme_provider.dart';

Future<void> mostrarDialogoActualizacion(
  BuildContext context,
  UpdateInfo info,
  int versionCodeActual,
) async {
  final esObligatoria = info.esObligatoriaPara(versionCodeActual);
  final theme = Theme.of(context);
  final themeProv = context.watch<ThemeProvider>();
  final fontFamily = themeProv.fontFamily;

  final resultado = await showDialog<String>(
    context: context,
    barrierDismissible: !esObligatoria,
    builder: (ctx) => PopScope(
      canPop: !esObligatoria,
      child: AlertDialog(
        icon: Icon(
          Icons.system_update,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        title: const Text(
          'Actualización disponible',
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.new_releases,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Versión ${info.version}',
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (info.cambios.isNotEmpty) ...[
                Text(
                  'Novedades:',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...info.cambios.map(
                  (c) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            c,
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (esObligatoria) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Esta actualización es obligatoria para seguir '
                          'usando la app.',
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 12,
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (!esObligatoria)
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'posponer'),
              child: const Text('Más tarde'),
            ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, 'descargar'),
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Descargar'),
          ),
        ],
      ),
    ),
  );

  if (resultado == 'descargar') {
    await _abrirNavegador(context, info.url);
  }
}

Future<void> _abrirNavegador(BuildContext context, String url) async {
  try {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el enlace de descarga'),
          ),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
