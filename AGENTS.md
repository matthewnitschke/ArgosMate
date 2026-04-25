# ArgosMate

Menubar app displaying stats about the Argos espresso machine via Bluetooth.

## Build

```bash
make build
```

Runs `swiftc` with CoreBluetooth framework. Output: `ArgosMate.app/`

## Run

Open `ArgosMate.app` or run `open ArgosMate.app`

## Project Structure

- `src/main.swift` - Single source file (entire app)
- `src/Info.plist` - App metadata
- `build.sh` - Build script

## Notes

- No Xcode project (pure Swift compilation)
- No external dependencies (native frameworks only)
- No tests, linting, or typechecking
- No Swift Package Manager
- Menubar accessory app (LSUIElement=true)