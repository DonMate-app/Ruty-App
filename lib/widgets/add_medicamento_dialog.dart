import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/medicamento.dart';
import '../providers/medicacion_provider.dart';
import '../providers/sound_provider.dart';
import '../providers/theme_provider.dart';

class AddMedicamentoDialog extends StatefulWidget {
  final Medicamento? medicamentoExistente;

  const AddMedicamentoDialog({super.key, this.medicamentoExistente});

  @override
  State<AddMedicamentoDialog> createState() => _AddMedicamentoDialogState();
}

class _AddMedicamentoDialogState extends State<AddMedicamentoDialog> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _dosisCtrl;
  late final TextEditingController _frecuenciaCtrl;
  late TimeOfDay _hora;
  late Color _color;

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
        TextEditingController(text: widget.medicamentoExistente?.nombre ?? '');
    _dosisCtrl =
        TextEditingController(text: widget.medicamentoExistente?.dosis ?? '');
    _frecuenciaCtrl = TextEditingController(
      text: widget.medicamentoExistente?.frecuencia ?? '',
    );
    _hora = widget.medicamentoExistente?.hora ??
        const TimeOfDay(hour: 8, minute: 0);
    _color = widget.medicamentoExistente?.color ?? Colors.red;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _dosisCtrl.dispose();
    _frecuenciaCtrl.dispose();
    super.dispose();
  }

  Future<void> _selHora() async {
    final h = await showTimePicker(context: context, initialTime: _hora);
    if (h != null) setState(() => _hora = h);
  }

  void _guardar() {
    if (_nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe el nombre del medicamento')),
      );
      return;
    }
    if (_dosisCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe la dosis')),
      );
      return;
    }

    final prov = context.read<MedicacionProvider>();
    if (widget.medicamentoExistente != null) {
      prov.modificarMedicamento(Medicamento(
        id: widget.medicamentoExistente!.id,
        nombre: _nombreCtrl.text.trim(),
        dosis: _dosisCtrl.text.trim(),
        frecuencia: _frecuenciaCtrl.text.trim(),
        hora: _hora,
        color: _color,
      ));
    } else {
      prov.agregarMedicamento(Medicamento(
        id: const Uuid().v4(),
        nombre: _nombreCtrl.text.trim(),
        dosis: _dosisCtrl.text.trim(),
        frecuencia: _frecuenciaCtrl.text.trim(),
        hora: _hora,
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
        widget.medicamentoExistente != null
            ? 'Modificar medicamento'
            : 'Nuevo medicamento',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dosisCtrl,
              decoration: const InputDecoration(
                labelText: 'Dosis',
                hintText: 'Ej: 1 pastilla, 5 ml',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _frecuenciaCtrl,
              decoration: const InputDecoration(
                labelText: 'Frecuencia',
                hintText: 'Ej: cada 8 horas, diario',
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Hora'),
              subtitle: Text(_hora.format(context)),
              trailing: const Icon(Icons.schedule),
              onTap: _selHora,
            ),
            const SizedBox(height: 8),
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
