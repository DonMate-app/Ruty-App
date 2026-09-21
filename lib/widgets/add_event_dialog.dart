import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/evento.dart';
import '../models/ilustracion_evento.dart';
import '../providers/estado_pro_provider.dart';
import '../providers/eventos_provider.dart';
import '../providers/sound_provider.dart';
import 'pro_feature_dialog.dart';
import 'success_animation.dart';

class AddEventDialog extends StatefulWidget {
  final DateTime fechaInicial;
  final TimeOfDay? horaInicioPredefinida;
  final Evento? eventoExistente;
  final Color? colorInicial;

  const AddEventDialog({
    super.key,
    required this.fechaInicial,
    this.horaInicioPredefinida,
    this.eventoExistente,
    this.colorInicial,
  });

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  late final TextEditingController _titCtrl;
  late TimeOfDay _hInicio, _hFin;
  late Color _color;
  bool _colorCargado = false;
  late TipoEvento _tipo;
  late Recurrencia _recurrencia;
  int _duracionMinutos = 60;
  String? _ilustracionId;

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
    _titCtrl =
        TextEditingController(text: widget.eventoExistente?.titulo ?? '');
    _hInicio = widget.eventoExistente?.horaInicio ??
        widget.horaInicioPredefinida ??
        const TimeOfDay(hour: 9, minute: 0);
    _hFin = widget.eventoExistente?.horaFin ??
        _hInicio.replacing(hour: (_hInicio.hour + 1) % 24);
    _color =
        widget.eventoExistente?.color ?? widget.colorInicial ?? Colors.indigo;
    _tipo = widget.eventoExistente?.tipo ?? TipoEvento.otro;
    _recurrencia = widget.eventoExistente?.recurrencia ?? Recurrencia.ninguna;
    _ilustracionId = widget.eventoExistente?.ilustracion;
    if (widget.eventoExistente != null) {
      _duracionMinutos = (_hFin.hour * 60 + _hFin.minute) -
          (_hInicio.hour * 60 + _hInicio.minute);
      if (_duracionMinutos <= 0) _duracionMinutos = 60;
    }
    if (widget.eventoExistente == null && widget.colorInicial == null) {
      _cargarColorDefecto();
    } else {
      _colorCargado = true;
    }
  }

  Future<void> _cargarColorDefecto() async {
    final prefs = await SharedPreferences.getInstance();
    final c = prefs.getInt('defaultEventColor');
    if (c != null && mounted) {
      setState(() {
        _color = Color(c & 0xFFFFFFFF);
        _colorCargado = true;
      });
    } else {
      if (mounted) {
        setState(() => _colorCargado = true);
      }
    }
  }

  Future<void> _selHoraInicio() async {
    final h = await showTimePicker(context: context, initialTime: _hInicio);
    if (h != null) {
      setState(() {
        _hInicio = h;
        _actualizarHoraFin();
      });
    }
  }

  void _actualizarHoraFin() {
    final minutosInicio = _hInicio.hour * 60 + _hInicio.minute;
    final minutosFin = minutosInicio + _duracionMinutos;
    final cruza = minutosFin >= 24 * 60;
    final minutosAjustados = cruza ? 24 * 60 - 1 : minutosFin;
    _hFin = TimeOfDay(
      hour: minutosAjustados ~/ 60,
      minute: minutosAjustados % 60,
    );
  }

  Future<void> _selDuracion() async {
    final nuevaDuracion = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Duración (minutos)'),
        children: [30, 45, 60, 90, 120, 180, 240]
            .map((m) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, m),
                  child: Text('$m minutos'),
                ))
            .toList(),
      ),
    );
    if (nuevaDuracion != null) {
      setState(() {
        _duracionMinutos = nuevaDuracion;
        _actualizarHoraFin();
      });
    }
  }

  Future<void> _abrirSelectorIlustracion() async {
    // 🔒 Verificar acceso Pro
    final estado = context.read<EstadoProProvider>();
    if (!estado.tieneAccesoPro) {
      final activado = await mostrarDialogoFuncionPro(
        context,
        nombreFuncion: 'Ilustraciones de eventos',
        descripcion:
            'Añade un emoji a tus eventos para identificarlos de un vistazo. '
            'Más de 60 opciones organizadas en 10 categorías.',
        icono: Icons.emoji_emotions_outlined,
      );
      if (!mounted) return;
      // Si activó el trial, volver a comprobar
      if (activado && context.read<EstadoProProvider>().tieneAccesoPro) {
        // Continuar con el selector
      } else {
        return;
      }
    }

    final seleccion = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _SelectorIlustracionDialog(
        seleccionActual: _ilustracionId,
      ),
    );
    if (seleccion != null) {
      setState(() {
        _ilustracionId = seleccion == '_sin_' ? null : seleccion;
      });
    }
  }

  void _guardar() {
    if (_titCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un título')),
      );
      return;
    }
    final inicioMin = _hInicio.hour * 60 + _hInicio.minute;
    final finMin = _hFin.hour * 60 + _hFin.minute;
    if (finMin <= inicioMin && _duracionMinutos >= 24 * 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La duración no puede superar 24 horas'),
        ),
      );
      return;
    }
    final prov = context.read<EventosProvider>();
    final esNuevo = widget.eventoExistente == null;

    if (!esNuevo) {
      prov.modificarEvento(Evento(
        id: widget.eventoExistente!.id,
        titulo: _titCtrl.text.trim(),
        fecha: widget.fechaInicial,
        horaInicio: _hInicio,
        horaFin: _hFin,
        color: _color,
        suspendido: widget.eventoExistente!.suspendido,
        cruzaMedianoche: finMin >= 24 * 60,
        tipo: _tipo,
        recurrencia: _recurrencia,
        ilustracion: _ilustracionId,
      ));
    } else {
      prov.agregarEvento(Evento(
        id: const Uuid().v4(),
        titulo: _titCtrl.text.trim(),
        fecha: widget.fechaInicial,
        horaInicio: _hInicio,
        horaFin: _hFin,
        color: _color,
        tipo: _tipo,
        recurrencia: _recurrencia,
        ilustracion: _ilustracionId,
      ));
    }
    context.read<SoundProvider>().reproducirClick();
    Navigator.pop(context);

    mostrarAnimacionExito(
      context,
      mensaje: esNuevo ? 'Evento creado' : 'Evento actualizado',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estado = context.watch<EstadoProProvider>();
    final emojiSeleccionado = IlustracionesData.emojiPorId(_ilustracionId);
    final esPro = estado.tieneAccesoPro;

    return AlertDialog(
      title: Text(
        widget.eventoExistente != null ? 'Modificar evento' : 'Nuevo evento',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Inicio'),
                    subtitle: Text(_hInicio.format(context)),
                    onTap: _selHoraInicio,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Duración'),
                    subtitle: Text('$_duracionMinutos min'),
                    onTap: _selDuracion,
                  ),
                ),
              ],
            ),
            ListTile(
              title: const Text('Fin'),
              subtitle: Text(_hFin.format(context)),
              enabled: false,
            ),
            const SizedBox(height: 10),

            // ── Ilustración ──
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: esPro
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: emojiSeleccionado != null
                    ? Text(
                        emojiSeleccionado,
                        style: const TextStyle(fontSize: 24),
                      )
                    : Icon(
                        esPro ? Icons.image_outlined : Icons.lock_outline,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
              ),
              title: Row(
                children: [
                  const Text('Ilustración'),
                  if (!esPro) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                !esPro
                    ? 'Activa Pro para usar ilustraciones'
                    : emojiSeleccionado != null
                        ? 'Toca para cambiar o quitar'
                        : 'Toca para elegir un emoji',
              ),
              trailing: emojiSeleccionado != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Quitar',
                      onPressed: () => setState(() => _ilustracionId = null),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _abrirSelectorIlustracion,
            ),

            const SizedBox(height: 10),
            DropdownButtonFormField<TipoEvento>(
              initialValue: _tipo,
              decoration: const InputDecoration(labelText: 'Tipo de evento'),
              items: TipoEvento.values.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(t.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (t) {
                if (t != null) setState(() => _tipo = t);
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<Recurrencia>(
              initialValue: _recurrencia,
              decoration: const InputDecoration(labelText: 'Repetición'),
              items: Recurrencia.values.map((r) {
                return DropdownMenuItem(
                  value: r,
                  child: Text(r.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (r) {
                if (r != null) setState(() => _recurrencia = r);
              },
            ),
            const SizedBox(height: 10),
            const Text('Color:'),
            if (!_colorCargado)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              )
            else
              Wrap(
                spacing: 8,
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

// ═══════════════════════════════════════════════════════════════
// Selector de ilustración
// ═══════════════════════════════════════════════════════════════

class _SelectorIlustracionDialog extends StatefulWidget {
  final String? seleccionActual;

  const _SelectorIlustracionDialog({this.seleccionActual});

  @override
  State<_SelectorIlustracionDialog> createState() =>
      _SelectorIlustracionDialogState();
}

class _SelectorIlustracionDialogState
    extends State<_SelectorIlustracionDialog> {
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categorias = _filtrarCategorias();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (ctx, controller) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.image_outlined),
                  const SizedBox(width: 8),
                  Text(
                    'Elegir ilustración',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (widget.seleccionActual != null)
                    TextButton.icon(
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Quitar'),
                      onPressed: () => Navigator.pop(context, '_sin_'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar ilustración...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _busqueda = v),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: categorias.isEmpty
                  ? Center(
                      child: Text(
                        'Sin resultados',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categorias.length,
                      itemBuilder: (_, i) => _categoria(context, categorias[i]),
                    ),
            ),
          ],
        );
      },
    );
  }

  List<IlustracionCategoria> _filtrarCategorias() {
    if (_busqueda.trim().isEmpty) return IlustracionesData.categorias;

    final q = _busqueda.toLowerCase();
    final resultado = <IlustracionCategoria>[];

    for (final cat in IlustracionesData.categorias) {
      final filtradas = cat.ilustraciones.where((il) {
        return il.nombre.toLowerCase().contains(q) || il.emoji.contains(q);
      }).toList();

      if (filtradas.isNotEmpty) {
        resultado.add(IlustracionCategoria(
          titulo: cat.titulo,
          icono: cat.icono,
          color: cat.color,
          ilustraciones: filtradas,
        ));
      }
    }
    return resultado;
  }

  Widget _categoria(BuildContext context, IlustracionCategoria cat) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(cat.icono, size: 18, color: cat.color),
              const SizedBox(width: 6),
              Text(
                cat.titulo,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: cat.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cat.ilustraciones.map((il) {
              final seleccionado = widget.seleccionActual == il.id;
              return GestureDetector(
                onTap: () => Navigator.pop(context, il.id),
                child: Container(
                  width: 64,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: seleccionado
                        ? cat.color.withValues(alpha: 0.2)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: seleccionado ? cat.color : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        il.emoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        il.nombre,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
