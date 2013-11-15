#!/bin/sh
set -e


cd AeroGear-Crypto-Demo
pod install
xctool clean build ONLY_ACTIVE_ARCH=NO