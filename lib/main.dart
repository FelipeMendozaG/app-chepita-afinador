import 'package:flutter/material.dart';
import 'package:app_chepita_afinador/theme/app_theme.dart';
import 'package:app_chepita_afinador/tuner_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afinador CHP',
      theme: AppTheme.darkTheme,
      home: const TunerPage(),
    );
  }
}
