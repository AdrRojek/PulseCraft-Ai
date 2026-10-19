#!/usr/bin/env bash
# Dlaczego NIE `flutter run --release`?
# - Twój iPhone jest zwykle tylko wireless → flutter run wisi na attach VM Service
#   i zostawia Cię na LaunchScreen (biały/czarny) bez UI.
# - Ten skrypt = build + czysty install. Appkę otwierasz sam na telefonie.
# - To jest ta sama ścieżka, którą używa agent.
set -euo pipefail
cd "$(dirname "$0")/.."

UDID="${1:-00008110-001079AA0C01401E}"
BUNDLE_ID="com.pulsecraft.ai.pulsecraft"
APP="build/ios/iphoneos/Runner.app"
MODE="${2:-release}" # release | profile

echo "→ flutter build ios --$MODE"
flutter build ios --"$MODE"

echo "→ uninstall $BUNDLE_ID (ignore if missing)"
xcrun devicectl device uninstall app --device "$UDID" "$BUNDLE_ID" || true

echo "→ install $APP"
xcrun devicectl device install app --device "$UDID" "$APP"

echo "✓ Zainstalowano. Otwórz ikonę Pulsecraft na telefonie."
echo "  Szukaj zielonego paska „PULSECRAFT BOOT OK” u góry — to znaczy, że Flutter maluje."
