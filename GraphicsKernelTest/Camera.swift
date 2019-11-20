//
//  Camera.swift
//  GraphicsKernelTest
//
//  Created by Luke Van In on 2019/11/19.
//  Copyright © 2019 eventcloud. All rights reserved.
//

import Foundation
import CoreGraphics

struct Camera {
    let origin: Vector3
    let corner: Vector3
    let horizontal: Vector3
    let vertical: Vector3
    let u: Vector3
    let v: Vector3
    let w: Vector3
    let lensRadius: Double
    
    init(lookOrigin: Vector3, lookTarget: Vector3, up: Vector3, fieldOfView: Double, aspect: Double, aperture: Double, focusDistance: Double) {
        let theta = fieldOfView * Double.pi / 180
        let halfHeight = tan(theta / 2)
        let halfWidth = aspect * halfHeight
        let w = (lookOrigin - lookTarget).normalized()
        let u = Vector3.cross(up, w).normalized()
        let v = Vector3.cross(w, u)
        let tw = halfWidth * focusDistance
        let th = halfHeight * focusDistance
        self.origin = lookOrigin
        self.corner = origin - (u * tw) - (v * th) - (w * focusDistance)
        self.horizontal = u * (tw * 2)
        self.vertical = v * (th * 2)
        self.lensRadius = aperture / 2
        self.u = u
        self.v = v
        self.w = w
    }
    
    func ray(coordinate: Coordinate) -> Ray {
        let rayDisk = Vector3.randomUnitDisk() * self.lensRadius
        let offset = (self.u * rayDisk.x) + (self.v * rayDisk.y)
        return Ray(
            origin: origin + offset,
            direction: (corner + (horizontal * coordinate.x) + (vertical * coordinate.y)) - origin - offset
        )
    }
}
