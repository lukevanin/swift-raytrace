//
//  Bufer.swift
//  GraphicsKernelTest
//
//  Created by Luke Van In on 2019/11/18.
//  Copyright © 2019 eventcloud. All rights reserved.
//

import Foundation
import CoreGraphics

final class Buffer {
    
    private let colorSpace: CGColorSpace = {
        let colorSpace = CGColorSpace(name: CGColorSpace.genericRGBLinear)
        return colorSpace!
    }()
    
    private let bitmapInfo: CGBitmapInfo = {
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        return bitmapInfo
    }()
    
    var data: Data
    let size: IntegralCoordinate
    let bytesPerRow: Int
    let bytesPerPixel: Int
    
    init(size: IntegralCoordinate) {
        self.size = size
        self.bytesPerRow = 4 * size.x
        self.bytesPerPixel = 4
        let totalBytes = bytesPerRow * size.y
        self.data = Data(repeating: 255, count: totalBytes)
    }
    
    func set(color: Color, at coordinate: IntegralCoordinate) {
        let d = (coordinate.y * bytesPerRow) + (coordinate.x * bytesPerPixel)
        data[d + 1] = UInt8(color.r * 255.99)
        data[d + 2] = UInt8(color.g * 255.99)
        data[d + 3] = UInt8(color.b * 255.99)
    }
    
    func cgImage() -> CGImage? {
        guard let dataProvider = CGDataProvider(data: data as CFData) else {
            return nil
        }
        
        let image = CGImage(
            width: size.x,
            height: size.y,
            bitsPerComponent: 8,
            bitsPerPixel: 8 * bytesPerPixel,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: dataProvider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )
        
        return image
    }
}
