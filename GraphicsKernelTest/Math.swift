//
//  Math.swift
//  GraphicsKernelTest
//
//  Created by Luke Van In on 2019/11/20.
//  Copyright © 2019 eventcloud. All rights reserved.
//

import Foundation
import simd

typealias Color = Vector3

struct Vector3 {
    
    static let zero = Vector3(x: 0, y: 0, z: 0)
    
    var x: Double {
        get {
            return v.x
        }
        set {
            v.x = newValue
        }
    }
    
    var y: Double {
        get {
            return v.y
        }
        set {
            v.y = newValue
        }
    }
    
    var z: Double {
        get {
            return v.z
        }
        set {
            v.z = newValue
        }
    }
    
    var r: Double {
        get {
            return v.x
        }
        set {
            v.x = newValue
        }
    }
    
    var g: Double {
        get {
            return v.y
        }
        set {
            v.y = newValue
        }
    }
    
    var b: Double {
        get {
            return v.z
        }
        set {
            v.z = newValue
        }
    }
    
    var v: simd_double3
    
    init(x: Double, y: Double, z: Double) {
        self.init(simd_double3(x: x, y: y, z: z))
    }
    
    init(r: Double, g: Double, b: Double) {
        self.init(simd_double3(x: r, y: g, z: b))
    }
    
    init(_ v: simd_double3) {
        self.v = v
    }
    
    @inlinable func normalized() -> Vector3 {
        return Vector3(simd_normalize(v))
    }
    
    @inlinable func length() -> Double {
        return simd_length(v)
    }
    
    @inlinable  func magnitude() -> Double {
        return simd_length_squared(v)
    }
    
    @inlinable static prefix func +(a: Vector3) -> Vector3 {
        return Vector3(a.v)
    }
    
    @inlinable static prefix func -(a: Vector3) -> Vector3 {
        return Vector3(simd_double3(x: 0, y: 0, z: 0) - a.v)
    }
    
    @inlinable static func +(a: Vector3, t: Double) -> Vector3 {
        return Vector3(a.v + simd_double3(x: t, y: t, z: t))
    }
    
    @inlinable static func *(a: Vector3, t: Double) -> Vector3 {
        return Vector3(a.v * simd_double3(x: t, y: t, z: t))
    }
    
    @inlinable static func *(t: Double, a: Vector3) -> Vector3 {
        return Vector3(simd_double3(x: t, y: t, z: t) * a.v)
    }

    @inlinable static func /(a: Vector3, t: Double) -> Vector3 {
        return Vector3(a.v / simd_double3(x: t, y: t, z: t))
    }
    
    @inlinable static func +(a: Vector3, b: Vector3) -> Vector3 {
        return Vector3(a.v + b.v)
    }
    
    @inlinable static func -(a: Vector3, b: Vector3) -> Vector3 {
        return Vector3(a.v - b.v)
    }
    
    @inlinable static func *(a: Vector3, b: Vector3) -> Vector3 {
        return Vector3(a.v * b.v)
    }
    
    @inlinable static func /(a: Vector3, b: Vector3) -> Vector3 {
        return Vector3(a.v / b.v)
    }
    
    @inlinable static func dot(_ a: Vector3, _ b: Vector3) -> Double {
        return simd_dot(a.v, b.v)
    }
    
    @inlinable static func cross(_ a: Vector3, _ b: Vector3) -> Vector3 {
        return Vector3(simd_cross(a.v, b.v))
    }
    
    @inlinable static func reflect(_ a: Vector3, _ n: Vector3) -> Vector3 {
        return Vector3(simd_reflect(a.v, n.v))
    }
    
    @inlinable static func refract(_ a: Vector3, _ n: Vector3, _ i: Double) -> Vector3? {
        // TODO: Use simd_refract
        return Vector3(simd_refract(a.v, n.v, i))
//        let uv = a.normalized()
//        let dt = dot(uv, n)
//        let d = 1.0 - (i * i * (1 - (dt * dt)))
//        guard d > 0 else {
//            return nil
//        }
//        return (i * (uv - (n * dt))) - (n * sqrt(d))
//        return Vector3(simd_refract(a.v, n.v, i))
    }
    
    @inlinable static func lerp(from a: Vector3, to b: Vector3, t: Double) -> Vector3 {
        return Vector3(simd_mix(a.v, b.v, simd_double3(x: t, y: t, z: t)))
    }
    
    @inlinable static func random() -> Vector3 {
        let range = Random(range: Range(min: -1, max: 1))
        return Vector3(
            x: range.next(),
            y: range.next(),
            z: range.next()
        )
    }
    
    @inlinable static func randomUnitDisk() -> Vector3 {
        let a = Random.unit.next() * Double.pi * 2
        let r = Random.unit.next()
        return Vector3(
            x: cos(a) * r,
            y: sin(a) * r,
            z: 0
        )
    }
}
