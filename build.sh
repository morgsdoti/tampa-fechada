#!/bin/zsh
# Compila o app e instala em /Applications/Tampa Fechada.app
set -e
cd "$(dirname "$0")"

APP="build/Tampa Fechada.app"
rm -rf build
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" build/AppIcon.iconset

# Binário universal (Apple Silicon + Intel), roda do macOS 13 em diante
for arch in arm64 x86_64; do
  swiftc -O -swift-version 5 -target $arch-apple-macos13.0 main.swift -o build/TampaFechada-$arch
done
lipo -create build/TampaFechada-arm64 build/TampaFechada-x86_64 -output "$APP/Contents/MacOS/TampaFechada"
cp Info.plist "$APP/Contents/Info.plist"

swiftc -O -swift-version 5 gen-icon.swift -o build/gen-icon
build/gen-icon build/icon.png
for s in 16 32 128 256 512; do
  sips -z $s $s build/icon.png --out build/AppIcon.iconset/icon_${s}x${s}.png >/dev/null
  sips -z $((s*2)) $((s*2)) build/icon.png --out build/AppIcon.iconset/icon_${s}x${s}@2x.png >/dev/null
done
iconutil -c icns build/AppIcon.iconset -o "$APP/Contents/Resources/AppIcon.icns"

codesign --force --deep -s - "$APP"
ditto -c -k --keepParent "$APP" build/TampaFechada.zip

if [[ "$1" != "--no-install" ]]; then
  rm -rf "/Applications/Tampa Fechada.app"
  cp -R "$APP" /Applications/
  echo "Instalado em /Applications/Tampa Fechada.app"
fi
