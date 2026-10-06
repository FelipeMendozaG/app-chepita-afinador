# 🤖 AGENTS.md — Guía de Arquitectura, Tecnologías y Reglas de Desarrollo

Bienvenido al repositorio **Afinador CHP (`app_chepita_afinador`)**. Este documento establece el contexto técnico, la arquitectura de software, las directrices de estilo y los comandos operacionales para que cualquier agente de IA o desarrollador pueda comprender y extender el proyecto de forma consistente.

---

## 1. 📌 Información General del Proyecto

* **Nombre del Paquete:** `app_chepita_afinador`
* **Nombre Comercial / UI:** Afinador CHP / Chepita Afinador
* **Propósito:** Aplicación móvil multiplataforma desarrollada en Flutter para afinación precisa de instrumentos de cuerda en tiempo real mediante el micrófono del dispositivo.
* **Instrumento Primario:** Ukelele en afinación estándar **G4 - C4 - E4 - A4** (Sol, Do, Mi, La).

---

## 2. 🛠️ Stack Tecnológico

| Capa / Módulo | Tecnología / Paquete | Versión / Detalle |
| :--- | :--- | :--- |
| **Framework Base** | Flutter | SDK `^3.7.2` |
| **Lenguaje** | Dart | 3.7+ con Sound Null-Safety |
| **Captura de Audio** | `flutter_audio_capture` | `^1.1.11` (Flujo PCM de audio en tiempo real) |
| **Procesamiento de Señal (DSP)** | `pitch_detector_dart` | `^0.0.7` (Detección de tono $f_0$ sobre buffer flotante) |
| **Permisos de Hardware** | `permission_handler` | `^12.0.1` (Permiso `Permission.microphone`) |
| **Assets & Branding** | `flutter_launcher_icons` | `^0.14.4` (Iconos automáticos para Android/iOS) |
| **Linter & Análisis Estático** | `flutter_lints` | `^5.0.0` |

---

## 3. 🏗️ Arquitectura de la Aplicación

### 3.1 Estructura Actual de Archivos

```text
app-chepita-afinador/
├── android/                   # Configuración y manifests nativos Android
├── assets/
│   └── icon/
│       └── icono_afinador.png # Ícono principal de la aplicación
├── ios/                       # Configuración nativa iOS (Info.plist para micrófono)
├── lib/
│   ├── main.dart              # Punto de entrada de la aplicación (MaterialApp)
│   └── tuner_page.dart        # Interfaz de usuario y ciclo de vida de captura de audio
├── test/                      # Tests unitarios y de widgets
├── pubspec.yaml               # Declaración de dependencias y assets
├── analysis_options.yaml      # Reglas del linter (flutter_lints)
└── README.md                  # Documentación introductoria
```

### 3.2 Flujo de Datos y Audio en Tiempo Real

```
[ Micrófono Físico ]
         │
         ▼
[ flutter_audio_capture ] ──> Genera buffer Float32 / PCM (44.1 kHz, 2048 buffer)
         │
         ▼
[ PitchDetector ] ─────────> Algoritmo de detección de tono fundamental (f0)
         │                   Filtro: (pitch > 80 Hz && pitch < 1000 Hz)
         ▼
[ Detección de Cuerda ] ───> Mapeo euclidiano contra notas de referencia (G4, C4, E4, A4)
         │
         ▼
[ Clasificación ] ─────────> Tolerancia ±2.0 Hz: "Afinada ✅", "Muy baja 🔽", "Muy alta 🔼"
         │
         ▼
[ UI State / Widget ] ─────> Actualización reactiva en pantalla
```

### 3.3 Módulo Futuro / Propuesto de Agentes (`lib/agents/`)

Para extender la app con agentes autónomos o colaborativos (diagnóstico acústico, tutor musical):
* `lib/agents/core/`: Definición de mensajes, eventos y el `AgentSupervisor`.
* `lib/agents/tools/`: Herramientas ejecutables que consultan el buffer de audio o cambian la afinación objetivo.
* `lib/agents/specialized/`: Agentes con prompts/lógica especializada (`DiagnosticAgent`, `TutorAgent`).
* `lib/agents/memory/`: Gestión de memoria a corto y largo plazo (sesión y calibración persistente).

---

## 4. 💻 Comandos Esenciales de Terminal

> **Nota:** Todos los comandos deben ejecutarse desde la raíz del proyecto (`e:\chepita-dev\app-chepita-afinador`).

### Gestión de Dependencias
```bash
# Descargar e instalar paquetes
flutter pub get

# Actualizar dependencias compatibles
flutter pub upgrade
```

### Calidad de Código y Análisis
```bash
# Ejecutar análisis estático (linter)
flutter analyze

# Formatear todo el código bajo directrices oficiales
dart format .
```

### Pruebas Automatizadas
```bash
# Ejecutar todas las pruebas
flutter test

# Ejecutar una prueba específica
flutter test test/nombre_del_test.dart
```

### Ejecución en Modo Desarrollo
```bash
# Ejecutar en el dispositivo conectado o emulador por defecto
flutter run

# Ejecutar seleccionando dispositivo específico
flutter run -d <device_id>
```

### Compilación para Producción (Release)
```bash
# Compilar APK para Android
flutter build apk --release

# Compilar App Bundle para Google Play Store
flutter build appbundle --release

# Regenerar íconos de la app (tras modificar assets/icon)
dart run flutter_launcher_icons
```

---

## 5. 📐 Convenciones de Código y Reglas de Estilo

1. **Estilo Oficial:** Seguir estrictamente las guías de [Effective Dart](https://dart.dev/effective-dart) y `flutter_lints`:
   * Nombres de archivos y carpetas: `snake_case.dart`.
   * Clases, Enums, Extensiones y Widgets: `PascalCase`.
   * Métodos, funciones y variables: `camelCase`.
   * Miembros privados: Prefijo con guión bajo `_ejemploPrivado`.
2. **Ciclo de Vida de Hardware y Audio:**
   * **Liberación de Recursos:** Cualquier suscripción, `Stream`, controlador o instancia de `FlutterAudioCapture` **DEBE** detenerse y liberarse en el método `dispose()` del `StatefulWidget`.
   * **Manejo Seguro de Nulos:** Evitar el operador `!` innecesario; usar coalescencia nula (`??`) o comprobaciones defensivas antes de invocar APIs de audio.
3. **Gestión de Permisos:**
   * Toda solicitud al micrófono debe usar `Permission.microphone.request()` y gestionar adecuadamente los estados `isGranted`, `isDenied` e `isPermanentlyDenied`.
4. **Rendimiento:**
   * Evitar llamadas costosas o reconstrucciones masivas dentro del callback de alta frecuencia del micrófono (`44.1 kHz`).
   * Filtrar ruido o lecturas inválidas antes de emitir actualizaciones a la UI con `setState`.
5. **Arquitectura Limpia:**
   * Separar progresivamente la lógica matemática y de procesamiento de audio fuera de los widgets UI hacia servicios o controladores dedicados.
