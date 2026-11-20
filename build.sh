#!/usr/bin/env bash
set -euo pipefail
mkdir -p dist
SDK_PATH="$(xcrun --sdk iphoneos --show-sdk-path)"
clang -fobjc-arc -dynamiclib -arch arm64 -isysroot "$SDK_PATH" \
  -miphoneos-version-min=13.0 \
  -framework UIKit -framework Foundation \
  -install_name @rpath/bloodboyyoung_ig.dylib \
  src/bloodboyyoung_ig.m -o dist/bloodboyyoung_ig.dylib
codesign -f -s - dist/bloodboyyoung_ig.dylib
echo "Ready: dist/bloodboyyoung_ig.dylib"
