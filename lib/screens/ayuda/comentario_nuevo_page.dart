import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/comentario_usuario.dart';
import '../../providers/comentarios_provider.dart';
import '../../providers/theme_provider.dart';

class ComentarioNuevoPage extends StatefulWidget {
  const ComentarioNuevoPage({super.key});

  @override
  State<ComentarioNuevoPage> createState() => _ComentarioNuevoPageState();
}

class _ComentarioNuevoPageState extends State<ComentarioNuevoPage> {
  final _mensajeCtrl = TextEditingController();
  final _contactoCtrl = TextEditingController();
  TipoComentario _tipo = TipoComentario.sugerencia;
  String _versionApp = '';
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _cargarVersion();
  }

  Future<void> _cargarVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _versionApp = 'v${info.version} (${info.buildNumber})';
      });
    }
  }

  @override
  void dispose() {
    _mensajeCtrl.dispose();
    _contactoCtrl.dispose();
    super.dispose();
  }

  String _tituloTipo(TipoComentario t) {
    switch (t) {
      case TipoComentario.sugerencia:
        return 'Sugerencia';
      case TipoComentario.error:
        return 'Reportar un error';
      case TipoComentario.felicitacion:
        return 'Felicitación';
      case TipoComentario.otro:
        return 'Otro';
    }
  }

  IconData _iconoTipo(TipoComentario t) {
    switch (t) {
      case TipoComentario.sugerencia:
        return Icons.lightbulb_outline;
      case TipoComentario.error:
        return Icons.bug_report_outlined;
      case TipoComentario.felicitacion:
        return Icons.favorite_outline;
      case TipoComentario.otro:
        return Icons.chat_bubble_outline;
    }
  }

  Future<void> _enviar() async {
    if (_mensajeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un mensaje')),
      );
      return;
    }

    setState(() => _enviando = true);

    final prov = context.read<ComentariosProvider>();
    prov.agregarComentario(
      tipo: _tipo,
      mensaje: _mensajeCtrl.text.trim(),
      contacto: _contactoCtrl.text.trim(),
      versionApp: _versionApp,
    );

    // Preparar texto para compartir
    final contacto = _contactoCtrl.text.trim();
    final textoCompartir = 'Comentario desde Horario App\n\n'
        'Tipo: ${_tituloTipo(_tipo)}\n'
        'Versión: $_versionApp\n'
        '${contacto.isNotEmpty ? 'Contacto: $contacto\n' : ''}'
        '\nMensaje:\n${_mensajeCtrl.text.trim()}';

    try {
      await Share.share(
        textoCompartir,
        subject: 'Comentario Horario App - ${_tituloTipo(_tipo)}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comentario guardado y compartido'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comentario guardado (error al compartir: $e)'),
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar comentario'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Tu opinión nos ayuda a mejorar. Cuéntanos qué piensas.',
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // ── Tipo ──
          Text(
            'Tipo de comentario',
            style: TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TipoComentario.values.map((t) {
              final seleccionado = _tipo == t;
              return ChoiceChip(
                avatar: Icon(
                  _iconoTipo(t),
                  size: 18,
                  color: seleccionado ? Colors.white : null,
                ),
                label: Text(
                  _tituloTipo(t),
                  style: TextStyle(fontFamily: fontFamily),
                ),
                selected: seleccionado,
                onSelected: (_) => setState(() => _tipo = t),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Mensaje ──
          Text(
            'Mensaje',
            style: TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _mensajeCtrl,
            maxLines: 6,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText: _tipo == TipoComentario.error
                  ? 'Describe qué pasó y cuándo...'
                  : 'Escribe tu comentario aquí...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
            style: TextStyle(fontFamily: fontFamily),
          ),
          const SizedBox(height: 12),

          // ── Contacto ──
          Text(
            'Contacto (opcional)',
            style: TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _contactoCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'tu@correo.com o @usuario',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            style: TextStyle(fontFamily: fontFamily),
          ),
          const SizedBox(height: 12),

          // ── Info versión ──
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Se adjuntará tu versión de la app ($_versionApp) '
                    'para ayudarnos a reproducir el problema.',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Botón enviar ──
          FilledButton.icon(
            onPressed: _enviando ? null : _enviar,
            icon: _enviando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
            label: Text(
              _enviando ? 'Enviando...' : 'Guardar y compartir',
              style: TextStyle(fontFamily: fontFamily),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'El comentario se guarda localmente en tu historial. '
            'Para enviarlo, puedes compartirlo por correo o mensajería '
            'con el botón de arriba.',
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
