import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/insignia.dart';
import '../../models/perfil_usuario.dart';
import '../../providers/ejercicio_provider.dart';
import '../../providers/eventos_provider.dart';
import '../../providers/metas_provider.dart';
import '../../providers/notas_provider.dart';
import '../../providers/perfil_provider.dart';
import '../../providers/tareas_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/metas_service.dart';
import '../../widgets/nivel_widget.dart';
import '../../widgets/pro_guard.dart';
import '../metas/metas_page.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final perfilProv = context.watch<PerfilProvider>();
    final metasProv = context.watch<MetasProvider>();
    final perfil = perfilProv.perfil;
    final fontFamily = themeProv.fontFamily;

    // Racha real: usa el método oficial de MetasService
    final eventos = context.watch<EventosProvider>().eventos;
    final tareas = context.watch<TareasProvider>().tareas;
    final registrosEjercicio = context.watch<EjercicioProvider>().registros;
    final notas = context.watch<NotasProvider>().notasSinFiltrar;

    final racha = MetasService.calcularRachaGeneral(
      eventos: eventos,
      tareas: tareas,
      registrosEjercicio: registrosEjercicio,
      notas: notas,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de usuario')),
      body: ListView(
        children: [
          // ── NIVEL + RACHA + INSIGNIAS (Fase 16.3, bloque Pro) ──
          ProGuardInline(
            nombreFuncion: 'Nivel, racha y logros',
            descripcion:
                'Sube de nivel, mantén tu racha diaria y desbloquea insignias '
                'completando metas. Convierte tus hábitos en progreso visible.',
            icono: Icons.emoji_events,
            child: Column(
              children: [
                const NivelWidget(),
                _rachaCard(context, racha, fontFamily),
                _insigniasResumen(context, metasProv, fontFamily),
              ],
            ),
          ),

          // ── Encabezado con resumen ──
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.15),
                    child: Icon(
                      Icons.person,
                      size: 36,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          perfil.nombre.isEmpty ? 'Sin nombre' : perfil.nombre,
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          perfil.edad > 0
                              ? '${perfil.edad} años · ${_textoEstilo(perfil.estiloVida)}'
                              : 'Completa tu perfil para recomendaciones',
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (perfil.imc > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            'IMC: ${perfil.imc.toStringAsFixed(1)} · ${perfil.categoriaImc}',
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Datos básicos ──
          _seccionTitulo(context, 'Datos básicos'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Nombre'),
            subtitle:
                Text(perfil.nombre.isEmpty ? 'Sin nombre' : perfil.nombre),
            onTap: () => _editarTexto(
              context,
              titulo: 'Nombre',
              valorInicial: perfil.nombre,
              onGuardar: (v) => perfilProv.actualizarCampo(nombre: v),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.cake_outlined),
            title: const Text('Edad'),
            subtitle:
                Text(perfil.edad > 0 ? '${perfil.edad} años' : 'Sin definir'),
            onTap: () => _editarNumero(
              context,
              titulo: 'Edad',
              valorInicial: perfil.edad.toString(),
              esDecimal: false,
              onGuardar: (v) =>
                  perfilProv.actualizarCampo(edad: int.tryParse(v) ?? 0),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.wc),
            title: const Text('Sexo'),
            subtitle: Text(_textoSexo(perfil.sexo)),
            onTap: () => _editarSexo(context, perfilProv, perfil.sexo),
          ),
          ListTile(
            leading: const Icon(Icons.monitor_weight_outlined),
            title: const Text('Peso (kg)'),
            subtitle: Text(
              perfil.pesoKg > 0
                  ? '${perfil.pesoKg.toStringAsFixed(1)} kg'
                  : 'Sin definir',
            ),
            onTap: () => _editarNumero(
              context,
              titulo: 'Peso (kg)',
              valorInicial: perfil.pesoKg > 0 ? perfil.pesoKg.toString() : '',
              esDecimal: true,
              onGuardar: (v) => perfilProv.actualizarCampo(
                pesoKg: double.tryParse(v) ?? 0,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.height),
            title: const Text('Altura (cm)'),
            subtitle: Text(
              perfil.alturaCm > 0
                  ? '${perfil.alturaCm.toStringAsFixed(0)} cm'
                  : 'Sin definir',
            ),
            onTap: () => _editarNumero(
              context,
              titulo: 'Altura (cm)',
              valorInicial:
                  perfil.alturaCm > 0 ? perfil.alturaCm.toString() : '',
              esDecimal: true,
              onGuardar: (v) => perfilProv.actualizarCampo(
                alturaCm: double.tryParse(v) ?? 0,
              ),
            ),
          ),

          const Divider(height: 32),

          // ── Estilo de vida ──
          _seccionTitulo(context, 'Estilo de vida'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: EstiloVida.values.map((e) {
                return RadioListTile<EstiloVida>(
                  title: Text(_textoEstilo(e)),
                  value: e,
                  groupValue: perfil.estiloVida,
                  onChanged: (v) {
                    if (v != null) {
                      perfilProv.actualizarCampo(estiloVida: v);
                    }
                  },
                );
              }).toList(),
            ),
          ),

          const Divider(height: 32),

          // ── Enfermedades ──
          _seccionTitulo(context, 'Enfermedades'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Selecciona las que apliquen. Esta información nos ayuda a '
              'darte mejores recomendaciones.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _enfermedadesComunes.map((e) {
                final seleccionada = perfil.enfermedades.contains(e);
                return FilterChip(
                  label: Text(e),
                  selected: seleccionada,
                  onSelected: (sel) {
                    final nuevas = Set<String>.from(perfil.enfermedades);
                    if (sel) {
                      nuevas.add(e);
                    } else {
                      nuevas.remove(e);
                    }
                    perfilProv.actualizarCampo(enfermedades: nuevas);
                  },
                );
              }).toList(),
            ),
          ),

          const Divider(height: 32),

          // ── Alergias ──
          _seccionTitulo(context, 'Alergias'),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _alergiasComunes.map((a) {
                final seleccionada = perfil.alergias.contains(a);
                return FilterChip(
                  label: Text(a),
                  selected: seleccionada,
                  onSelected: (sel) {
                    final nuevas = Set<String>.from(perfil.alergias);
                    if (sel) {
                      nuevas.add(a);
                    } else {
                      nuevas.remove(a);
                    }
                    perfilProv.actualizarCampo(alergias: nuevas);
                  },
                );
              }).toList(),
            ),
          ),

          const Divider(height: 32),

          // ── Condiciones ──
          _seccionTitulo(context, 'Condición'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: Condicion.values.map((c) {
                return CheckboxListTile(
                  title: Text(_textoCondicion(c)),
                  value: perfil.condiciones.contains(c),
                  onChanged: (sel) {
                    final nuevas = Set<Condicion>.from(perfil.condiciones);
                    if (sel == true) {
                      nuevas.add(c);
                    } else {
                      nuevas.remove(c);
                    }
                    perfilProv.actualizarCampo(condiciones: nuevas);
                  },
                );
              }).toList(),
            ),
          ),

          const Divider(height: 32),

          // ── Notas ──
          _seccionTitulo(context, 'Notas'),
          ListTile(
            leading: const Icon(Icons.notes),
            title: const Text('Notas personales'),
            subtitle: Text(
              perfil.notas.isEmpty ? 'Sin notas' : perfil.notas,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _editarTexto(
              context,
              titulo: 'Notas',
              valorInicial: perfil.notas,
              multilinea: true,
              onGuardar: (v) => perfilProv.actualizarCampo(notas: v),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Tarjeta de racha (Fase 16.3) ─────────────────────────

  Widget _rachaCard(
    BuildContext context,
    int racha,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    final activa = racha > 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: activa
              ? Colors.deepOrange.withValues(alpha: 0.4)
              : theme.colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: activa
                    ? Colors.deepOrange.withValues(alpha: 0.15)
                    : theme.colorScheme.surfaceContainerHighest,
              ),
              alignment: Alignment.center,
              child: Text(
                activa ? '🔥' : '💤',
                style: const TextStyle(fontSize: 26),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activa
                        ? 'Racha de $racha ${racha == 1 ? 'día' : 'días'}'
                        : 'Sin racha activa',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activa
                        ? '¡Sigue así! Mantén el hábito'
                        : 'Completa una meta hoy para empezar',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Resumen de insignias (Fase 16.3) ─────────────────────

  Widget _insigniasResumen(
    BuildContext context,
    MetasProvider metas,
    String fontFamily,
  ) {
    final theme = Theme.of(context);
    final obtenidas = metas.insigniasObtenidas;
    final total = metas.insignias.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.military_tech,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Insignias',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${obtenidas.length}/$total',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MetasPage(initialTab: 2),
                      ),
                    );
                  },
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (obtenidas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Aún no tienes insignias. ¡Completa metas para desbloquearlas!',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: obtenidas
                    .take(8)
                    .map((ins) => _chipInsignia(context, ins))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chipInsignia(BuildContext context, Insignia ins) {
    return Tooltip(
      message: '${ins.nombre}\n${ins.descripcion}',
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: ins.color.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: ins.color, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          ins.emoji,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────

  Widget _seccionTitulo(BuildContext context, String texto) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        texto,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _textoEstilo(EstiloVida e) {
    switch (e) {
      case EstiloVida.sedentario:
        return 'Sedentario';
      case EstiloVida.ligero:
        return 'Actividad ligera';
      case EstiloVida.activo:
        return 'Activo';
      case EstiloVida.deportista:
        return 'Deportista';
    }
  }

  String _textoSexo(Sexo s) {
    switch (s) {
      case Sexo.noEspecificado:
        return 'No especificado';
      case Sexo.masculino:
        return 'Masculino';
      case Sexo.femenino:
        return 'Femenino';
      case Sexo.otro:
        return 'Otro';
    }
  }

  String _textoCondicion(Condicion c) {
    switch (c) {
      case Condicion.ninguna:
        return 'Ninguna';
      case Condicion.embarazo:
        return 'Embarazo';
      case Condicion.lactancia:
        return 'Lactancia';
      case Condicion.recuperacion:
        return 'Recuperación';
      case Condicion.cronica:
        return 'Enfermedad crónica';
      case Condicion.discapacidad:
        return 'Discapacidad';
    }
  }

  // ─── Diálogos ─────────────────────────────────────────────

  void _editarTexto(
    BuildContext context, {
    required String titulo,
    required String valorInicial,
    required ValueChanged<String> onGuardar,
    bool multilinea = false,
  }) {
    final ctrl = TextEditingController(text: valorInicial);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: multilinea ? 4 : 1,
          decoration: const InputDecoration(
            hintText: 'Escribe aquí...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              onGuardar(ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editarNumero(
    BuildContext context, {
    required String titulo,
    required String valorInicial,
    required ValueChanged<String> onGuardar,
    bool esDecimal = false,
  }) {
    final ctrl = TextEditingController(text: valorInicial);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: esDecimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              onGuardar(ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editarSexo(
    BuildContext context,
    PerfilProvider prov,
    Sexo actual,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: Sexo.values.map((s) {
            return RadioListTile<Sexo>(
              title: Text(_textoSexo(s)),
              value: s,
              groupValue: actual,
              onChanged: (v) {
                if (v != null) {
                  prov.actualizarCampo(sexo: v);
                  Navigator.pop(ctx);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── Listas predefinidas ──────────────────────────────────

  static const List<String> _enfermedadesComunes = [
    'Diabetes',
    'Hipertensión',
    'Asma',
    'Colesterol alto',
    'Tiroides',
    'Migraña',
    'Artritis',
    'Depresión',
    'Ansiedad',
    'Cardiopatía',
  ];

  static const List<String> _alergiasComunes = [
    'Gluten',
    'Lactosa',
    'Frutos secos',
    'Mariscos',
    'Huevo',
    'Soya',
    'Polen',
    'Penicilina',
    'Látex',
    'Picaduras de insectos',
  ];
}
