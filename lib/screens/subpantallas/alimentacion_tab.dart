import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/alimento_registro.dart';
import '../../providers/alimentacion_provider.dart';
import '../../providers/sound_provider.dart';
import '../../widgets/add_alimento_dialog.dart';

class AlimentacionTab extends StatefulWidget {
  const AlimentacionTab({super.key});

  @override
  State<AlimentacionTab> createState() => _AlimentacionTabState();
}

class _AlimentacionTabState extends State<AlimentacionTab> {
  DateTime _fecha = DateTime.now();

  void _abrirNuevoRegistro() {
    showDialog(
      context: context,
      builder: (_) => AddAlimentoDialog(fechaInicial: _fecha),
    );
  }

  void _opcionesRegistro(AlimentoRegistro r) {
    final prov = context.read<AlimentacionProvider>();

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modificar'),
              onTap: () {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (_) => AddAlimentoDialog(
                    registroExistente: r,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Eliminar'),
              onTap: () {
                Navigator.pop(ctx);
                prov.eliminarRegistro(r.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AlimentacionProvider>();
    final registros = prov.registrosDeDia(_fecha);
    final theme = Theme.of(context);

    // Contadores por tipo
    final liquidos =
        registros.where((r) => r.tipo == TipoAlimento.liquido).length;
    final solidos =
        registros.where((r) => r.tipo == TipoAlimento.solido).length;
    final platos = registros.where((r) => r.tipo == TipoAlimento.plato).length;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() {
                    _fecha = _fecha.subtract(const Duration(days: 1));
                  }),
                ),
                Text(
                  '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() {
                    _fecha = _fecha.add(const Duration(days: 1));
                  }),
                ),
              ],
            ),
          ),
          // Resumen del día
          if (registros.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Chip(
                    avatar: const Icon(Icons.local_drink, size: 16),
                    label: Text('$liquidos'),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    avatar: const Icon(Icons.fastfood, size: 16),
                    label: Text('$solidos'),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    avatar: const Icon(Icons.restaurant, size: 16),
                    label: Text('$platos'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          Expanded(
            child: registros.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aún no hay registros este día',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Toca el botón + para registrar tu primera comida.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: registros.length,
                    itemBuilder: (_, i) {
                      final r = registros[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              theme.colorScheme.primary.withValues(alpha: 0.15),
                          child: Icon(
                            _iconoParaTipo(r.tipo),
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(r.descripcion),
                        subtitle: Text(
                          '${r.tipo.name} · ${r.cantidad} ${_unidadParaTipo(r.tipo)} · ${r.fechaHora.hour.toString().padLeft(2, '0')}:${r.fechaHora.minute.toString().padLeft(2, '0')}',
                        ),
                        onTap: () => _opcionesRegistro(r),
                        onLongPress: () => _opcionesRegistro(r),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Añadir registro',
        onPressed: _abrirNuevoRegistro,
        child: const Icon(Icons.add),
      ),
    );
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

  String _unidadParaTipo(TipoAlimento tipo) {
    switch (tipo) {
      case TipoAlimento.liquido:
        return 'ml';
      case TipoAlimento.solido:
        return 'g';
      case TipoAlimento.plato:
        return 'uds';
    }
  }
}
