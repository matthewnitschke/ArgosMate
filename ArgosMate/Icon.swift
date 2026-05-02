//
//  Icon.swift
//  ArgosMate
//
//  Created by Matthew Nitschke on 4/25/26.
//

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
    image.isTemplate = true

    let context = NSGraphicsContext.current!.cgContext

    let scaleX = size.width / 36.0
    let scaleY = size.height / 36.0

    let path = CGMutablePath()
    path.move(to: CGPoint(x: 9.7734 * scaleX, y: 10.8911 * scaleY))
    path.addCurve(to: CGPoint(x: 8.5430 * scaleX, y: 9.6511 * scaleY),
                 control1: CGPoint(x: 9.0949 * scaleX, y: 10.8911 * scaleY),
                 control2: CGPoint(x: 8.5430 * scaleX, y: 10.3352 * scaleY))
    path.addLine(to: CGPoint(x: 8.5430 * scaleX, y: 6.8854 * scaleY))
    path.addCurve(to: CGPoint(x: 9.7734 * scaleX, y: 5.6502 * scaleY),
                 control1: CGPoint(x: 8.5430 * scaleX, y: 6.2068 * scaleY),
                 control2: CGPoint(x: 9.0949 * scaleX, y: 5.6502 * scaleY))
    path.addLine(to: CGPoint(x: 26.1846 * scaleX, y: 5.6502 * scaleY))
    path.addCurve(to: CGPoint(x: 27.4219 * scaleX, y: 6.8854 * scaleY),
                 control1: CGPoint(x: 26.8740 * scaleX, y: 5.6502 * scaleY),
                 control2: CGPoint(x: 27.4219 * scaleX, y: 6.2068 * scaleY))
    path.addLine(to: CGPoint(x: 27.4219 * scaleX, y: 19.1798 * scaleY))
    path.addCurve(to: CGPoint(x: 26.8553 * scaleX, y: 20.2130 * scaleY),
                 control1: CGPoint(x: 27.4219 * scaleX, y: 19.5984 * scaleY),
                 control2: CGPoint(x: 27.2127 * scaleX, y: 19.9878 * scaleY))
    path.addLine(to: CGPoint(x: 11.3660 * scaleX, y: 30.1437 * scaleY))
    path.addCurve(to: CGPoint(x: 9.4723 * scaleX, y: 29.1074 * scaleY),
                 control1: CGPoint(x: 10.5473 * scaleX, y: 30.6684 * scaleY),
                 control2: CGPoint(x: 9.4723 * scaleX, y: 30.0810 * scaleY))
    path.addLine(to: CGPoint(x: 9.4723 * scaleX, y: 25.5765 * scaleY))
    path.addCurve(to: CGPoint(x: 10.0446 * scaleX, y: 24.5339 * scaleY),
                 control1: CGPoint(x: 9.4723 * scaleX, y: 25.1520 * scaleY),
                 control2: CGPoint(x: 9.6871 * scaleX, y: 24.7599 * scaleY))
    path.addLine(to: CGPoint(x: 21.1833 * scaleX, y: 17.4902 * scaleY))
    path.addCurve(to: CGPoint(x: 21.7534 * scaleX, y: 16.4477 * scaleY),
                 control1: CGPoint(x: 21.5347 * scaleX, y: 17.2657 * scaleY),
                 control2: CGPoint(x: 21.7534 * scaleX, y: 16.8724 * scaleY))
    path.addLine(to: CGPoint(x: 21.7534 * scaleX, y: 12.1221 * scaleY))
    path.addCurve(to: CGPoint(x: 20.5270 * scaleX, y: 10.8911 * scaleY),
                 control1: CGPoint(x: 21.7534 * scaleX, y: 11.4370 * scaleY),
                 control2: CGPoint(x: 21.2117 * scaleX, y: 10.8911 * scaleY))
    path.closeSubpath()

    context.setFillColor(NSColor.black.cgColor)
    context.addPath(path)
    context.fillPath()

    image.unlockFocus()

    return image
}

