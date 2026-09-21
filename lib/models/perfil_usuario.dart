import 'package:flutter/foundation.dart';

enum EstiloVida {
  sedentario,
  ligero,
  activo,
  deportista,
}

enum Sexo {
  noEspecificado,
  masculino,
  femenino,
  otro,
}

enum Condicion {
  ninguna,
  embarazo,
  lactancia,
  recuperacion,
  cronica,
  discapacidad,
}

class PerfilUsuario {
  // Datos básicos
  String nombre;
  int edad;
  Sexo sexo;
  double pesoKg;
  double alturaCm;

  // Estilo de vida
  EstiloVida estiloVida;

  // Salud
  Set<String> enfermedades;
  Set<String> alergias;
  Set<Condicion> condiciones;

  // Notas libres
  String notas;

  PerfilUsuario({
    this.nombre = '',
    this.edad = 0,
    this.sexo = Sexo.noEspecificado,
    this.pesoKg = 0,
    this.alturaCm = 0,
    this.estiloVida = EstiloVida.sedentario,
    Set<String>? enfermedades,
    Set<String>? alergias,
    Set<Condicion>? condiciones,
    this.notas = '',
  })  : enfermedades = enfermedades ?? {},
        alergias = alergias ?? {},
        condiciones = condiciones ?? {};

  /// Devuelve true si el usuario ha rellenado algún dato relevante.
  bool get estaCompleto =>
      nombre.isNotEmpty ||
      edad > 0 ||
      estiloVida != EstiloVida.sedentario ||
      enfermedades.isNotEmpty ||
      alergias.isNotEmpty ||
      condiciones.isNotEmpty;

  /// Índice de Masa Corporal (kg / m²). 0 si no hay datos.
  double get imc {
    if (pesoKg <= 0 || alturaCm <= 0) return 0;
    final alturaM = alturaCm / 100;
    return pesoKg / (alturaM * alturaM);
  }

  /// Categoría del IMC.
  String get categoriaImc {
    if (imc == 0) return 'Sin datos';
    if (imc < 18.5) return 'Bajo peso';
    if (imc < 25) return 'Peso normal';
    if (imc < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'edad': edad,
        'sexo': sexo.name,
        'pesoKg': pesoKg,
        'alturaCm': alturaCm,
        'estiloVida': estiloVida.name,
        'enfermedades': enfermedades.toList(),
        'alergias': alergias.toList(),
        'condiciones': condiciones.map((c) => c.name).toList(),
        'notas': notas,
      };

  factory PerfilUsuario.fromJson(Map<String, dynamic> json) {
    return PerfilUsuario(
      nombre: json['nombre'] ?? '',
      edad: json['edad'] ?? 0,
      sexo: Sexo.values.firstWhere(
        (s) => s.name == json['sexo'],
        orElse: () => Sexo.noEspecificado,
      ),
      pesoKg: (json['pesoKg'] as num?)?.toDouble() ?? 0,
      alturaCm: (json['alturaCm'] as num?)?.toDouble() ?? 0,
      estiloVida: EstiloVida.values.firstWhere(
        (e) => e.name == json['estiloVida'],
        orElse: () => EstiloVida.sedentario,
      ),
      enfermedades: Set<String>.from(json['enfermedades'] ?? []),
      alergias: Set<String>.from(json['alergias'] ?? []),
      condiciones: (json['condiciones'] as List?)
              ?.map((c) => Condicion.values.firstWhere(
                    (v) => v.name == c,
                    orElse: () => Condicion.ninguna,
                  ))
              .toSet() ??
          {},
      notas: json['notas'] ?? '',
    );
  }
}
