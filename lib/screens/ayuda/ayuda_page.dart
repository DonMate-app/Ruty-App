import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/ayuda_contenido.dart';
import '../../providers/theme_provider.dart';
import 'comentario_nuevo_page.dart';
import 'comentarios_historial_page.dart';

class AyudaPage extends StatefulWidget {
  const AyudaPage({super.key});

  @override
  State<AyudaPage> createState() => _AyudaPageState();
}

class _AyudaPageState extends State<AyudaPage> {
  final _searchCtrl = TextEditingController();
  String _busqueda = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AyudaCategoria> _filtrar() {
    if (_busqueda.trim().isEmpty) return AyudaContenido.categorias;

    final q = _busqueda.toLowerCase();
    final resultado = <AyudaCategoria>[];

    for (final cat in AyudaContenido.categorias) {
      final preguntasFiltradas = cat.preguntas.where((p) {
        return p.pregunta.toLowerCase().contains(q) ||
            p.respuesta.toLowerCase().contains(q);
      }).toList();

      if (preguntasFiltradas.isNotEmpty) {
        resultado.add(AyudaCategoria(
          id: cat.id,
          titulo: cat.titulo,
          icono: cat.icono,
          color: cat.color,
          preguntas: preguntasFiltradas,
        ));
      }
    }
    return resultado;
  }

  void _abrirComentario() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ComentarioNuevoPage(),
      ),
    );
  }

  void _abrirHistorial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ComentariosHistorialPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;
    final categorias = _filtrar();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historial de comentarios',
            onPressed: _abrirHistorial,
          ),
        ],
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar en la ayuda...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busqueda.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _busqueda = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (v) => setState(() => _busqueda = v),
            ),
          ),

          // Botón de comentario
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Material(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _abrirComentario,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.feedback_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¿No encuentras respuesta?',
                              style: TextStyle(
                                fontFamily: fontFamily,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Envíanos tu sugerencia o reporte',
                              style: TextStyle(
                                fontFamily: fontFamily,
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Lista de categorías
          Expanded(
            child: categorias.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sin resultados para "$_busqueda"',
                            style: TextStyle(
                              fontFamily: fontFamily,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: categorias.length,
                    itemBuilder: (_, i) =>
                        _categoria(context, categorias[i], fontFamily),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _categoria(
    BuildContext context,
    AyudaCategoria cat,
    String fontFamily,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cat.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(cat.icono, color: cat.color, size: 22),
        ),
        title: Text(
          cat.titulo,
          style: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${cat.preguntas.length} pregunta(s)',
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
          ),
        ),
        children: cat.preguntas
            .map((p) => _pregunta(context, p, fontFamily, cat.color))
            .toList(),
      ),
    );
  }

  Widget _pregunta(
    BuildContext context,
    AyudaPregunta p,
    String fontFamily,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          p.pregunta,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              p.respuesta,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 13,
                height: 1.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
