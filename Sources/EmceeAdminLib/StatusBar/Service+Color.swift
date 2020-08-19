import AppKit
import Extensions
import Services

public extension Service {
    var color: NSColor { version.color }
}

private extension String {
    var color: NSColor {
        if let rgbValue = UInt((try? avito_sha256Hash().prefix(6)) ?? "000000", radix: 16) {
            let red   =  CGFloat((rgbValue >> 16) & 0xff) / 255
            let green =  CGFloat((rgbValue >>  8) & 0xff) / 255
            let blue  =  CGFloat((rgbValue      ) & 0xff) / 255
            return NSColor(calibratedRed: red, green: green, blue: blue, alpha: 1.0)
        } else {
            return .black
        }
    }
}
