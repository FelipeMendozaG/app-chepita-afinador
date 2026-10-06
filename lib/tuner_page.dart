import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:app_chepita_afinador/models/instrument_string.dart';
import 'package:app_chepita_afinador/theme/app_theme.dart';
import 'package:app_chepita_afinador/widgets/string_selector.dart';
import 'package:app_chepita_afinador/widgets/tuner_gauge.dart';

class TunerPage extends StatefulWidget {
  const TunerPage({super.key});

  @override
  State<TunerPage> createState() => _TunerPageState();
}

class _TunerPageState extends State<TunerPage> {
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  late final PitchDetector _pitchDetector;

  double _detectedPitch = 0.0;
  bool _isCapturing = false;
  bool _hasSignal = false;
  bool _wasInTune = false;
  bool _isAutoMode = true;
  PermissionStatus _micPermissionStatus = PermissionStatus.denied;

  InstrumentString _targetString = InstrumentString.ukeleleStandard.first;
  Timer? _signalDecayTimer;

  @override
  void initState() {
    super.initState();
    _pitchDetector = PitchDetector(audioSampleRate: 44100, bufferSize: 2048);
    _initializeTuner();
  }

  Future<void> _initializeTuner() async {
    await _audioCapture.init();
    await _checkPermissionAndStart();
  }

  Future<void> _checkPermissionAndStart() async {
    final status = await Permission.microphone.request();
    if (!mounted) return;

    setState(() {
      _micPermissionStatus = status;
    });

    if (status.isGranted) {
      await _startCapture();
    }
  }

  Future<void> _startCapture() async {
    if (_isCapturing) return;

    try {
      await _audioCapture.start(
        _onAudioBuffer,
        _onAudioError,
        sampleRate: 44100,
        bufferSize: 2048,
      );

      if (mounted) {
        setState(() {
          _isCapturing = true;
        });
      }
    } catch (e) {
      debugPrint("Error al iniciar captura de audio: $e");
    }
  }

