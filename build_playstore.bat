@echo off
echo ========================================================
echo    Compilando Bundle (.aab) para Google Play Store
echo    App: Chepita tune (chepita.tune)
echo ========================================================
echo.

cd /d "%~dp0"

echo [1/3] Limpiando compilaciones anteriores...
call flutter clean

echo.
echo [2/3] Obteniendo dependencias...
call flutter pub get

echo.
echo [3/3] Compilando Android App Bundle (Release)...
call flutter build appbundle --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo  COMPILACION EXITOSA!
    echo ========================================================
    echo  El archivo para Google Play Store ha sido generado en:
    echo  build\app\outputs\bundle\release\app-release.aab
    echo ========================================================
    explorer /select,"build\app\outputs\bundle\release\app-release.aab"
) else (
    echo.
    echo [ERROR] La compilacion ha fallado. Revisa los mensajes anteriores.
)

pause
