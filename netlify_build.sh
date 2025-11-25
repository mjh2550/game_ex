#!/usr/bin/env bash
set -e

# Flutter 설치 (stable channel, shallow clone)
if ! command -v flutter >/dev/null 2>&1; then
  echo "Installing Flutter..."
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git /opt/buildhome/flutter
  export PATH="/opt/buildhome/flutter/bin:$PATH"
  flutter precache --web
fi

export PATH="/opt/buildhome/flutter/bin:$PATH"

echo "Flutter version:"
flutter --version

echo "Getting dependencies..."
flutter pub get

echo "Building web release..."
flutter build web --release

echo "Build complete!"