  void _onAudioBuffer(dynamic buffer) async {
    final result = await _pitchDetector.getPitchFromFloatBuffer(buffer);

    if (result.pitched && result.pitch > 80 && result.pitch < 1000) {
      if (!mounted) return;

      final currentString = _isAutoMode
          ? InstrumentString.findClosest(result.pitch)
          : _targetString;

      final currentCents = InstrumentString.calculateCents(
        result.pitch,
        currentString.frequency,
      );
      final currentStatus = InstrumentString.determineStatus(
        currentCents,
        hasSignal: true,
      );

      // Respuesta háptica al afinar con precisión
      if (currentStatus == TuningStatus.inTune && !_wasInTune) {
        HapticFeedback.mediumImpact();
        _wasInTune = true;
      } else if (currentStatus != TuningStatus.inTune) {
        _wasInTune = false;
      }

      setState(() {
        _detectedPitch = result.pitch;
        _targetString = currentString;
        _hasSignal = true;
      });

      // Temporizador de decaimiento tras silencio (1.2 segundos)
      _signalDecayTimer?.cancel();
      _signalDecayTimer = Timer(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _hasSignal = false;
            _wasInTune = false;
          });
        }
      });
    }
  }

  void _onAudioError(Object error) {
    debugPrint("Error de audio capturado: $error");
  }

  Future<void> _stopCapture() async {
    if (!_isCapturing) return;

    await _audioCapture.stop();
    _signalDecayTimer?.cancel();

    if (mounted) {
      setState(() {
        _isCapturing = false;
        _hasSignal = false;
        _wasInTune = false;
      });
    }
  }

  void _toggleCapture() {
    HapticFeedback.selectionClick();
    if (_isCapturing) {
      _stopCapture();
    } else {
      if (_micPermissionStatus.isGranted) {
        _startCapture();
      } else {
        _checkPermissionAndStart();
      }
    }
  }

  void _onSelectString(InstrumentString string) {
    setState(() {
      _targetString = string;
      _isAutoMode = false; // Al tocar una cuerda pasa a modo manual
    });
  }

  void _toggleAutoMode() {
    setState(() {
      _isAutoMode = !_isAutoMode;
    });
  }

  @override
  void dispose() {
    _signalDecayTimer?.cancel();
    _audioCapture.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cents = _hasSignal
        ? InstrumentString.calculateCents(_detectedPitch, _targetString.frequency)
        : 0.0;
    final status = InstrumentString.determineStatus(cents, hasSignal: _hasSignal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chepita Afinador'),
        actions: [
          IconButton(
            tooltip: _isCapturing ? 'Pausar micrófono' : 'Activar micrófono',
            icon: Icon(
              _isCapturing ? Icons.mic_rounded : Icons.mic_off_rounded,
              color: _isCapturing ? AppTheme.tuned : AppTheme.textMuted,
            ),
            onPressed: _toggleCapture,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        // Selector interactivo de cuerdas (G4, C4, E4, A4)
                        StringSelectorRow(
                          strings: InstrumentString.ukeleleStandard,
                          selectedString: _targetString,
                          isAutoMode: _isAutoMode,
                          onSelectString: _onSelectString,
                          onToggleAuto: _toggleAutoMode,
                        ),

                        const SizedBox(height: 16),

                        // Medidor semicircular analógico (Gauge) con aguja animada
                        TunerGauge(
                          cents: cents,
                          status: status,
                          hasSignal: _hasSignal,
                        ),

                        const SizedBox(height: 8),

                        // Nota y Cuerda activa destacada
                        _buildNoteDisplay(status),

                        const SizedBox(height: 12),

                        // Badge dinámico de estado (¡Afinada!, Muy baja, Muy alta)
                        _buildStatusBadge(status),

                        const SizedBox(height: 16),

                        // Panel de datos acústicos (Frecuencia en Hz y Cents)
                        _buildMetricsPanel(cents),
                      ],
                    ),

                    Column(
                      children: [
                        const SizedBox(height: 16),

                        // Banner de permisos en caso de error
                        if (!_micPermissionStatus.isGranted)
                          _buildPermissionWarning(),

                        // Botón de acción principal
                        _buildActionButton(),

                        const SizedBox(height: 12),

                        // Pie de página
                        Text(
                          'Ukelele Estándar (G4 · C4 · E4 · A4) · Chepita Apps © 2025',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoteDisplay(TuningStatus status) {
    return Column(
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w900,
            color: _hasSignal ? status.color : AppTheme.textMuted,
            height: 1.0,
            shadows: _hasSignal
                ? [
                    Shadow(
                      color: status.glowColor,
                      blurRadius: 24,
                    ),
                  ]
                : null,
          ),
          child: Text(_hasSignal ? _targetString.id : '--'),
        ),
        const SizedBox(height: 4),
        Text(
          _hasSignal
              ? '${_targetString.noteName} (Cuerda ${_targetString.stringIndex})'
              : 'Toca una cuerda para escuchar...',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(TuningStatus status) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: status.color.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, color: status.color, size: 18),
          const SizedBox(width: 8),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsPanel(double cents) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem(
            label: 'FRECUENCIA',
            value: _hasSignal ? '${_detectedPitch.toStringAsFixed(1)} Hz' : '-- Hz',
            detail: _hasSignal ? 'Ref: ${_targetString.frequency.toStringAsFixed(1)} Hz' : 'En espera',
          ),
          Container(width: 1, height: 32, color: AppTheme.border),
          _buildMetricItem(
            label: 'DESVIACIÓN',
            value: _hasSignal
                ? '${cents >= 0 ? '+' : ''}${cents.toStringAsFixed(1)} ¢'
                : '-- ¢',
            detail: _hasSignal
                ? (cents.abs() <= 4 ? 'Tolerancia ±4¢' : 'Ajustar tensión')
                : 'En espera',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required String detail,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMuted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          detail,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.sharp.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.sharp, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.sharp),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Se requiere permiso de micrófono para afinar.',
              style: TextStyle(fontSize: 12, color: AppTheme.textPrimary),
            ),
          ),
          TextButton(
            onPressed: () => openAppSettings(),
            child: const Text('AJUSTES', style: TextStyle(color: AppTheme.sharp, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _toggleCapture,
        icon: Icon(
          _isCapturing ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: 24,
        ),
        label: Text(_isCapturing ? 'Pausar Afinador' : 'Iniciar Afinador'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isCapturing ? AppTheme.surfaceHighlight : AppTheme.tuned,
          foregroundColor: _isCapturing ? AppTheme.textPrimary : Colors.black,
          side: _isCapturing ? const BorderSide(color: AppTheme.border) : BorderSide.none,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
