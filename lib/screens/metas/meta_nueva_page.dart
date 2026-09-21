import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/meta.dart';
import '../../providers/metas_provider.dart';
import '../../providers/theme_provider.dart';

class MetaNuevaPage extends StatefulWidget {
  const MetaNuevaPage({super.key});

  @override
  State<MetaNuevaPage> createState() => _MetaNuevaPageState();
}

class _MetaNuevaPageState extends State<MetaNuevaPage> {
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _objetivoCtrl = TextEditingController(text: '7');

  DificultadMeta _dificultad = DificultadMeta.facil;
  CategoriaMeta _categoria = CategoriaMeta.salud;
  TipoProgresoMeta _tipoProgreso = TipoProgresoMeta.diasConsecutivos;
  FiltroMeta _filtro = FiltroMeta.agua;
  String _emoji = '🎯';

  final List<String> _emojisDisponibles = [
    '🎯',
    '💧',
    '🏃',
    '🥗',
    '💊',
    '📝',
    '📅',
    '✅',
    '🔥',
    '⭐',
    '🏆',
    '🧠',
    '💪',
    '🌊',
    '🍽️',
    '🚀',
  ];

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _objetivoCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_tituloCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un título')),
      );
      return;
    }

    final objetivo = int.tryParse(_objetivoCtrl.text.trim()) ?? 1;
    if (objetivo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El objetivo debe ser mayor a 0')),
      );
      return;
    }

    context.read<MetasProvider>().crearMetaPersonalizada(
          titulo: _tituloCtrl.text.trim(),
          descripcion: _descCtrl.text.trim(),
          dificultad: _dificultad,
          categoria: _categoria,
          tipoProgreso: _tipoProgreso,
          filtro: _filtro,
          objetivo: objetivo,
          emoji: _emoji,
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva meta'),
        actions: [
          TextButton(
            onPressed: _guardar,
            child: const Text('Guardar'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Emoji ──
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _emoji,
                style: const TextStyle(fontSize: 42),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Elige un emoji',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _emojisDisponibles
                .map(
                  (e) => GestureDetector(
                    onTap: () => setState(() => _emoji = e),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _emoji == e
                            ? theme.colorScheme.primary.withValues(alpha: 0.2)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                        border: _emoji == e
                            ? Border.all(
                                color: theme.colorScheme.primary,
                                width: 2,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        e,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),

          // ── Título ──
          TextField(
            controller: _tituloCtrl,
            decoration: const InputDecoration(
              labelText: 'Título',
              hintText: 'Ej: 7 días de ejercicio',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // ── Descripción ──
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              hintText: '¿Qué quieres lograr?',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),

          // ── Dificultad ──
          DropdownButtonFormField<DificultadMeta>(
            initialValue: _dificultad,
            decoration: const InputDecoration(
              labelText: 'Dificultad',
              border: OutlineInputBorder(),
            ),
            items: DificultadMeta.values.map((d) {
              return DropdownMenuItem(
                value: d,
                child: Row(
                  children: [
                    Icon(d.icono, color: d.color, size: 18),
                    const SizedBox(width: 8),
                    Text('${d.nombre} (+${d.recompensaXP} XP)'),
                  ],
                ),
              );
            }).toList(),
            onChanged: (d) {
              if (d != null) setState(() => _dificultad = d);
            },
          ),
          const SizedBox(height: 12),

          // ── Categoría ──
          DropdownButtonFormField<CategoriaMeta>(
            initialValue: _categoria,
            decoration: const InputDecoration(
              labelText: 'Categoría',
              border: OutlineInputBorder(),
            ),
            items: CategoriaMeta.values.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Row(
                  children: [
                    Icon(c.icono, color: c.color, size: 18),
                    const SizedBox(width: 8),
                    Text(c.nombre),
                  ],
                ),
              );
            }).toList(),
            onChanged: (c) {
              if (c != null) setState(() => _categoria = c);
            },
          ),
          const SizedBox(height: 12),

          // ── Tipo de progreso ──
          DropdownButtonFormField<TipoProgresoMeta>(
            initialValue: _tipoProgreso,
            decoration: const InputDecoration(
              labelText: 'Tipo de progreso',
              border: OutlineInputBorder(),
            ),
            items: TipoProgresoMeta.values.map((t) {
              return DropdownMenuItem(
                value: t,
                child: Text(t.nombre),
              );
            }).toList(),
            onChanged: (t) {
              if (t != null) setState(() => _tipoProgreso = t);
            },
          ),
          const SizedBox(height: 12),

          // ── Filtro ──
          if (_tipoProgreso != TipoProgresoMeta.manual &&
              _tipoProgreso != TipoProgresoMeta.totalTareasCompletadas &&
              _tipoProgreso != TipoProgresoMeta.totalEventos &&
              _tipoProgreso != TipoProgresoMeta.totalRutinasAplicadas &&
              _tipoProgreso != TipoProgresoMeta.totalMinutos) ...[
            DropdownButtonFormField<FiltroMeta>(
              initialValue: _filtro,
              decoration: const InputDecoration(
                labelText: 'Área específica',
                border: OutlineInputBorder(),
              ),
              items: FiltroMeta.values.map((f) {
                return DropdownMenuItem(
                  value: f,
                  child: Text('${f.emoji} ${f.nombre}'),
                );
              }).toList(),
              onChanged: (f) {
                if (f != null) setState(() => _filtro = f);
              },
            ),
            const SizedBox(height: 12),
          ],

          // ── Objetivo ──
          TextField(
            controller: _objetivoCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Objetivo',
              hintText: 'Ej: 7 días, 30 registros, etc.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          // ── Info ──
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _tipoProgreso == TipoProgresoMeta.manual
                        ? 'Deberás marcar esta meta manualmente cuando la completes.'
                        : 'El progreso se calculará automáticamente según tu actividad.',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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
