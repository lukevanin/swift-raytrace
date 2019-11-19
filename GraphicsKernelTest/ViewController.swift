//
//  ViewController.swift
//  GraphicsKernelTest
//
//  Created by Luke Van In on 2019/11/18.
//  Copyright © 2019 eventcloud. All rights reserved.
//

import UIKit

private func testPatternKernel(renderSize: IntegralCoordinate) -> Kernel {
    let w = CGFloat(renderSize.x)
    let h = CGFloat(renderSize.y)
    return { coordinate in
        let x = coordinate.x
        let y = coordinate.y
        let u = CGFloat(x)
        let v = CGFloat(y)
        
        let a = x % 10 >= 5
        let b = y % 10 >= 5
        
        let color = Color(
            r: u / w,
            g: a != b ? 0.0 : 1.0,
            b: v / h
        )
        return color
    }
}

private func sky(ray: Ray) -> Color {
    let unitDirection = ray.direction.normal()
    let t = 0.5 * (unitDirection.y + 1)
    let startColor = Vector3(x: 1, y: 1, z: 1)
    let endColor = Vector3(x: 0.5, y: 0.7, z: 1.0)
    return Vector3.lerp(from: startColor, to: endColor, t: 1.0 - t)
}

private func color(ray: Ray, world: Hitable, depth: Int) -> Color {
    let limits = Range(min: 0.001, max: CGFloat.greatestFiniteMagnitude)
    if let hit = world.hit(ray: ray, limits: limits) {
        if let scatter = hit.material.scatter(ray: ray, hit: hit), depth > 0 {
            return color(ray: scatter.ray, world: world, depth: depth - 1) * scatter.attenuation
        }
        else {
            return Vector3.zero
        }
    }
    else {
        return sky(ray: ray)
    }
}

private func makeRandomWorld() -> HitableList {
    
    var items = [Hitable]()
    
    // Ground
    items.append(
        Sphere(
            origin: Vector3(x: 0, y: 1000, z: 0),
            radius: 1000,
            material: LambertianMaterial(
                albedo: Vector3(r: 0.5, g: 0.5, b: 0.5)
            )
        )
    )

    // Large spheres
    items.append(
        Sphere(
            origin: Vector3(x: 4, y: -1, z: 0),
            radius: 1.0,
            material: MetalMaterial(
                albedo: Vector3(r: 0.8, g: 0.6, b: 0.5),
                fuzz: 0
            )
        )
    )
    
    items.append(
        Sphere(
            origin: Vector3(x: -4, y: -1, z: 0),
            radius: 1.0,
            material: LambertianMaterial(
                albedo: Vector3(r: 0.33, g: 0.33, b: 0.33)
            )
        )
    )
    
    items.append(
        Sphere(
            origin: Vector3(x: 0, y: -1, z: 0),
            radius: 1.0,
            material: DielectricMaterial(
                refractiveIndex: 1.5
            )
        )
    )
    
    // Small spheres
    let offsetRange = CGFloat(-0.5) ..< CGFloat(0.5)
    let colorRange = CGFloat(0.2) ..< CGFloat(0.8)
    let anchor = Vector3(x: 4, y: -0.2, z: 0)
    
    for y in -3 ..< 3 {
        for x in -8 ..< 8 {
            let center = Vector3(
                x: CGFloat(x) + (CGFloat.random(in: offsetRange) * 0.9),
                y: -0.2,
                z: CGFloat(y) + (CGFloat.random(in: offsetRange) * 0.9)
            )
            
            if (center - anchor).length() > 0.9 {
                let material: Material
                let m = CGFloat.random(in: 0 ..< 1)
                
                if m > 0.2 {
                    material = LambertianMaterial(
                        albedo: Vector3(
                            r: CGFloat.random(in: colorRange),
                            g: CGFloat.random(in: colorRange),
                            b: CGFloat.random(in: colorRange)
                        )
                    )
                }
                else if m > 0.1 {
                    material = MetalMaterial(
                        albedo: Vector3(
                            r: CGFloat.random(in: colorRange),
                            g: CGFloat.random(in: colorRange),
                            b: CGFloat.random(in: colorRange)
                        ),
                        fuzz: 0
                    )
                }
                else {
                    material = DielectricMaterial(
                        refractiveIndex: 1.5
                    )
                }
                
                items.append(
                    Sphere(
                        origin: center,
                        radius: 0.2,
                        material: material
                    )
                )
            }
        }
    }
    
    // Make world
    return HitableList(items: items)
}

