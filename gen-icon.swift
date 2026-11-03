// Gera o ícone do app (1024x1024 PNG): sol branco sobre quadrado laranja.
import Cocoa

let px = 1024
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
                           samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                           colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

let rect = NSRect(x: 100, y: 100, width: 824, height: 824)
let path = NSBezierPath(roundedRect: rect, xRadius: 185, yRadius: 185)
NSGradient(starting: NSColor(srgbRed: 1.0, green: 0.68, blue: 0.22, alpha: 1),
           ending: NSColor(srgbRed: 0.93, green: 0.36, blue: 0.24, alpha: 1))!.draw(in: path, angle: -90)

let cfg = NSImage.SymbolConfiguration(pointSize: 440, weight: .semibold)
    .applying(NSImage.SymbolConfiguration(paletteColors: [.white]))
let sun = NSImage(systemSymbolName: "sun.max.fill", accessibilityDescription: nil)!.withSymbolConfiguration(cfg)!
let s = sun.size
sun.draw(in: NSRect(x: (1024 - s.width) / 2, y: (1024 - s.height) / 2, width: s.width, height: s.height))

NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
