#!/bin/sh
set -e

cd AeroDoc
pod install
xctool clean build ONLY_ACTIVE_ARCH=NO
