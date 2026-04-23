import AppKit

func createIconImage(size: NSSize = NSSize(width: 22, height: 22)) -> NSImage {
    let image = NSImage(size: size)
    image.addRepresentation(NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size.width),
        pixelsHigh: Int(size.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!)

    image.lockFocus()

    let context = NSGraphicsContext.current!.cgContext

    let scaleX = size.width / 36.0
    let scaleY = size.height / 36.0

    let path = CGMutablePath()
    path.move(to: CGPoint(x: 7 * scaleX, y: (36 - 26.3033) * scaleY))
    path.addLine(to: CGPoint(x: 7 * scaleX, y: (36 - 32) * scaleY))
    path.addLine(to: CGPoint(x: 28 * scaleX, y: (36 - 32) * scaleY))
    path.addLine(to: CGPoint(x: 28 * scaleX, y: (36 - 16.5359) * scaleY))
    path.addLine(to: CGPoint(x: 8.03317 * scaleX, y: (36 - 4) * scaleY))
    path.addLine(to: CGPoint(x: 8.03317 * scaleX, y: (36 - 11.0385) * scaleY))
    path.addLine(to: CGPoint(x: 21.6965 * scaleX, y: (36 - 19.5036) * scaleY))
    path.addLine(to: CGPoint(x: 21.6965 * scaleX, y: (36 - 26.3033) * scaleY))
    path.closeSubpath()

    context.setFillColor(NSColor.black.cgColor)
    context.addPath(path)
    context.fillPath()

    image.unlockFocus()

    return image
}