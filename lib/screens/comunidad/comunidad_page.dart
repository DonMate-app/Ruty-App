import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/comunidad_item.dart';
import '../../providers/comunidad_provider.dart';
import '../../providers/sound_provider.dart';
import '../../widgets/comunidad_card.dart';
import '../../widgets/guia_dialogo.dart';
import 'comunidad_detalle_page.dart';
import 'comunidad_nuevo_page.dart';

class ComunidadPage extends StatefulWidget {
  const ComunidadPage({super.key});

  @override
  State<ComunidadPage> createState() => _ComunidadPageState();
}

class _ComunidadPageState extends State<ComunidadPage> {
  CategoriaComunidad? _filtroCategoria;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mostrarGuiaSiNecesario(context, 'comunidad');
    });
  }

  List<ComunidadItem> _filtrar(List<ComunidadItem> items) {
    if (_filtroCategoria == null) return items;
    return items.where((i) => i.categoria == _filtroCategoria).toList();
  }

  void _abrirDetalle(ComunidadItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComunidadDetallePage(item: item),
      ),
    );
  }

  void _abrirNuevo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ComunidadNuevoPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ComunidadProvider>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Comunidad'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined),
              tooltip: 'Filtrar por categoría',
              onPressed: _abrirFiltroCategorias,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.verified), text: 'Del sistema'),
              Tab(icon: Icon(Icons.people), text: 'Comunidad'),
              Tab(icon: Icon(Icons.person_outline), text: 'Mis aportes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _lista(
              _filtrar(prov.itemsSistema),
              prov,
              'Aún no hay items del sistema en esta categoría.',
            ),
            _lista(
              _filtrar(prov.itemsPopulares),
              prov,
              'Aún no hay items en la comunidad.',
              mostrarMasRecomendado: true,
            ),
            _lista(
              _filtrar(prov.itemsUsuario),
              prov,
              'Aún no has creado aportes. ¡Comparte tu primera rutina!',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Crear aporte',
          onPressed: _abrirNuevo,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _lista(
    List<ComunidadItem> items,
    ComunidadProvider prov,
    String mensajeVacio, {
    bool mostrarMasRecomendado = false,
  }) {
    if (items.isEmpty) {
      final theme = Theme.of(context);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            mensajeVacio,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    final tema = Theme.of(context);
    final masRecomendado =
        mostrarMasRecomendado && items.isNotEmpty ? items.first : null;

    return ListView(
      children: [
        if (masRecomendado != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: tema.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Más recomendado por la comunidad',
                  style: tema.textTheme.titleSmall?.copyWith(
                    color: tema.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ComunidadCard(
            item: masRecomendado,
            onTap: () => _abrirDetalle(masRecomendado),
            onLike: () {
              context.read<SoundProvider>().reproducirClick();
              prov.toggleLike(masRecomendado.id);
            },
          ),
          if (items.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'Más aportes',
                style: tema.textTheme.titleSmall?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
        ...items.skip(masRecomendado != null ? 1 : 0).map(
              (item) => ComunidadCard(
                item: item,
                onTap: () => _abrirDetalle(item),
                onLike: () {
                  context.read<SoundProvider>().reproducirClick();
                  prov.toggleLike(item.id);
                },
              ),
            ),
        const SizedBox(height: 80),
      ],
    );
  }

  void _abrirFiltroCategorias() async {
    final seleccion = await showModalBottomSheet<CategoriaComunidad?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('Todas las categorías'),
              onTap: () => Navigator.pop(ctx, null),
            ),
            const Divider(height: 1),
            ...CategoriaComunidad.values.map(
              (c) => ListTile(
                leading: Text(c.emoji, style: const TextStyle(fontSize: 20)),
                title: Text(c.nombre),
                trailing:
                    _filtroCategoria == c ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(ctx, c),
              ),
            ),
          ],
        ),
      ),
    );

    setState(() {
      _filtroCategoria = seleccion;
    });
  }
}