private func raytraceKernel(renderSize: IntegralCoordinate) -> Kernel {
    
//    let camera = Camera(
//        origin: Vector3(x: 0, y: 0, z: 0),
//        corner: Vector3(x: -1, y: -1, z: -1),
//        horizontal: Vector3(x: 2, y: 0, z: 0),
//        vertical: Vector3(x: 0, y: 2, z: 0)
//    )
    
    let lookOrigin = Vector3(x: 18, y: -3.0, z: 4)
    let lookTarget = Vector3(x: 0, y: 0, z: -1)
    let focusDistance = (lookOrigin - lookTarget).length()
    let aperture = CGFloat(0.1)
    
    let camera = Camera(
        lookOrigin: lookOrigin,
        lookTarget: lookTarget,
        up: Vector3(x: 0, y: 1, z: 0),
        fieldOfView: 10,
        aspect: CGFloat(renderSize.x) / CGFloat(renderSize.y),
        aperture: aperture,
        focusDistance: focusDistance
    )
    
    let world = makeRandomWorld()
    
//    let world = HitableList(items: [
//        // Ground
//        Sphere(
//            origin: Vector3(x: 0, y: 100.5, z: -1),
//            radius: 100,
//            material: LambertianMaterial(
//                albedo: Vector3(r: 0.8, g: 0.8, b: 0.8)
//            )
//        ),
////        // Middle
////        Sphere(
////            origin: Vector3(x: 0, y: 0, z: -1),
////            radius: 0.5,
////            material: LambertianMaterial(
////                albedo: Vector3(r: 0.1, g: 0.2, b: 0.5)
////            )
////        ),
////        // Right
////        Sphere(
////            origin: Vector3(x: 1, y: 0, z: -1),
////            radius: 0.5,
////            material: MetalMaterial(
////                albedo: Vector3(r: 0.8, g: 0.6, b: 0.2),
////                fuzz: 0.3
////            )
////        ),
////        // Left
////        Sphere(
////            origin: Vector3(x: -1, y: 0, z: -1),
////            radius: 0.5,
////            material: DielectricMaterial(
////                refactiveIndex: 1.5
////            )
////        ),
////        // Middle
////        Sphere(
////            origin: Vector3(x: 0.51, y: 0, z: -1),
////            radius: 0.5,
////            material: MetalMaterial(
////                albedo: Vector3(r: 0.9, g: 0.9, b: 0.9),
////                fuzz: 0.1
////            )
////        ),
////        // Left
////        Sphere(
////            origin: Vector3(x: -0.51, y: 0, z: -1),
////            radius: 0.5,
////            material: DielectricMaterial(
////                refractiveIndex: 1.1
////            )
////        ),
//        // Right
//        Sphere(
//            origin: Vector3(x: 1, y: 0, z: -1),
//            radius: 0.5,
//            material: LambertianMaterial(
//                albedo: Vector3(r: 0.8, g: 0.8, b: 0.1)
//            )
//        ),
//        // Middle
//        Sphere(
//            origin: Vector3(x: 0, y: 0, z: -1),
//            radius: 0.5,
//            material: MetalMaterial(
//                albedo: Vector3(r: 0.9, g: 0.1, b: 0.1),
//                fuzz: 0.1
//            )
//        ),
//        // Left
//        Sphere(
//            origin: Vector3(x: -1, y: 0, z: -1),
//            radius: 0.5,
//            material: LambertianMaterial(
//                albedo: Vector3(r: 0.1, g: 0.1, b: 0.8)
//            )
//        ),
//    ])
    
    let sampleCount = 100
    let sampleRange = CGFloat(-0.5) ..< CGFloat(0.5)
    let sampleDepth = 50
    
    return { coordinate in
        var a = Vector3.zero
        for _ in 0 ..< sampleCount {
            let p = CGFloat.random(in: sampleRange)
            let q = CGFloat.random(in: sampleRange)
            let u = (CGFloat(coordinate.x) + p) / CGFloat(renderSize.x)
            let v = (CGFloat(coordinate.y) + q) / CGFloat(renderSize.y)
            let r = camera.ray(coordinate: Coordinate(x: u, y: v))
            let c = color(ray: r, world: world, depth: sampleDepth)
            a = a + c
        }
        return a / CGFloat(sampleCount)
    }
}

class ViewController: UIViewController {
    
    var kernelView: KernelView? {
        return self.view as? KernelView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let renderSize = IntegralCoordinate(x: 200, y: 200)
        let imageBuffer = Buffer(size: renderSize)
        
        //        kernelView?.kernels.append(testPatternKernel(renderSize: renderSize))
        kernelView?.kernels.append(raytraceKernel(renderSize: renderSize))

        kernelView?.buffer = imageBuffer
        kernelView?.render()
    }
}

