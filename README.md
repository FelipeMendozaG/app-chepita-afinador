# 🎸 Afinador CHP (Afinador de Ukelele)

Una aplicación móvil simple y precisa desarrollada con Flutter para ayudarte a afinar tu ukelele rápida y fácilmente utilizando el micrófono de tu dispositivo.

## ✨ Características

* **Detección de Tono en Tiempo Real:** Utiliza el algoritmo de detección de tono (Pitch Detection) para analizar el audio del micrófono y mostrar la frecuencia detectada.
* **Afinación Estándar de Ukelele:** Soporte para la afinación estándar G-C-E-A (Cuerdas: Sol, Do, Mi, La).
* **Guía Visual:** Indica si la cuerda está muy baja (🔽), muy alta (🔼) o perfectamente afinada (✅).
* **Interfaz Minimalista:** Diseño limpio y fácil de usar, centrado en la lectura rápida de la frecuencia.

## 🛠️ Tecnologías Utilizadas

* **Framework:** Flutter
* **Lenguaje:** Dart
* **Detección de Audio:** `flutter_audio_capture`
* **Detección de Tono:** `pitch_detector_dart`
* **Manejo de Permisos:** `permission_handler`

## 🚀 Instalación y Ejecución

### 1. Requisitos

Asegúrate de tener instalado:

* [Flutter SDK](https://flutter.dev/docs/get-started/install)
* [Android Studio o VS Code](https://flutter.dev/docs/get-started/editor)

### 2. Clonar el Repositorio

```bash
git clone [https://github.com/tu_usuario/afinador-chp.git](https://github.com/tu_usuario/afinador-chp.git)
cd afinador-chp