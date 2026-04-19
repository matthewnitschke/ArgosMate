#!/bin/bash

rm -rf ArgosMate.app

mkdir -p ArgosMate.app/Contents/MacOS
cp -r src/Resources ArgosMate.app/Contents/MacOS

cp src/Info.plist ArgosMate.app/Contents


swiftc ./src/main.swift -o ./ArgosMate.app/Contents/MacOS/ArgosMate -framework CoreBluetooth