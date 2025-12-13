import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';

class TunerPage extends StatefulWidget {
  const TunerPage({super.key});

  @override
  State<TunerPage> createState() => _TunerPageState();
}

class _TunerPageState extends State<TunerPage> {
  FlutterAudioCapture _audioCapture = new FlutterAudioCapture();
  late PitchDetector _pitchDetector;
  double? _detectedPitch = 0.0;
  bool _isCapturing = false;
  final Map<String, double> _ukeleleStrings = {
    'G4': 392.0,
    'C4': 261.63,
    'E4': 329.63,
    'A4': 440.0,
  };

  @override
  void initState() {
    super.initState();
    _audioCapture.init();
    _pitchDetector = PitchDetector(audioSampleRate: 44100, bufferSize: 2048);
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    if (_isCapturing) return;
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      _isCapturing = true;
    } else {
      debugPrint("Permiso de micrófono denegado.");
      _isCapturing = false;
    }
  }

  void _startCapture() async {
    if (_audioCapture == null) {
      _audioCapture = FlutterAudioCapture();
    }
    if (_audioCapture != null) {
      _isCapturing = true;
      await _audioCapture!.start(
        (buffer) async {
          final result = await _pitchDetector.getPitchFromFloatBuffer(buffer);
          if (result.pitched && result.pitch > 80 && result.pitch < 1000) {
            setState(() {
              _detectedPitch = result.pitch;
            });
          }
        },
        (error) {
          debugPrint("Error de audio: $error");
        },
        sampleRate: 44100,
        bufferSize: 2048,
      );
    }
  }

  String _detectarCuerda(double freq) {
    String cuerda = '';
    double minDiff = double.infinity;

    _ukeleleStrings.forEach((key, value) {
      final diff = (freq - value).abs();
      if (diff < minDiff) {
        minDiff = diff;
        cuerda = key;
      }
    });

    return cuerda;
  }

  String _estadoAfinacion(double freq, double ref) {
    const tolerancia = 2.0;
    if ((freq - ref).abs() <= tolerancia) return "Afinada ✅";
    if (freq < ref) return "Muy baja 🔽";
    return "Muy alta 🔼";
  }

  @override
  Widget build(BuildContext context) {
    final cuerda = _detectarCuerda(_detectedPitch!);
    final ref = _ukeleleStrings[cuerda] ?? 0.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Afinador de ukelele')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              cuerda,
              style: const TextStyle(fontSize: 90, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "${_detectedPitch!.toStringAsFixed(2)} Hz",
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(height: 20),
            Text(
              ref == 0 ? "" : _estadoAfinacion(_detectedPitch!, ref),
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isCapturing ? _stopCapture : _startCapture,
                child: Text(
                  _isCapturing ? 'Detener captura' : 'Iniciar Afinador',
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const SizedBox(
        height: 50,
        child: Center(
          child: Text(
            'Desarrollado por Chepita Apps y Felipe © 2025',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  Future<void> _stopCapture() async {
    await _audioCapture.stop();
    _isCapturing = false;
  }

  @override
  void dispose() {
    _audioCapture!.stop();
    super.dispose();
  }
}
