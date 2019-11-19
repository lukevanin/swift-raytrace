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
    let x: CGFloat
    let y: CGFloat
}
    
extension Coordinate {
    init(_ coordinate: IntegralCoordinate) {
        self.x = CGFloat(coordinate.x)
        self.y = CGFloat(coordinate.y)
    }
}

struct Ray {
    let origin: Vector3
    let direction: Vector3
    
    @inlinable func point(at delta: CGFloat) -> Vector3 {
        return origin + (direction * delta)
    }
}

struct Hit {
    let coordinate: Vector3
    let normal: Vector3
    let t: CGFloat
    let material: Material
}

struct MaterialRay {
    let attenuation: Vector3
    let ray: Ray
}

protocol Material {
    func scatter(ray: Ray, hit: Hit) -> MaterialRay?
}

struct Range {
    var min: CGFloat
    var max: CGFloat
    
    func contains(_ t: CGFloat) -> Bool {
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

typealias Color = Vector3

struct Vector3 {
    
    static let zero = Vector3([0, 0, 0])
    
    var x: CGFloat {
        get {
            return v[0]
        }
        set {
            v[0] = newValue
        }
    }
    
    var y: CGFloat {
        get {
            return v[1]
        }
        set {
            v[1] = newValue
        }
    }
    
    var z: CGFloat {
        get {
            return v[2]
        }
        set {
            v[2] = newValue
        }
    }
    
    var r: CGFloat {
        get {
            return v[0]
        }
        set {
            v[0] = newValue
        }
    }
    
    var g: CGFloat {
        get {
            return v[1]
        }
        set {
            v[1] = newValue
        }
    }
    
    var b: CGFloat {
        get {
            return v[2]
        }
        set {
            v[2] = newValue
        }
    }

    var v: [CGFloat]
    
    init(x: CGFloat, y: CGFloat, z: CGFloat) {
        self.init([x, y, z])
    }
    
    init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init([r, g, b])
    }

    init(_ v: [CGFloat]) {
        self.v = v
    }
    
    @inlinable subscript(index: Int) -> CGFloat {
        return v[index]
    }
    
    @inlinable func normal() -> Vector3 {
        return self / length()
    }
    
    @inlinable func length() -> CGFloat {
        return sqrt(magnitude())
    }
    
    @inlinable  func magnitude() -> CGFloat {
        return (x * x) + (y * y) + (z * z)
    }
    
    @inlinable static prefix func +(v: Vector3) -> Vector3 {
        return v
    }
    
    @inlinable static prefix func -(v: Vector3) -> Vector3 {
        return Vector3(x: -v[0], y: -v[1], z: -v[2])
    }
    
    @inlinable static func +(v: Vector3, t: CGFloat) -> Vector3 {
        return Vector3(x: v[0] + t, y: v[1] + t, z: v[2] + t)
    }

    @inlinable static func *(v: Vector3, t: CGFloat) -> Vector3 {
        return Vector3(x: v[0] * t, y: v[1] * t, z: v[2] * t)
    }
    
    @inlinable static func /(v: Vector3, t: CGFloat) -> Vector3 {
        return Vector3(x: v[0] / t, y: v[1] / t, z: v[2] / t)
    }
    
    @inlinable static func +(a: Vector3, b: Vector3) -> Vector3 {
        return Vector3(x: a[0] + b[0], y: a[1] + b[1], z: a[2] + b[2])
    }
    
    @inlinable static func -(a: Vector3, b: Vector3) -> Vector3 {
        return Vector3(x: a[0] - b[0], y: a[1] - b[1], z: a[2] - b[2])
    }
    
    @inlinable static func *(a: Vector3, b: Vector3) -> Vector3 {
        return Vector3(x: a[0] * b[0], y: a[1] * b[1], z: a[2] * b[2])
    }
    
    @inlinable static func /(a: Vector3, b: Vector3) -> Vector3 {
        return Vector3(x: a[0] / b[0], y: a[1] / b[1], z: a[2] / b[2])
    }

    @inlinable static func dot(_ a: Vector3, _ b: Vector3) -> CGFloat {
        return (a[0] * b[0]) + (a[1] * b[1]) + (a[2] * b[2])
    }
    
    @inlinable static func cross(_ a: Vector3, _ b: Vector3) -> Vector3 {
        return Vector3(
            x: (a[1] * b[2]) - (a[2] * b[1]),
            y: (a[2] * b[0]) - (a[0] * b[2]),
            z: (a[0] * b[1]) - (a[1] * b[0])
        )
    }
    
    @inlinable static func reflect(_ v: Vector3, _ n: Vector3) -> Vector3 {
        return v - (n * Vector3.dot(v, n) * 2)
    }
    
    @inlinable static func refract(_ v: Vector3, _ n: Vector3, _ i: CGFloat) -> Vector3? {
        let uv = v.normal()
        let dt = dot(uv, n)
        let d = 1.0 - (i * i * (1 - (dt * dt)))
        guard d > 0 else {
            return nil
        }
        return ((uv - (n * dt)) * i) - (n * sqrt(d))
    }

    @inlinable static func lerp(from a: Vector3, to b: Vector3, t: CGFloat) -> Vector3 {
        return (a * (1.0 - t)) + (b * t)
    }
    
    @inlinable static func random() -> Vector3 {
        let range = CGFloat(-1.0) ..< CGFloat(1.0)
        return Vector3(
            x: CGFloat.random(in: range),
            y: CGFloat.random(in: range),
            z: CGFloat.random(in: range)
        )
    }
    
    @inlinable static func randomUnitDisk() -> Vector3 {
        let a = CGFloat.random(in: 0 ..< 1) * CGFloat.pi * 2
        let r = CGFloat.random(in: 0 ..< 1)
        return Vector3(
            x: cos(a) * r,
            y: sin(a) * r,
            z: 0
        )
    }
}
