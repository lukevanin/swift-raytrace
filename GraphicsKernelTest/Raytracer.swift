//
//  Raytracer.swift
//  GraphicsKernelTest
//
//  Created by Luke Van In on 2019/11/20.
//  Copyright © 2019 eventcloud. All rights reserved.
//

import Foundation

final class Raytracer {
    
    typealias Background = (Ray) -> Color
    
    struct Config {
        let sampleCount: Int
        let sampleDepth: Int
    }
    
    private let buffer: Buffer
    private let world: Hitable
    private let camera: Camera
    private let background: Background
    private let config: Config
    
    init(camera: Camera, world: Hitable, background: @escaping Background, buffer: Buffer, config: Config) {
        self.camera = camera
        self.world = world
        self.background = background
        self.buffer = buffer
        self.config  = config
    }
    
    private func color(ray: Ray, world: Hitable, depth: Int) -> Color {
        let limits = Range(min: 0.001, max: Double.greatestFiniteMagnitude)
        if let hit = world.hit(ray: ray, limits: limits) {
            if let scatter = hit.material.scatter(ray: ray, hit: hit), depth > 0 {
                return color(ray: scatter.ray, world: world, depth: depth - 1) * scatter.attenuation
            }
            else {
                return Vector3.zero
//                return Vector3(r: 1.0, g: 0.0, b: 1.0)
            }
        }
        else {
            return background(ray)
        }
    }

    func render() {
        let renderSize = buffer.size
        let sampleCount = config.sampleCount
        let sampleRange = Random(range: Range(min: -0.5, max: 0.5))
        let sampleDepth = config.sampleDepth
        
        let totalPixelCount = renderSize.x * renderSize.y
        let totalSampleCount = totalPixelCount * sampleCount
        let startTime = Date()
        
        for y in 0 ..< renderSize.y {
            for x in 0 ..< renderSize.x {
                var a = Vector3.zero
                for _ in 0 ..< sampleCount {
                    let p = sampleRange.next()
                    let q = sampleRange.next()
                    let u = (Double(x) + p) / Double(renderSize.x)
                    let v = (Double(y) + q) / Double(renderSize.y)
                    let r = camera.ray(coordinate: Coordinate(x: u, y: v))
                    let c = color(ray: r, world: world, depth: sampleDepth)
                    a = a + c
                }
                let color = a / Double(sampleCount)
                let coordinate = IntegralCoordinate(
                    x: x,
                    y: y
                )
                buffer.set(color: color, at: coordinate)
            }
        }
        
        let endTime = Date()
        let elapsedTime = endTime.timeIntervalSince(startTime)
        print("Render complete.")
        print("Elapsed time : \(elapsedTime) seconds")
        print("Pixels       : \(totalPixelCount)")
        print("Samples      : \(totalSampleCount)")
    }
}
