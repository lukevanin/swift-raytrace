//
//  Vector3.swift
//  GraphicsKernelTest
//
//  Created by Luke Van In on 2019/11/18.
//  Copyright © 2019 eventcloud. All rights reserved.
//

import Foundation
import CoreGraphics

struct IntegralCoordinate {
    let x: Int
    let y: Int
}

struct Coordinate {
    let x: Double
    let y: Double
}
    
extension Coordinate {
    init(_ coordinate: IntegralCoordinate) {
        self.x = Double(coordinate.x)
        self.y = Double(coordinate.y)
    }
}

struct Ray {
    let origin: Vector3
    let direction: Vector3
    
    @inlinable func point(at delta: Double) -> Vector3 {
        return origin + (direction * delta)
    }
}

struct Hit {
    let coordinate: Vector3
    let normal: Vector3
    let t: Double
    let material: Material
}

struct MaterialRay {
    let attenuation: Vector3
    let ray: Ray
}

protocol Material {
    func scatter(ray: Ray, hit: Hit) -> MaterialRay?
}

struct Random {
    
    static let unit = Random(range: Range(min: 0, max: 1))
    
    private let min: Double
    private let span: Double
    
    init(range: Range) {
        self.min = range.min
        self.span = range.span
    }
    
    func next() -> Double {
        return min + (Double(drand48()) * span)
    }
}


struct Range {
    var min: Double
    var max: Double
    var span: Double {
        return max - min
    }
    
    func contains(_ t: Double) -> Bool {
        return t > min && t < max
    }
}

protocol Hitable {
    func hit(ray: Ray, limits: Range) -> Hit?
}

class HitableList: Hitable {
    var items = [Hitable]()
    
    convenience init() {
        self.init(items: [])
    }
    
    init(items: [Hitable]) {
        self.items = items
    }
    
    subscript(index: Int) -> Hitable {
        get {
            return items[index]
        }
        set {
            items[index] = newValue
        }
    }
    
    func append(_ item: Hitable) {
        items.append(item)
    }
    
    func remove(at index: Int) -> Hitable {
        return items.remove(at: index)
    }
    
    func hit(ray: Ray, limits: Range) -> Hit? {
        var hit: Hit?
        var hitLimit = limits
        for item in items {
            if let itemHit = item.hit(ray: ray, limits: hitLimit) {
                hit = itemHit
                hitLimit.max = itemHit.t
            }
        }
        return hit
    }
}

