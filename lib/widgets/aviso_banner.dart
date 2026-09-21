import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/aviso.dart';
import '../providers/avisos_provider.dart';
import '../providers/theme_provider.dart';

class AvisoBannerStack extends StatelessWidget {
  final Widget child;

  const AvisoBannerStack({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // Los banners se muestran encima del contenido
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Consumer<AvisosProvider>(
            builder: (context, prov, _) {
              if (prov.avisosActivos.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: prov.avisosActivos
                    .map((a) => _AvisoBanner(aviso: a))
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AvisoBanner extends StatefulWidget {
  final Aviso aviso;

  const _AvisoBanner({required this.aviso});

  @override
  State<_AvisoBanner> createState() => _AvisoBannerState();
}

class _AvisoBannerState extends State<_AvisoBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;
    final color = widget.aviso.color(context);

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              color: color,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  context.read<AvisosProvider>().descartar(widget.aviso.id);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.aviso.icono,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.aviso.mensaje,
                          style: TextStyle(
                            fontFamily: fontFamily,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          context
                              .read<AvisosProvider>()
                              .descartar(widget.aviso.id);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
