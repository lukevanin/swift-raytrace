//
//  Geometry.swift
//  GraphicsKernelTest
//
//  Created by Luke Van In on 2019/11/19.
//  Copyright © 2019 eventcloud. All rights reserved.
//

import Foundation
import CoreGraphics

struct Sphere: Hitable {
    let origin: Vector3
    let radius: CGFloat
    let material: Material
    
    func hit(ray: Ray, limits: Range) -> Hit? {
        let oc = ray.origin - origin
        let a = Vector3.dot(ray.direction, ray.direction)
        let b = Vector3.dot(oc, ray.direction)
        let c = Vector3.dot(oc, oc) - (radius * radius)
        let d = (b * b) - (a * c)
        
        if d > 0 {
            // One or two intersections
            let s = sqrt(d)
            
            let t0 = (-b - s) / a
            if limits.contains(t0) {
                let p = ray.point(at: t0)
                return Hit(
                    coordinate: p,
                    normal: (p - origin) / radius,
                    t: t0,
                    material: material
                )
            }
            
            let t1 = (-b + s) / a
            if limits.contains(t1) {
                let p = ray.point(at: t1)
                return Hit(
                    coordinate: p,
                    normal: (p - origin) / radius,
                    t: t1,
                    material: material
                )
            }
        }
        
        // No intersection
        return nil
    }
}
