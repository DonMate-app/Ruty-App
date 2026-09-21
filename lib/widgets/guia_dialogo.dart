import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/guia_contenido.dart';
import '../providers/guias_provider.dart';
import '../providers/theme_provider.dart';

/// Muestra la guía indicada la primera vez que el usuario entra a una
/// pantalla. Si ya la ha visto, no hace nada.
Future<void> mostrarGuiaSiNecesario(
  BuildContext context,
  String id,
) async {
  final prov = context.read<GuiasProvider>();
  if (prov.haVisto(id)) return;

  final guia = GuiasContenido.obtener(id);
  if (guia == null) return;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _GuiaDialogo(
      guia: guia,
      onCerrar: () {
        prov.marcarVista(id);
        Navigator.pop(ctx);
      },
    ),
  );
}

class _GuiaDialogo extends StatelessWidget {
  final GuiaContenido guia;
  final VoidCallback onCerrar;

  const _GuiaDialogo({
    required this.guia,
    required this.onCerrar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              decoration: BoxDecoration(
                color: guia.color.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: guia.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      guia.icono,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    guia.titulo,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    guia.subtitulo,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: guia.pasos.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final paso = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: idx < guia.pasos.length - 1 ? 16 : 0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: guia.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            paso.icono,
                            color: guia.color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                paso.titulo,
                                style: TextStyle(
                                  fontFamily: fontFamily,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                paso.descripcion,
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
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: guia.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onCerrar,
                  child: Text(
                    '¡Entendido!',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
