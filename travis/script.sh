#!/bin/sh
set -e


cd AeroGear-Crypto-Demo
pod install
xctool -workspace AeroGear-Crypto-Demo.xcworkspace -scheme AeroGear-Crypto-Demo -sdk iphonesimulator