func createOutlineIconImage(size: NSSize = NSSize(width: 22, height: 22)) -> NSImage {
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
    image.isTemplate = true

    let context = NSGraphicsContext.current!.cgContext

    let scaleX = size.width / 36.0
    let scaleY = size.height / 36.0

    let path = CGMutablePath()
    path.move(to: CGPoint(x: 9.7734 * scaleX, y: 10.8911 * scaleY))
    path.addCurve(to: CGPoint(x: 8.5430 * scaleX, y: 9.6511 * scaleY),
                 control1: CGPoint(x: 9.0949 * scaleX, y: 10.8911 * scaleY),
                 control2: CGPoint(x: 8.5430 * scaleX, y: 10.3352 * scaleY))
    path.addLine(to: CGPoint(x: 8.5430 * scaleX, y: 6.8854 * scaleY))
    path.addCurve(to: CGPoint(x: 9.7734 * scaleX, y: 5.6502 * scaleY),
                 control1: CGPoint(x: 8.5430 * scaleX, y: 6.2068 * scaleY),
                 control2: CGPoint(x: 9.0949 * scaleX, y: 5.6502 * scaleY))
    path.addLine(to: CGPoint(x: 26.1846 * scaleX, y: 5.6502 * scaleY))
    path.addCurve(to: CGPoint(x: 27.4219 * scaleX, y: 6.8854 * scaleY),
                 control1: CGPoint(x: 26.8740 * scaleX, y: 5.6502 * scaleY),
                 control2: CGPoint(x: 27.4219 * scaleX, y: 6.2068 * scaleY))
    path.addLine(to: CGPoint(x: 27.4219 * scaleX, y: 19.1798 * scaleY))
    path.addCurve(to: CGPoint(x: 26.8553 * scaleX, y: 20.2130 * scaleY),
                 control1: CGPoint(x: 27.4219 * scaleX, y: 19.5984 * scaleY),
                 control2: CGPoint(x: 27.2127 * scaleX, y: 19.9878 * scaleY))
    path.addLine(to: CGPoint(x: 11.3660 * scaleX, y: 30.1437 * scaleY))
    path.addCurve(to: CGPoint(x: 9.4723 * scaleX, y: 29.1074 * scaleY),
                 control1: CGPoint(x: 10.5473 * scaleX, y: 30.6684 * scaleY),
                 control2: CGPoint(x: 9.4723 * scaleX, y: 30.0810 * scaleY))
    path.addLine(to: CGPoint(x: 9.4723 * scaleX, y: 25.5765 * scaleY))
    path.addCurve(to: CGPoint(x: 10.0446 * scaleX, y: 24.5339 * scaleY),
                 control1: CGPoint(x: 9.4723 * scaleX, y: 25.1520 * scaleY),
                 control2: CGPoint(x: 9.6871 * scaleX, y: 24.7599 * scaleY))
    path.addLine(to: CGPoint(x: 21.1833 * scaleX, y: 17.4902 * scaleY))
    path.addCurve(to: CGPoint(x: 21.7534 * scaleX, y: 16.4477 * scaleY),
                 control1: CGPoint(x: 21.5347 * scaleX, y: 17.2657 * scaleY),
                 control2: CGPoint(x: 21.7534 * scaleX, y: 16.8724 * scaleY))
    path.addLine(to: CGPoint(x: 21.7534 * scaleX, y: 12.1221 * scaleY))
    path.addCurve(to: CGPoint(x: 20.5270 * scaleX, y: 10.8911 * scaleY),
                 control1: CGPoint(x: 21.7534 * scaleX, y: 11.4370 * scaleY),
                 control2: CGPoint(x: 21.2117 * scaleX, y: 10.8911 * scaleY))
    path.closeSubpath()

    context.setStrokeColor(NSColor.black.cgColor)
    context.setLineWidth(1.5 * scaleX)
    context.addPath(path)
    context.strokePath()

    image.unlockFocus()

    return image
}
