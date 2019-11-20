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
        let target = hit.coordinate + hit.normal + Vector3.random().normalized()
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
    let fuzz: Double
    
    func scatter(ray: Ray, hit: Hit) -> MaterialRay? {
        let reflected = Vector3.reflect(ray.direction, hit.normal)
        let direction = reflected + (Vector3.random().normalized() * fuzz)
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
    let refractiveIndex: Double
    
    func scatter(ray: Ray, hit: Hit) -> MaterialRay? {
        let reflected = Vector3.reflect(ray.direction, hit.normal)
        let dotProduct = Vector3.dot(ray.direction, hit.normal)
        let outwardNormal: Vector3
        let refractiveIndex: Double
        let cosine: Double
        
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
        
        let direction: Vector3
        if let refracted = Vector3.refract(ray.direction, outwardNormal, refractiveIndex) {
            let reflectionProbability = schlick(cosine: cosine, refractiveIndex: refractiveIndex)
            let r = Random(range: Range(min: 0, max: 1.0))
            if r.next() < reflectionProbability {
                direction = reflected
            }
            else {
                direction = refracted
            }
        }
        else {
            direction = reflected
        }
        
        return MaterialRay(
            attenuation: Vector3(x: 1.0, y: 1.0, z: 1.0),
            ray: Ray(origin: hit.coordinate, direction: direction)
        )
    }
    
    private func schlick(cosine: Double, refractiveIndex: Double) -> Double {
        let r0 = (1 - refractiveIndex) / (1 + refractiveIndex)
        let r1 = r0 * r0
        return r1 + ((1 - r1) * pow(1 - cosine, 5))
    }
}
