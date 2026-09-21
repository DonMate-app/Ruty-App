import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/nota_rapida.dart';
import '../../providers/notas_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/guia_dialogo.dart';
import 'nota_editor_page.dart';

class NotasPage extends StatefulWidget {
  const NotasPage({super.key});

  @override
  State<NotasPage> createState() => _NotasPageState();
}

class _NotasPageState extends State<NotasPage> {
  final _searchCtrl = TextEditingController();
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mostrarGuiaSiNecesario(context, 'notas');
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _nuevaNota() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotaEditorPage(),
      ),
    );
  }

  void _abrirNota(NotaRapida nota) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotaEditorPage(nota: nota),
      ),
    );
  }

  void _opcionesNota(NotaRapida nota) {
    final prov = context.read<NotasProvider>();

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(ctx);
                _abrirNota(nota);
              },
            ),
            ListTile(
              leading: Icon(
                nota.fijada ? Icons.push_pin : Icons.push_pin_outlined,
              ),
              title: Text(nota.fijada ? 'Desfijar' : 'Fijar'),
              onTap: () {
                Navigator.pop(ctx);
                prov.toggleFijada(nota.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Cambiar color'),
              onTap: () {
                Navigator.pop(ctx);
                _mostrarSelectorColor(nota);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Eliminar'),
              onTap: () {
                Navigator.pop(ctx);
                _confirmarEliminar(nota);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarSelectorColor(NotaRapida nota) {
    final prov = context.read<NotasProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Color de la nota'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            NotasProvider.coloresDisponibles.length,
            (i) => GestureDetector(
              onTap: () {
                prov.cambiarColor(nota.id, i);
                Navigator.pop(ctx);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: NotasProvider.coloresDisponibles[i],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black26),
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(NotaRapida nota) {
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
              context.read<NotasProvider>().eliminarNota(nota.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NotasProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final fontFamily = themeProv.fontFamily;
    final notas = prov.notas;

    return Scaffold(
      appBar: AppBar(
        title: _buscando
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar en notas...',
                  border: InputBorder.none,
                ),
                onChanged: (v) => prov.setFiltroBusqueda(v),
              )
            : const Text('Aclaración mental'),
        actions: [
          IconButton(
            icon: Icon(_buscando ? Icons.close : Icons.search),
            tooltip: _buscando ? 'Cerrar búsqueda' : 'Buscar',
            onPressed: () {
              setState(() {
                if (_buscando) {
                  _buscando = false;
                  _searchCtrl.clear();
                  prov.setFiltroBusqueda('');
                } else {
                  _buscando = true;
                }
              });
            },
          ),
        ],
      ),
      body: prov.estaVacio
          ? _emptyState(context, fontFamily)
          : notas.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No hay notas que coincidan con la búsqueda',
                      style: TextStyle(
                        fontFamily: fontFamily,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: notas.length,
                  itemBuilder: (_, i) => _tarjetaNota(
                    context,
                    notas[i],
                    fontFamily,
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Nueva nota',
        onPressed: _nuevaNota,
        icon: const Icon(Icons.add),
        label: const Text('Nueva nota'),
      ),
    );
  }

  Widget _emptyState(BuildContext context, String fontFamily) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Vacía tu mente',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Anota ideas, pendientes o pensamientos '
              'sueltos para liberar tu cabeza.',
              style: TextStyle(
                fontFamily: fontFamily,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _nuevaNota,
              icon: const Icon(Icons.add),
              label: const Text('Crear mi primera nota'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaNota(
    BuildContext context,
    NotaRapida nota,
    String fontFamily,
  ) {
    final esColorClaro = nota.color.computeLuminance() > 0.5;
    final colorTexto = esColorClaro ? Colors.black87 : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: nota.color,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _abrirNota(nota),
          onLongPress: () => _opcionesNota(nota),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        nota.titulo,
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorTexto,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (nota.fijada)
                      Icon(
                        Icons.push_pin,
                        size: 16,
                        color: colorTexto,
                      ),
                  ],
                ),
                if (nota.cuerpo.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    nota.cuerpo,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 13,
                      color: colorTexto.withValues(alpha: 0.8),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  _formatearFecha(nota.fechaModificacion),
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 10,
                    color: colorTexto.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diff = ahora.difference(fecha);

    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} d';

    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}
