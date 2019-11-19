//
//  Materials.swift
//  GraphicsKernelTest
//
//  Created by Luke Van In on 2019/11/19.
//  Copyright © 2019 eventcloud. All rights reserved.
//

import Foundation
import CoreGraphics

struct LambertianMaterial: Material {
    let albedo: Vector3
    func scatter(ray: Ray, hit: Hit) -> MaterialRay? {
        let target = hit.coordinate + hit.normal + Vector3.random().normal()
        return MaterialRay(
            attenuation: albedo,
            ray: Ray(
                origin: hit.coordinate,
                direction: target - hit.coordinate
            )
        )
    }
}

struct MetalMaterial: Material {
    let albedo: Vector3
    let fuzz: CGFloat
    
    func scatter(ray: Ray, hit: Hit) -> MaterialRay? {
        let reflected = Vector3.reflect(ray.direction, hit.normal)
        let direction = reflected + (Vector3.random().normal() * fuzz)
        guard Vector3.dot(direction, hit.normal) > 0 else {
            // Ray not reflected
            return nil
        }
        return MaterialRay(
            attenuation: albedo,
            ray: Ray(
                origin: hit.coordinate,
                direction: direction
            )
        )
    }
}

struct DielectricMaterial: Material {
    let refractiveIndex: CGFloat
    
    func scatter(ray: Ray, hit: Hit) -> MaterialRay? {
        let reflected = Vector3.reflect(ray.direction, hit.normal)
        let attenuation = Vector3(x: 1.0, y: 1.0, z: 1.0)
        let dotProduct = Vector3.dot(ray.direction, hit.normal)
        let outwardNormal: Vector3
        let refractiveIndex: CGFloat
        let cosine: CGFloat
        
        if dotProduct > 0 {
            outwardNormal = -hit.normal
            refractiveIndex = self.refractiveIndex
            cosine = (refractiveIndex * dotProduct) / ray.direction.length()
        }
        else {
            outwardNormal = hit.normal
            refractiveIndex = 1.0 / self.refractiveIndex
            cosine = -dotProduct / ray.direction.length()
        }
        
        if let refracted = Vector3.refract(ray.direction, outwardNormal, refractiveIndex) {
            let p = schlick(cosine: cosine, refractiveIndex: refractiveIndex)
            if CGFloat.random(in: 0 ..< 1.0) >= p {
                return MaterialRay(
                    attenuation: attenuation,
                    ray: Ray(origin: hit.coordinate, direction: refracted)
                )
            }
            else {
                return MaterialRay(
                    attenuation: attenuation,
                    ray: Ray(origin: hit.coordinate, direction: reflected)
                )
            }
        }
        else {
            return MaterialRay(
                attenuation: attenuation,
                ray: Ray(origin: hit.coordinate, direction: reflected)
            )
        }
    }
    
    private func schlick(cosine: CGFloat, refractiveIndex: CGFloat) -> CGFloat {
        let r0 = (1 - refractiveIndex) / (1 + refractiveIndex)
        let r1 = r0 * r0
        return r1 + ((1 - r1) * pow(1 - cosine, 5))
    }
}
