import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/nota_rapida.dart';
import '../../providers/notas_provider.dart';
import '../../providers/theme_provider.dart';

class NotaEditorPage extends StatefulWidget {
  final NotaRapida? nota;

  const NotaEditorPage({super.key, this.nota});

  @override
  State<NotaEditorPage> createState() => _NotaEditorPageState();
}

class _NotaEditorPageState extends State<NotaEditorPage> {
  late final TextEditingController _ctrl;
  late Color _colorActual;
  late bool _fijada;
  bool _tieneCambios = false;
  bool _esNueva = false;

  @override
  void initState() {
    super.initState();
    _esNueva = widget.nota == null;
    _ctrl = TextEditingController(text: widget.nota?.contenido ?? '');
    _colorActual = widget.nota?.color ?? NotasProvider.coloresDisponibles.first;
    _fijada = widget.nota?.fijada ?? false;
    _ctrl.addListener(() {
      if (!_tieneCambios) {
        setState(() => _tieneCambios = true);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _guardar() {
    final contenido = _ctrl.text.trim();
    if (contenido.isEmpty) {
      if (_esNueva) {
        Navigator.pop(context);
        return;
      }
      // Eliminar nota vacía
      context.read<NotasProvider>().eliminarNota(widget.nota!.id);
      Navigator.pop(context);
      return;
    }

    final prov = context.read<NotasProvider>();

    if (_esNueva) {
      final idxColor = NotasProvider.coloresDisponibles
          .indexWhere((c) => c.toARGB32() == _colorActual.toARGB32());
      prov.agregarNota(contenido, colorIndex: idxColor >= 0 ? idxColor : 0);
    } else {
      widget.nota!.contenido = contenido;
      widget.nota!.color = _colorActual;
      widget.nota!.fijada = _fijada;
      prov.actualizarNota(widget.nota!);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;
    final esColorClaro = _colorActual.computeLuminance() > 0.5;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _guardar();
      },
      child: Scaffold(
        backgroundColor: _colorActual,
        appBar: AppBar(
          backgroundColor: _colorActual,
          foregroundColor: esColorClaro ? Colors.black87 : Colors.white,
          elevation: 0,
          title: Text(
            _esNueva ? 'Nueva nota' : 'Editar nota',
            style: TextStyle(
              fontFamily: fontFamily,
              color: esColorClaro ? Colors.black87 : Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(_fijada ? Icons.push_pin : Icons.push_pin_outlined),
              tooltip: _fijada ? 'Desfijar' : 'Fijar',
              onPressed: () => setState(() => _fijada = !_fijada),
            ),
            IconButton(
              icon: const Icon(Icons.palette_outlined),
              tooltip: 'Cambiar color',
              onPressed: _mostrarSelectorColor,
            ),
            if (!_esNueva)
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Eliminar',
                onPressed: _confirmarEliminar,
              ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _ctrl,
              autofocus: _esNueva,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 16,
                color: esColorClaro ? Colors.black87 : Colors.white,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Escribe lo que tengas en mente...',
                hintStyle: TextStyle(
                  fontFamily: fontFamily,
                  color: esColorClaro ? Colors.black54 : Colors.white70,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarSelectorColor() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Color de la nota',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(
                  NotasProvider.coloresDisponibles.length,
                  (i) {
                    final c = NotasProvider.coloresDisponibles[i];
                    final seleccionado =
                        c.toARGB32() == _colorActual.toARGB32();
                    return GestureDetector(
                      onTap: () {
                        setState(() => _colorActual = c);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: seleccionado ? Colors.black : Colors.black26,
                            width: seleccionado ? 3 : 1,
                          ),
                        ),
                        child: seleccionado
                            ? const Icon(Icons.check, size: 20)
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarEliminar() {
    if (widget.nota == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar nota?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NotasProvider>().eliminarNota(widget.nota!.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
