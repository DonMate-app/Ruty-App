import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/notificaciones_prefs_provider.dart';
import '../../services/alarma_service.dart';
import '../../services/notification_service.dart';

class AlarmaPage extends StatefulWidget {
  final String categoria;
  final String payload;

  /// Si se pasan estos datos, la página inicia la alarma ella misma.
  /// Si son null, asume que ya está sonando algo.
  final String? sonidoInicial;
  final String? tituloInicial;
  final String? cuerpoInicial;
  final bool? vibrarInicial;

  const AlarmaPage({
    super.key,
    required this.categoria,
    required this.payload,
    this.sonidoInicial,
    this.tituloInicial,
    this.cuerpoInicial,
    this.vibrarInicial,
  });

  @override
  State<AlarmaPage> createState() => _AlarmaPageState();
}

class _AlarmaPageState extends State<AlarmaPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _iniciando = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Iniciar la alarma DESPUÉS de que la pantalla esté montada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _iniciarSiEsNecesario();
    });
  }

  Future<void> _iniciarSiEsNecesario() async {
    final alarma = context.read<AlarmaService>();

    // Si ya está reproduciendo, no hacer nada
    if (alarma.reproduciendo) return;

    // Si no tenemos datos para iniciar, no hacer nada
    if (widget.sonidoInicial == null) return;

    if (mounted) setState(() => _iniciando = true);

    await alarma.iniciar(
      sonido: widget.sonidoInicial!,
      payload: widget.payload,
      titulo: widget.tituloInicial ?? 'Alarma',
      cuerpo: widget.cuerpoInicial ?? '',
      vibrar: widget.vibrarInicial ?? true,
    );

    if (mounted) setState(() => _iniciando = false);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _detener() async {
    await context.read<AlarmaService>().detener();

    final callback = NotificationService().onAccion;
    callback?.call('tomado', widget.payload);

    if (mounted) Navigator.pop(context);
  }

  Future<void> _posponer() async {
    final alarma = context.read<AlarmaService>();
    final payload = alarma.payloadActual ?? widget.payload;

    // Leer minutos de snooze
    final prefs = context.read<NotificacionesPrefsProvider>();
    final minutos = prefs.getPref(widget.categoria).snoozeMinutos;

    await alarma.detener();

    // Llamar al callback con posponer
    final callback = NotificationService().onAccion;
    callback?.call('posponer:$minutos', payload);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alarma = context.watch<AlarmaService>();
    final titulo = alarma.tituloActual ?? widget.tituloInicial ?? 'Alarma';
    final cuerpo = alarma.cuerpoActual ?? widget.cuerpoInicial ?? '';

    return Scaffold(
      backgroundColor: theme.colorScheme.error,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Icono pulsante
              ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.1).animate(
                  CurvedAnimation(
                    parent: _pulseController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.alarm,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Título
              Text(
                titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Cuerpo
              if (cuerpo.isNotEmpty)
                Text(
                  cuerpo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),

              // Indicador de "iniciando sonido"
              if (_iniciando) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Preparando sonido...',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],

              const Spacer(),

              // Botón Posponer
              _botonGrande(
                icono: Icons.snooze,
                texto: 'Posponer',
                onTap: _posponer,
                color: Colors.orange.shade700,
              ),
              const SizedBox(height: 16),

              // Botón Detener
              _botonGrande(
                icono: Icons.stop_circle,
                texto: 'Detener',
                onTap: _detener,
                color: Colors.white,
                colorTexto: Colors.red.shade700,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _botonGrande({
    required IconData icono,
    required String texto,
    required VoidCallback onTap,
    required Color color,
    Color colorTexto = Colors.white,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: colorTexto,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onTap,
        icon: Icon(icono, size: 32),
        label: Text(
          texto,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
