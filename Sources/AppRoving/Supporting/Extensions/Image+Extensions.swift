//
//  Image+Extensions.swift
//  xcDebugger
//
//  Created by Axel Ancona Esselmann on 11/22/23.
//

import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif


#if os(macOS)
extension Data {
    init?(imageName: String, type: NSBitmapImageRep.FileType) {
        guard
            let tiffData = NSImage(named: imageName)?.tiffRepresentation,
            let bitmapData = NSBitmapImageRep(data: tiffData),
            let representation = bitmapData.representation(using: .png, properties: [:])
        else {
            return nil
        }
        self = representation
    }

    init?(pngDataFor imageName: String) {
        self.init(imageName: imageName, type: .png)
    }
}
#else
extension Data {
    init?(pngDataFor imageName: String) {
        guard let pngData = UIImage(named: imageName)?.pngData() else {
            return nil
        }
        self = pngData
    }
}
#endif
