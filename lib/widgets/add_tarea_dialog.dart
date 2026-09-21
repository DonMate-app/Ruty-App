import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/tarea.dart';
import '../providers/sound_provider.dart';
import '../providers/tareas_provider.dart';

class AddTareaDialog extends StatefulWidget {
  final Tarea? tareaExistente;

  const AddTareaDialog({super.key, this.tareaExistente});

  @override
  State<AddTareaDialog> createState() => _AddTareaDialogState();
}

class _AddTareaDialogState extends State<AddTareaDialog> {
  late final TextEditingController _titCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _duracionCtrl;
  late Color _color;
  late UnidadDuracion _unidad;
  late PrioridadTarea _prioridad;
  DateTime? _fechaLimite;

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
    _titCtrl = TextEditingController(text: widget.tareaExistente?.titulo ?? '');
    _descCtrl =
        TextEditingController(text: widget.tareaExistente?.descripcion ?? '');
    _duracionCtrl = TextEditingController(
      text: widget.tareaExistente?.duracion.toString() ?? '30',
    );
    _color = widget.tareaExistente?.color ?? Colors.indigo;
    _unidad = widget.tareaExistente?.unidad ?? UnidadDuracion.minutos;
    _prioridad = widget.tareaExistente?.prioridad ?? PrioridadTarea.media;
    _fechaLimite = widget.tareaExistente?.fechaLimite;
  }

  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();
    final seleccion = await showDatePicker(
      context: context,
      initialDate: _fechaLimite ?? ahora,
      firstDate: ahora.subtract(const Duration(days: 365)),
      lastDate: ahora.add(const Duration(days: 365 * 5)),
    );
    if (seleccion != null) {
      setState(() => _fechaLimite = seleccion);
    }
  }

  void _guardar() {
    if (_titCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un título')),
      );
      return;
    }
    final duracion = int.tryParse(_duracionCtrl.text.trim()) ?? 0;
    if (duracion <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Duración debe ser mayor a 0')),
      );
      return;
    }

    final prov = context.read<TareasProvider>();
    if (widget.tareaExistente != null) {
      prov.modificarTarea(Tarea(
        id: widget.tareaExistente!.id,
        titulo: _titCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
        duracion: duracion,
        unidad: _unidad,
        color: _color,
        completada: widget.tareaExistente!.completada,
        prioridad: _prioridad,
        fechaLimite: _fechaLimite,
        fechaCreacion: widget.tareaExistente!.fechaCreacion,
      ));
    } else {
      prov.agregarTarea(Tarea(
        id: const Uuid().v4(),
        titulo: _titCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
        duracion: duracion,
        unidad: _unidad,
        color: _color,
        prioridad: _prioridad,
        fechaLimite: _fechaLimite,
        fechaCreacion: DateTime.now(),
      ));
    }
    context.read<SoundProvider>().reproducirClick();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.tareaExistente != null ? 'Modificar tarea' : 'Nueva tarea',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _duracionCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Duración'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<UnidadDuracion>(
                    initialValue: _unidad,
                    decoration: const InputDecoration(labelText: 'Unidad'),
                    items: UnidadDuracion.values.map((u) {
                      return DropdownMenuItem(
                        value: u,
                        child: Text(u.name),
                      );
                    }).toList(),
                    onChanged: (u) {
                      if (u != null) setState(() => _unidad = u);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<PrioridadTarea>(
              initialValue: _prioridad,
              decoration: const InputDecoration(labelText: 'Prioridad'),
              items: PrioridadTarea.values.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text(p.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (p) {
                if (p != null) setState(() => _prioridad = p);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Fecha límite'),
              subtitle: Text(
                _fechaLimite == null
                    ? 'Sin fecha'
                    : '${_fechaLimite!.day}/${_fechaLimite!.month}/${_fechaLimite!.year}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _seleccionarFecha,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Color:'),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: colores
                  .map((c) => GestureDetector(
                        onTap: () => setState(() => _color = c),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: _color == c
                                ? Border.all(
                                    color: Colors.black,
                                    width: 3,
                                  )
                                : null,
                          ),
                        ),
                      ))
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
