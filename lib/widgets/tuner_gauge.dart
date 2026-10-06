import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:app_chepita_afinador/models/instrument_string.dart';
import 'package:app_chepita_afinador/theme/app_theme.dart';

class TunerGauge extends StatelessWidget {
  final double cents; // -50.0 a +50.0
  final TuningStatus status;
  final bool hasSignal;

  const TunerGauge({
    super.key,
    required this.cents,
    required this.status,
    required this.hasSignal,
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay señal, la aguja reposa en el centro (0) o amortigua suavemente
    final targetCents = hasSignal ? cents.clamp(-50.0, 50.0) : 0.0;

    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: targetCents),
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        builder: (context, animatedCents, child) {
          return SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _GaugePainter(
                cents: animatedCents,
                status: status,
                hasSignal: hasSignal,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double cents;
  final TuningStatus status;
  final bool hasSignal;

  _GaugePainter({
    required this.cents,
    required this.status,
    required this.hasSignal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.95);
    final radius = size.width * 0.44;

    // Ángulos del arco: de -140° a -40° (arco superior de 100°)
    const startAngle = -math.pi * 0.85;
    const sweepAngle = math.pi * 0.70;

    final baseArcPaint = Paint()
      ..color = AppTheme.border.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      baseArcPaint,
    );

    // Zona verde central de tolerancia (+/- 4 cents)
    const toleranceAngleFraction = 4.0 / 50.0;
    final midAngle = startAngle + sweepAngle / 2;
    final inTuneSpan = (sweepAngle / 2) * toleranceAngleFraction;

    final inTunePaint = Paint()
      ..color = AppTheme.tuned.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      midAngle - inTuneSpan,
      inTuneSpan * 2,
      false,
      inTunePaint,
    );

    // Marcas de escala y números (-40, -20, 0, +20, +40)
    final tickPaint = Paint()
      ..color = AppTheme.textMuted
      ..strokeWidth = 2.0;

    final majorTickPaint = Paint()
      ..color = AppTheme.textSecondary
      ..strokeWidth = 3.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int tick = -50; tick <= 50; tick += 10) {
      final fraction = (tick + 50) / 100.0;
      final angle = startAngle + sweepAngle * fraction;

      final isMajor = tick % 20 == 0;
      final isCenter = tick == 0;
      final tickLength = isCenter ? 14.0 : (isMajor ? 10.0 : 6.0);

      final outerX = center.dx + radius * math.cos(angle);
      final outerY = center.dy + radius * math.sin(angle);

      final innerX = center.dx + (radius - tickLength) * math.cos(angle);
      final innerY = center.dy + (radius - tickLength) * math.sin(angle);

      Paint currentTickPaint = isMajor ? majorTickPaint : tickPaint;
      if (isCenter) {
        currentTickPaint = Paint()
          ..color = AppTheme.tuned
          ..strokeWidth = 3.5;
      }

      canvas.drawLine(
        Offset(innerX, innerY),
        Offset(outerX, outerY),
        currentTickPaint,
      );

      // Etiquetas numéricas para -40, 0, +40
      if (tick == -40 || tick == 0 || tick == 40) {
        final labelText = tick == 0 ? '0' : (tick > 0 ? '+$tick' : '$tick');
        textPainter.text = TextSpan(
          text: labelText,
          style: TextStyle(
            color: isCenter
                ? (hasSignal && status == TuningStatus.inTune
                    ? AppTheme.tuned
                    : AppTheme.textSecondary)
                : AppTheme.textMuted,
            fontSize: 10,
            fontWeight: isCenter ? FontWeight.bold : FontWeight.w500,
          ),
        );
        textPainter.layout();

        final labelRadius = radius - tickLength - 12;
        final labelX = center.dx + labelRadius * math.cos(angle) - textPainter.width / 2;
        final labelY = center.dy + labelRadius * math.sin(angle) - textPainter.height / 2;

        textPainter.paint(canvas, Offset(labelX, labelY));
      }
    }

    // Dibujar Aguja Indicadora (Needle)
    final needleFraction = (cents + 50) / 100.0;
    final needleAngle = startAngle + sweepAngle * needleFraction;

    final needleLength = radius - 8;
    final tipX = center.dx + needleLength * math.cos(needleAngle);
    final tipY = center.dy + needleLength * math.sin(needleAngle);

    final needleColor = hasSignal ? status.color : AppTheme.textMuted;

    // Resplandor de la punta de la aguja si hay señal
    if (hasSignal) {
      final glowPaint = Paint()
        ..color = status.glowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(tipX, tipY), 9, glowPaint);
    }

    // Trazo de la aguja
    final needlePaint = Paint()
      ..color = needleColor
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, Offset(tipX, tipY), needlePaint);

    // Punta circular de la aguja
    final tipCirclePaint = Paint()..color = needleColor;
    canvas.drawCircle(Offset(tipX, tipY), 4.5, tipCirclePaint);

    // Pivote central
    final pivotOuterPaint = Paint()..color = AppTheme.surfaceHighlight;
    canvas.drawCircle(center, 9, pivotOuterPaint);

    final pivotInnerPaint = Paint()..color = needleColor;
    canvas.drawCircle(center, 4.5, pivotInnerPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.cents != cents ||
        oldDelegate.status != status ||
        oldDelegate.hasSignal != hasSignal;
  }
}
