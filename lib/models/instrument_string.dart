import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:app_chepita_afinador/theme/app_theme.dart';

enum TuningStatus {
  silent,
  flat,
  inTune,
  sharp;

  String get label {
    switch (this) {
      case TuningStatus.silent:
        return 'Toca una cuerda';
      case TuningStatus.flat:
        return 'Muy baja (Tensa la clavija)';
      case TuningStatus.inTune:
        return '¡Afinada!';
      case TuningStatus.sharp:
        return 'Muy alta (Afloja la clavija)';
    }
  }

  Color get color {
    switch (this) {
      case TuningStatus.silent:
        return AppTheme.idle;
      case TuningStatus.flat:
        return AppTheme.flat;
      case TuningStatus.inTune:
        return AppTheme.tuned;
      case TuningStatus.sharp:
        return AppTheme.sharp;
    }
  }

  Color get glowColor {
    switch (this) {
      case TuningStatus.silent:
        return Colors.transparent;
      case TuningStatus.flat:
        return AppTheme.flatGlow;
      case TuningStatus.inTune:
        return AppTheme.tunedGlow;
      case TuningStatus.sharp:
        return AppTheme.sharpGlow;
    }
  }

  IconData get icon {
    switch (this) {
      case TuningStatus.silent:
        return Icons.graphic_eq_rounded;
      case TuningStatus.flat:
        return Icons.arrow_upward_rounded; // Tocar hacia arriba / tensar
      case TuningStatus.inTune:
        return Icons.check_circle_rounded;
      case TuningStatus.sharp:
        return Icons.arrow_downward_rounded; // Tocar hacia abajo / aflojar
    }
  }
}

class InstrumentString {
  final String id; // ej. "G4"
  final String noteName; // ej. "Sol"
  final int stringIndex; // 4, 3, 2, 1
  final double frequency; // Frecuencia fundamental en Hz

  const InstrumentString({
    required this.id,
    required this.noteName,
    required this.stringIndex,
    required this.frequency,
  });

  /// Afinación estándar de Ukelele Soprano / Concierto / Tenor (G4-C4-E4-A4)
  static const List<InstrumentString> ukeleleStandard = [
    InstrumentString(id: 'G4', noteName: 'Sol', stringIndex: 4, frequency: 392.00),
    InstrumentString(id: 'C4', noteName: 'Do', stringIndex: 3, frequency: 261.63),
    InstrumentString(id: 'E4', noteName: 'Mi', stringIndex: 2, frequency: 329.63),
    InstrumentString(id: 'A4', noteName: 'La', stringIndex: 1, frequency: 440.00),
  ];

  /// Calcula la desviación en Cents entre la frecuencia medida y la de referencia.
  /// 1 semitono = 100 cents. Rango visual habitual: -50 a +50 cents.
  static double calculateCents(double detectedFreq, double targetFreq) {
    if (detectedFreq <= 0 || targetFreq <= 0) return 0.0;
    final cents = 1200.0 * (math.log(detectedFreq / targetFreq) / math.ln2);
    return cents.clamp(-50.0, 50.0);
  }

  /// Determina el estado de afinación dado el desvío en cents y la tolerancia (por defecto +/- 4.0 cents).
  static TuningStatus determineStatus(double cents, {double tolerance = 4.0, bool hasSignal = true}) {
    if (!hasSignal) return TuningStatus.silent;
    if (cents.abs() <= tolerance) return TuningStatus.inTune;
    if (cents < -tolerance) return TuningStatus.flat;
    return TuningStatus.sharp;
  }

  /// Encuentra la cuerda más cercana por ratio logarítmico (menor distancia en cents).
  static InstrumentString findClosest(double detectedFreq, {List<InstrumentString> strings = ukeleleStandard}) {
    if (detectedFreq <= 0) return strings.first;

    InstrumentString closest = strings.first;
    double minCentsDistance = double.infinity;

    for (final string in strings) {
      final distance = (calculateCents(detectedFreq, string.frequency)).abs();
      if (distance < minCentsDistance) {
        minCentsDistance = distance;
        closest = string;
      }
    }

    return closest;
  }
}
