import 'dart:io';

import 'package:flutter/foundation.dart';

// ═══════════════════════════════════════════════════════════════
// REGIONES Y PRECIOS (Fase 17.5)
// ═══════════════════════════════════════════════════════════════

enum RegionPrecio {
  venezuela,
  latam,
  espana,
  internacional,
}

extension RegionPrecioExt on RegionPrecio {
  String get nombre {
    switch (this) {
      case RegionPrecio.venezuela:
        return 'Venezuela';
      case RegionPrecio.latam:
        return 'Latinoamérica';
      case RegionPrecio.espana:
        return 'España';
      case RegionPrecio.internacional:
        return 'Internacional';
    }
  }

  int get precioUSD {
    switch (this) {
      case RegionPrecio.venezuela:
        return 5;
      case RegionPrecio.latam:
        return 8;
      case RegionPrecio.espana:
        return 10;
      case RegionPrecio.internacional:
        return 15;
    }
  }

  String get moneda {
    switch (this) {
      case RegionPrecio.espana:
        return 'EUR';
      default:
        return 'USD';
    }
  }

  /// Ej: "$5 USD" o "$10 EUR"
  String get etiquetaPrecio => '\$${precioUSD} $moneda';
}

// ═══════════════════════════════════════════════════════════════
// SERVICIO DE PRECIOS
// ═══════════════════════════════════════════════════════════════

class PreciosService {
  /// TODO 17.4: poner en `true` cuando el co-dev cree la cuenta y las URLs.
  static const bool _checkoutConfigurado = false;

  /// TODO 17.4: reemplazar por las URLs reales de Lemon Squeezy.
  static const Map<RegionPrecio, String> _urlsCheckout = {
    RegionPrecio.venezuela:
        'https://donmate.lemonsqueezy.com/checkout/buy/PLACEHOLDER-VE',
    RegionPrecio.latam:
        'https://donmate.lemonsqueezy.com/checkout/buy/PLACEHOLDER-LATAM',
    RegionPrecio.espana:
        'https://donmate.lemonsqueezy.com/checkout/buy/PLACEHOLDER-ES',
    RegionPrecio.internacional:
        'https://donmate.lemonsqueezy.com/checkout/buy/PLACEHOLDER-INTL',
  };

  /// Mapa país ISO 3166-1 alpha-2 → región de precio.
  static const Map<String, RegionPrecio> _paisARegion = {
    // Venezuela
    'VE': RegionPrecio.venezuela,

    // Latinoamérica
    'MX': RegionPrecio.latam,
    'CO': RegionPrecio.latam,
    'AR': RegionPrecio.latam,
    'CL': RegionPrecio.latam,
    'PE': RegionPrecio.latam,
    'EC': RegionPrecio.latam,
    'BO': RegionPrecio.latam,
    'PY': RegionPrecio.latam,
    'UY': RegionPrecio.latam,
    'CR': RegionPrecio.latam,
    'PA': RegionPrecio.latam,
    'GT': RegionPrecio.latam,
    'DO': RegionPrecio.latam,
    'HN': RegionPrecio.latam,
    'SV': RegionPrecio.latam,
    'NI': RegionPrecio.latam,
    'CU': RegionPrecio.latam,
    'PR': RegionPrecio.latam,

    // España
    'ES': RegionPrecio.espana,
  };

  /// Detecta la región usando el locale del dispositivo.
  /// Ej: "es_VE" → Venezuela, "en_US" → internacional.
  static RegionPrecio detectar() {
    try {
      final locale = Platform.localeName;
      final partes = locale.split('_');
      if (partes.length >= 2) {
        return paraPais(partes[1]);
      }
    } catch (e) {
      debugPrint('💵 [Precios] No se pudo detectar locale: $e');
    }
    return RegionPrecio.internacional;
  }

  /// Devuelve la región para un código de país ISO (ej. "VE", "MX").
  static RegionPrecio paraPais(String codigoPais) {
    return _paisARegion[codigoPais.toUpperCase()] ?? RegionPrecio.internacional;
  }

  /// ¿Está configurado el checkout? (false hasta que el co-dev cree la cuenta)
  static bool get checkoutConfigurado => _checkoutConfigurado;

  /// Devuelve la URL de checkout para la región, o `null` si no configurada.
  static String? urlCheckout(RegionPrecio region) {
    if (!_checkoutConfigurado) return null;
    return _urlsCheckout[region];
  }
}
