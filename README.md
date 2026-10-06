# 🎸 Chepita Afinador (Afinador CHP)

[![Flutter](https://img.shields.io/badge/Flutter-^3.7.2-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green)](https://flutter.dev)
[![Linter](https://img.shields.io/badge/Linter-flutter__lints%205.0.0-blue)](https://pub.dev/packages/flutter_lints)

Una aplicación móvil moderna, precisa e intuitiva desarrollada en **Flutter** para la afinación en tiempo real de instrumentos de cuerda mediante el micrófono del dispositivo. Diseñada específicamente para **Ukelele** con afinación estándar y una estética oscura premium.

---

## ✨ Características Principales

* 🎙️ **Detección de Tono en Tiempo Real (DSP):** Procesa el audio capturado a 44.1 kHz mediante un buffer PCM Float32 para extraer la frecuencia fundamental ($f_0$) al instante.
* 🎼 **Afinación Estándar de Ukelele:**
  * **Cuerda 4:** G4 (Sol) &mdash; `392.00 Hz`
  * **Cuerda 3:** C4 (Do) &mdash; `261.63 Hz`
  * **Cuerda 2:** E4 (Mi) &mdash; `329.63 Hz`
  * **Cuerda 1:** A4 (La) &mdash; `440.00 Hz`
* 🔄 **Modo Automático y Selección Manual:**
  * **Automático:** Detecta y resalta por sí solo la cuerda más cercana calculando la menor distancia en *cents*.
  * **Manual:** Permite fijar una cuerda específica tocando los botones del selector.
* 🧭 **Indicador Analógico de Aguja (`TunerGauge`):** Dial semicircular de alta precisión graduado de `-50¢` a `+50¢` con aguja animada suave y arco de tolerancia.
* 📳 **Respuesta Háptica:** Retroalimentación táctil (`HapticFeedback.mediumImpact()`) en el momento exacto en que la cuerda queda afinada.
* 📊 **Panel de Métricas Acústicas:** Lectura en tiempo real de frecuencia en hercios (`Hz`), frecuencia de referencia y desviación exacta en cents (`¢`).
* 🎨 **Diseño Moderno "Dark Acústica":** Paleta oscura de alto contraste con retroiluminación dinámica de estados:
  * 🟢 **¡Afinada!** (Verde esmeralda neón dentro del rango de $\pm 4.0¢$).
  * 🟡 **Muy baja** (Ámbar &mdash; tensa la clavija).
  * 🔴 **Muy alta** (Rojo coral &mdash; afloja la clavija).
* 🛡️ **Manejo Seguro de Recursos y Permisos:** Control reactivo del permiso de micrófono y liberación de memoria y hardware en segundo plano o al pausar.

---

## 🛠️ Stack Tecnológico

| Capa / Módulo | Paquete / Tecnología | Propósito |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) | Framework multiplataforma reactivo |
| **Lenguaje** | [Dart](https://dart.dev) | Lenguaje con Sound Null-Safety |
| **Captura de Audio** | [`flutter_audio_capture`](https://pub.dev/packages/flutter_audio_capture) | Flujo de audio PCM en tiempo real del micrófono |
| **Procesamiento de Señal** | [`pitch_detector_dart`](https://pub.dev/packages/pitch_detector_dart) | Algoritmo de detección de tono ($f_0$) sobre buffer flotante |
| **Permisos** | [`permission_handler`](https://pub.dev/packages/permission_handler) | Gestión y verificación de permisos de micrófono |
| **Branding & Assets** | [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) | Generación automática de iconos de aplicación |
| **Análisis de Código** | [`flutter_lints`](https://pub.dev/packages/flutter_lints) | Reglas oficiales de calidad y linter de Flutter |

---

## 📁 Estructura del Proyecto

```text
app-chepita-afinador/
├── android/                     # Configuración y manifests de Android
├── assets/
│   └── icon/
│       └── icono_afinador.png   # Icono oficial de la app
├── ios/                         # Configuración nativa de iOS (Info.plist)
├── lib/
│   ├── main.dart                # Punto de entrada de la aplicación
│   ├── tuner_page.dart          # Pantalla principal y ciclo de vida de captura de audio
│   ├── models/
│   │   └── instrument_string.dart # Modelos de cuerdas, cálculo logarítmico de cents y estados
│   ├── theme/
│   │   └── app_theme.dart       # Paleta "Dark Acústica", tipografía y estilos
│   └── widgets/
│       ├── string_selector.dart # Selector táctil interactivo y toggle Auto/Manual
│       └── tuner_gauge.dart     # Widget de aguja analógica personalizada (CustomPainter)
├── pubspec.yaml                 # Configuración del paquete y dependencias
└── README.md                    # Este archivo
```

---

## 🚀 Instalación y Puesta en Marcha

### 1. Requisitos Previos

* [Flutter SDK](https://flutter.dev/docs/get-started/install) (versión `>=3.7.2`)
* [Dart SDK](https://dart.dev/get-dart)
* Dispositivo físico o emulador configurado con soporte de entrada de micrófono (Android Studio / Xcode / VS Code).

### 2. Clonar el Repositorio

```bash
git clone https://github.com/FelipeMendozaG/app-chepita-afinador.git
cd app-chepita-afinador
```

### 3. Instalar Dependencias

```bash
flutter pub get
```

### 4. Ejecutar la Aplicación

Conecta tu dispositivo móvil o inicia un emulador y ejecuta:

```bash
flutter run
```

---

## 💻 Comandos Útiles de Desarrollo

```bash
# Comprobar análisis estático de código
flutter analyze

# Dar formato al código Dart según las directrices oficiales
dart format .

# Ejecutar pruebas automáticas
flutter test

# Compilar instalador APK para Android (Release)
flutter build apk --release

# Compilar Android App Bundle para Google Play Store
flutter build appbundle --release

# Regenerar iconos de la aplicación
dart run flutter_launcher_icons
```

---

## 🔒 Permisos del Sistema

Para el correcto funcionamiento del afinador en tiempo real se requieren los permisos de captura de audio:

* **Android:** Se declara `android.permission.RECORD_AUDIO` en `AndroidManifest.xml`.
* **iOS:** Se incluye la descripción en `ios/Runner/Info.plist` bajo la clave `NSMicrophoneUsageDescription`.

La app comprueba y solicita los permisos de forma reactiva al iniciar, ofreciendo acceso directo a los ajustes del sistema si el permiso es denegado.

---

## 📄 Licencia

Desarrollado con ❤️ por **Chepita Apps** © 2025. Todos los derechos reservados.