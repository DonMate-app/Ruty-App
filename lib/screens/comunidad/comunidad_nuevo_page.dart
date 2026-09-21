import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/comunidad_item.dart';
import '../../providers/comunidad_provider.dart';
import '../../providers/perfil_provider.dart';
import '../../providers/sound_provider.dart';

class ComunidadNuevoPage extends StatefulWidget {
  const ComunidadNuevoPage({super.key});

  @override
  State<ComunidadNuevoPage> createState() => _ComunidadNuevoPageState();
}

class _ComunidadNuevoPageState extends State<ComunidadNuevoPage> {
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _pasosCtrl = TextEditingController();

  CategoriaComunidad _categoria = CategoriaComunidad.bienestar;
  String _dificultad = 'media';
  bool _esImportable = false;
  int _duracionMinutos = 0;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _tagsCtrl.dispose();
    _pasosCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_tituloCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un título')),
      );
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe una descripción')),
      );
      return;
    }

    final perfil = context.read<PerfilProvider>().perfil;
    final autor = perfil.nombre.isEmpty ? 'Anónimo' : perfil.nombre;

    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final pasos = _pasosCtrl.text
        .split('\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    final item = ComunidadItem(
      id: const Uuid().v4(),
      titulo: _tituloCtrl.text.trim(),
      descripcion: _descCtrl.text.trim(),
      autor: autor,
      esSistema: false,
      categoria: _categoria,
      tags: tags,
      likes: 0,
      fechaCreacion: DateTime.now(),
      pasos: pasos,
      duracionMinutos: _duracionMinutos,
      dificultad: _dificultad,
      esImportable: _esImportable,
    );

    context.read<ComunidadProvider>().agregarItemUsuario(item);
    context.read<SoundProvider>().reproducirClick();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo aporte'),
        actions: [
          TextButton(
            onPressed: _guardar,
            child: const Text('Publicar'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _tituloCtrl,
            decoration: const InputDecoration(
              labelText: 'Título',
              hintText: 'Ej: Mi rutina de mañana',
              border: OutlineInputBorder(),
            ),
            maxLength: 80,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              hintText: 'Explica brevemente de qué trata',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            maxLength: 300,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CategoriaComunidad>(
            initialValue: _categoria,
            decoration: const InputDecoration(
              labelText: 'Categoría',
              border: OutlineInputBorder(),
            ),
            items: CategoriaComunidad.values
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text('${c.emoji} ${c.nombre}'),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _categoria = v);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tagsCtrl,
            decoration: const InputDecoration(
              labelText: 'Etiquetas (separadas por coma)',
              hintText: 'salud, ejercicio, mañana',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duración (min)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    _duracionMinutos = int.tryParse(v) ?? 0;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _dificultad,
                  decoration: const InputDecoration(
                    labelText: 'Dificultad',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'facil', child: Text('Fácil')),
                    DropdownMenuItem(value: 'media', child: Text('Media')),
                    DropdownMenuItem(value: 'dificil', child: Text('Difícil')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _dificultad = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pasosCtrl,
            decoration: const InputDecoration(
              labelText: 'Pasos (uno por línea)',
              hintText: 'Paso 1\nPaso 2\nPaso 3',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 6,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Permitir importar como rutina'),
            subtitle: const Text(
              'Otros usuarios podrán añadirlo a sus rutinas',
            ),
            value: _esImportable,
            onChanged: (v) => setState(() => _esImportable = v),
          ),
          const SizedBox(height: 24),
          Text(
            'Nota: los aportes se guardan localmente en tu dispositivo. '
            'En una futura versión se podrán compartir con la comunidad.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
