//
//  Raytracer.swift
//  GraphicsKernelTest
//
//  Created by Luke Van In on 2019/11/20.
//  Copyright © 2019 eventcloud. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

private let tileSize = IntegralCoordinate(x: 32, y: 32)
private let sampleRange = Random(range: Range(min: -0.5, max: 0.5))

final class Raytracer {
    
    typealias Background = (Ray) -> Color
    
    struct Config {
        let sampleCount: Int
        let sampleDepth: Int
    }
    
    private let viewportSize: IntegralCoordinate
    private let world: Hitable
    private let camera: Camera
    private let background: Background
    private let config: Config
    private let renderQueue = DispatchQueue(
        label: "render-queue"
    )
    private let tileQueue = DispatchQueue(
        label: "tile-queue",
        qos: .userInitiated,
        attributes: [.concurrent]
    )
    private let renderGroup = DispatchGroup()

    init(viewportSize: IntegralCoordinate, camera: Camera, world: Hitable, background: @escaping Background, config: Config) {
        precondition(viewportSize.x % tileSize.x == 0, "Viewport width must be a multiple of \(tileSize.x)")
        precondition(viewportSize.y % tileSize.y == 0, "Viewport height must be a multiple of \(tileSize.y)")
        self.viewportSize = viewportSize
        self.camera = camera
        self.world = world
        self.background = background
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
            }
        }
        else {
            return background(ray)
        }
    }

    func render(_ completion: @escaping (UIImage) -> Void) {
        let totalPixelCount = viewportSize.x * viewportSize.y
        let totalSampleCount = totalPixelCount * config.sampleCount
        
        let tx = viewportSize.x / 32
        let ty = viewportSize.y / 32
        let tileCount = tx * ty

        let startTime = Date()
        var tiles = Array<CGImage?>(repeating: nil, count: tileCount)

        // Render tiles
        for y in 0 ..< ty {
            for x in 0 ..< tx {
                renderGroup.enter()
                tileQueue.async { [weak self, x, y] in
                    guard let self = self else {
                        return
                    }
                    let coordinate = IntegralCoordinate(x: x, y: y)
                    let tile = self.renderTile(tile: coordinate)
                    DispatchQueue.main.async {
                        tiles[(y * tx) + x] = tile
                        
                        let completedCount = tiles.reduce(0) { count, image in
                            count + (image != nil ? 1 : 0)
                        }
                        let progress = Float(completedCount) / Float(tileCount)
                        print("\(completedCount) / \(tileCount) (\(Int(progress * 100))%)")
                        
                        self.renderGroup.leave()
                    }
                }
            }
        }
        
        renderGroup.notify(queue: DispatchQueue.main) { [viewportSize, config] in
            // Composite tiles into single image
            let size = CGSize(width: viewportSize.x, height: viewportSize.y)
            let renderer = UIGraphicsImageRenderer(size: size)
            let image = renderer.image { context in
                let cgContext = context.cgContext
                
                let rect = CGRect(origin: .zero, size: size)
                context.fill(rect)

                cgContext.scaleBy(x: 1, y: -1)

                for y in 0 ..< ty {
                    for x in 0 ..< tx {
                        guard let tile = tiles[(y * tx) + x] else {
                            continue
                        }
                        let rect = CGRect(
                            origin: CGPoint(
                                x: x * tileSize.x,
                                y: -y * tileSize.y
                            ),
                            size: CGSize(
                                width: tileSize.x,
                                height: tileSize.y
                            )
                        )
                        cgContext.draw(tile, in: rect)
                    }
                }
            }
            
            let endTime = Date()
            let elapsedTime = endTime.timeIntervalSince(startTime)
            print("Render complete.")
            print("Viewport          : \(viewportSize.x) x \(viewportSize.y)")
            print("Elapsed time      : \(elapsedTime) seconds")
            print("Pixels            : \(totalPixelCount)")
            print("Samples per pixel : \(config.sampleCount)")
            print("Samples           : \(totalSampleCount)")
            
            completion(image)
        }
    }
    
    private func renderTile(tile: IntegralCoordinate) -> CGImage? {
        let buffer = Buffer(size: tileSize)
        let renderSize = viewportSize
        let sampleDepth = config.sampleDepth
        let sampleCount = config.sampleCount

        for ty in 0 ..< tileSize.y {
            for tx in 0 ..< tileSize.x {
                let x = Double(tile.x * tileSize.x) + Double(tx)
                let y = Double(tile.y * tileSize.y) + Double(ty)
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
                    x: tx,
                    y: ty
                )
                buffer.set(color: color, at: coordinate)
            }
        }
        
        return buffer.cgImage()
    }
}
