import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/estado_pro_provider.dart';
import '../../providers/theme_provider.dart';
import '../pagina_principal.dart';

class ActivacionPage extends StatefulWidget {
  final bool bloqueante;

  const ActivacionPage({super.key, this.bloqueante = false});

  @override
  State<ActivacionPage> createState() => _ActivacionPageState();
}

class _ActivacionPageState extends State<ActivacionPage> {
  final _ctrl = TextEditingController();
  String? _error;
  bool _activando = false;
  bool _esCodigoBeta = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _activar() async {
    FocusScope.of(context).unfocus();

    final codigo = _ctrl.text.trim();
    if (codigo.isEmpty) {
      setState(() => _error = 'Escribe un código');
      return;
    }

    setState(() {
      _activando = true;
      _error = null;
    });

    final prov = context.read<EstadoProProvider>();

    // Intentar como código beta primero (solo si empieza con BETA)
    if (codigo.toUpperCase().startsWith('BETA-')) {
      final ok = await prov.activarBeta(codigo);
      if (!mounted) return;
      if (ok) {
        await _exito('Modo beta activado');
        return;
      } else {
        setState(() {
          _error = 'Código beta inválido';
          _activando = false;
        });
        return;
      }
    }

    // Intentar como código de licencia normal
    final ok = await prov.activarLicencia(codigo);

    if (!mounted) return;

    if (ok) {
      await _exito('Licencia activada');
    } else {
      setState(() {
        _error = 'Código inválido o ya utilizado';
        _activando = false;
      });
    }
  }

  Future<void> _exito(String mensaje) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('¡Activado!'),
          ],
        ),
        content: Text(
          '$mensaje correctamente.\n\n'
          'Disfruta de todas las funciones de la app.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (widget.bloqueante) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PaginaPrincipal()),
        (route) => false,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;

    return PopScope(
      canPop: !widget.bloqueante,
      child: Scaffold(
        appBar: widget.bloqueante
            ? null
            : AppBar(title: const Text('Activar licencia')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.workspace_premium,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Activa tu licencia',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Introduce el código que recibiste por correo '
                  'después de tu compra.',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _ctrl,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(30),
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[A-Za-z0-9\-]'),
                    ),
                  ],
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    hintText: 'HOR-XXXX-XXXX-XX',
                    hintStyle: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 18,
                      letterSpacing: 2,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                  ),
                  onChanged: (_) {
                    if (_error != null) {
                      setState(() => _error = null);
                    }
                  },
                  onSubmitted: (_) => _activar(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(
                              fontFamily: fontFamily,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _activando ? null : _activar,
                    icon: _activando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.lock_open),
                    label: Text(
                      _activando ? 'Activando...' : 'Activar',
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    setState(() => _esCodigoBeta = !_esCodigoBeta);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _esCodigoBeta
                                  ? '¿Cómo obtener un código?'
                                  : '¿Cómo obtener un código?',
                              style: TextStyle(
                                fontFamily: fontFamily,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Contacta al desarrollador para adquirir '
                          'tu licencia completa. Recibirás un código '
                          'de activación único por correo.',
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.person),
                          title: Text('Leonard Vera'),
                          subtitle: Text('DonMate'),
                        ),
                        const ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.email),
                          title: Text('Contacto'),
                          subtitle: Text('correo@ejemplo.com'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
