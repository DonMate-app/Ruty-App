import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/alimento_registro.dart';
import '../providers/alimentacion_provider.dart';
import '../providers/sound_provider.dart';
import '../providers/theme_provider.dart';

class AddAlimentoDialog extends StatefulWidget {
  final AlimentoRegistro? registroExistente;
  final DateTime? fechaInicial;

  const AddAlimentoDialog({
    super.key,
    this.registroExistente,
    this.fechaInicial,
  });

  @override
  State<AddAlimentoDialog> createState() => _AddAlimentoDialogState();
}

class _AddAlimentoDialogState extends State<AddAlimentoDialog> {
  late final TextEditingController _descCtrl;
  late final TextEditingController _cantidadCtrl;
  late TipoAlimento _tipo;
  late DateTime _fechaHora;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(
      text: widget.registroExistente?.descripcion ?? '',
    );
    _cantidadCtrl = TextEditingController(
      text: widget.registroExistente != null
          ? widget.registroExistente!.cantidad.toString()
          : '',
    );
    _tipo = widget.registroExistente?.tipo ?? TipoAlimento.solido;
    _fechaHora = widget.registroExistente?.fechaHora ??
        widget.fechaInicial ??
        DateTime.now();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _cantidadCtrl.dispose();
    super.dispose();
  }

  String _unidad() {
    switch (_tipo) {
      case TipoAlimento.liquido:
        return 'ml';
      case TipoAlimento.solido:
        return 'g';
      case TipoAlimento.plato:
        return 'unidades';
    }
  }

  IconData _iconoParaTipo(TipoAlimento tipo) {
    switch (tipo) {
      case TipoAlimento.liquido:
        return Icons.local_drink;
      case TipoAlimento.solido:
        return Icons.fastfood;
      case TipoAlimento.plato:
        return Icons.restaurant;
    }
  }

  String _nombreTipo(TipoAlimento tipo) {
    switch (tipo) {
      case TipoAlimento.liquido:
        return 'Líquido';
      case TipoAlimento.solido:
        return 'Sólido';
      case TipoAlimento.plato:
        return 'Plato';
    }
  }

  Future<void> _selFechaHora() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaHora,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (fecha == null) return;

    if (!mounted) return;
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fechaHora),
    );
    if (hora == null) return;

    setState(() {
      _fechaHora = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        hora.hour,
        hora.minute,
      );
    });
  }

  void _guardar() {
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe una descripción')),
      );
      return;
    }

    final cantidad = double.tryParse(_cantidadCtrl.text.trim()) ?? 0;
    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cantidad debe ser mayor a 0')),
      );
      return;
    }

    final prov = context.read<AlimentacionProvider>();
    if (widget.registroExistente != null) {
      prov.modificarRegistro(AlimentoRegistro(
        id: widget.registroExistente!.id,
        descripcion: _descCtrl.text.trim(),
        tipo: _tipo,
        cantidad: cantidad,
        fechaHora: _fechaHora,
      ));
    } else {
      prov.agregarRegistro(AlimentoRegistro(
        id: const Uuid().v4(),
        descripcion: _descCtrl.text.trim(),
        tipo: _tipo,
        cantidad: cantidad,
        fechaHora: _fechaHora,
      ));
    }
    context.read<SoundProvider>().reproducirClick();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        widget.registroExistente != null
            ? 'Modificar registro'
            : 'Nuevo registro',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Ej: Ensalada de pollo',
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tipo:',
                style: TextStyle(fontFamily: fontFamily),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: TipoAlimento.values
                  .map(
                    (t) => ChoiceChip(
                      avatar: Icon(_iconoParaTipo(t), size: 16),
                      label: Text(_nombreTipo(t)),
                      selected: _tipo == t,
                      onSelected: (_) => setState(() => _tipo = t),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cantidadCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Cantidad',
                suffixText: _unidad(),
                hintText: _tipo == TipoAlimento.liquido
                    ? 'Ej: 250'
                    : _tipo == TipoAlimento.solido
                        ? 'Ej: 150'
                        : 'Ej: 1',
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: Text(
                'Fecha y hora',
                style: TextStyle(fontFamily: fontFamily),
              ),
              subtitle: Text(
                '${_fechaHora.day}/${_fechaHora.month}/${_fechaHora.year} '
                '- ${_fechaHora.hour.toString().padLeft(2, '0')}:${_fechaHora.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontFamily: fontFamily),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_calendar),
                onPressed: _selFechaHora,
              ),
            ),
            const SizedBox(height: 8),
            if (_tipo == TipoAlimento.liquido)
              Text(
                '💧 Recuerda beber al menos 8 vasos al día.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
