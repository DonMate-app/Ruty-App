import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/ejercicio.dart';
import '../providers/ejercicio_provider.dart';
import '../providers/sound_provider.dart';
import '../providers/theme_provider.dart';

class AddEjercicioDialog extends StatefulWidget {
  final Ejercicio? ejercicioExistente;

  const AddEjercicioDialog({super.key, this.ejercicioExistente});

  @override
  State<AddEjercicioDialog> createState() => _AddEjercicioDialogState();
}

class _AddEjercicioDialogState extends State<AddEjercicioDialog> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _minutosCtrl;
  late final TextEditingController _repsCtrl;
  late String _tipo;
  late Color _color;

  static const List<String> _tipos = [
    'Cardio',
    'Fuerza',
    'Flexibilidad',
    'Mixto',
    'Otro',
  ];

  final colores = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.orange,
    Colors.amber,
    Colors.brown,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    _nombreCtrl =
        TextEditingController(text: widget.ejercicioExistente?.nombre ?? '');
    _minutosCtrl = TextEditingController(
      text: widget.ejercicioExistente != null &&
              widget.ejercicioExistente!.objetivoMinutos > 0
          ? widget.ejercicioExistente!.objetivoMinutos.toString()
          : '',
    );
    _repsCtrl = TextEditingController(
      text: widget.ejercicioExistente != null &&
              widget.ejercicioExistente!.objetivoRepeticiones > 0
          ? widget.ejercicioExistente!.objetivoRepeticiones.toString()
          : '',
    );
    _tipo = widget.ejercicioExistente?.tipo ?? _tipos.first;
    _color = widget.ejercicioExistente?.color ?? Colors.green;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _minutosCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe el nombre del ejercicio')),
      );
      return;
    }

    final minutos = int.tryParse(_minutosCtrl.text.trim()) ?? 0;
    final reps = int.tryParse(_repsCtrl.text.trim()) ?? 0;

    if (minutos == 0 && reps == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Define al menos un objetivo (minutos o repeticiones)'),
        ),
      );
      return;
    }

    final prov = context.read<EjercicioProvider>();
    if (widget.ejercicioExistente != null) {
      prov.modificarEjercicio(Ejercicio(
        id: widget.ejercicioExistente!.id,
        nombre: _nombreCtrl.text.trim(),
        tipo: _tipo,
        objetivoMinutos: minutos,
        objetivoRepeticiones: reps,
        color: _color,
      ));
    } else {
      prov.agregarEjercicio(Ejercicio(
        id: const Uuid().v4(),
        nombre: _nombreCtrl.text.trim(),
        tipo: _tipo,
        objetivoMinutos: minutos,
        objetivoRepeticiones: reps,
        color: _color,
      ));
    }
    context.read<SoundProvider>().reproducirClick();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;

    return AlertDialog(
      title: Text(
        widget.ejercicioExistente != null
            ? 'Modificar ejercicio'
            : 'Nuevo ejercicio',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ej: Sentadillas',
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _tipo,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: _tipos
                  .map(
                    (t) => DropdownMenuItem(value: t, child: Text(t)),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _tipo = v);
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _minutosCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Objetivo (minutos)',
                hintText: 'Ej: 20',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _repsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Objetivo (repeticiones)',
                hintText: 'Ej: 15',
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Color:',
                style: TextStyle(fontFamily: fontFamily),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: colores
                  .map(
                    (c) => GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: _color == c
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
