#!/bin/bash

rm -rf ArgosMate.app

mkdir -p ArgosMate.app/Contents/MacOS

cp src/Info.plist ArgosMate.app/Contents

swiftc ./src/*.swift -o ./ArgosMate.app/Contents/MacOS/ArgosMate -framework CoreBluetooth