//
//  ViewController.swift
//  GraphicsKernelTest
//
//  Created by Luke Van In on 2019/11/18.
//  Copyright © 2019 eventcloud. All rights reserved.
//

import UIKit

private func testPatternKernel(renderSize: IntegralCoordinate) -> Kernel {
    let w = Double(renderSize.x)
    let h = Double(renderSize.y)
    return { coordinate in
        let x = coordinate.x
        let y = coordinate.y
        let u = Double(x)
        let v = Double(y)
        
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
    let unitDirection = ray.direction.normalized()
    let t = 0.5 * (unitDirection.y + 1)
    let startColor = Vector3(x: 1, y: 1, z: 1)
    let endColor = Vector3(x: 0.5, y: 0.7, z: 1.0)
    return Vector3.lerp(from: startColor, to: endColor, t: 1.0 - t)
}


private func makeRandomWorld() -> Hitable {
    
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
            material: DielectricMaterial(
                refractiveIndex: 1.5
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
            material: MetalMaterial(
                albedo: Vector3(r: 0.8, g: 0.6, b: 0.5),
                fuzz: 0
            )
        )
    )
    
    // Small spheres
    let offsetRange = Double(-0.5) ..< Double(0.5)
    let colorRange = Double(0.2) ..< Double(0.8)
    let anchor = Vector3(x: 4, y: -0.2, z: 0)
    
    for y in -3 ..< 3 {
        for x in -8 ..< 8 {
            let center = Vector3(
                x: Double(x) + (Double.random(in: offsetRange) * 0.9),
                y: -0.2,
                z: Double(y) + (Double.random(in: offsetRange) * 0.9)
            )
            
            if (center - anchor).length() > 0.9 {
                let material: Material
                let m = Double.random(in: 0 ..< 1)
                
                if m > 0.2 {
                    material = LambertianMaterial(
                        albedo: Vector3(
                            r: Double.random(in: colorRange),
                            g: Double.random(in: colorRange),
                            b: Double.random(in: colorRange)
                        )
                    )
                }
                else if m > 0.1 {
                    material = MetalMaterial(
                        albedo: Vector3(
                            r: Double.random(in: colorRange),
                            g: Double.random(in: colorRange),
                            b: Double.random(in: colorRange)
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

private func makeTestWorld5() -> Hitable {
    let items = [
        // Ground
        Sphere(
            origin: Vector3(x: 0, y: 100.5, z: -1),
            radius: 100,
            material: LambertianMaterial(
                albedo: Vector3(r: 0.8, g: 0.8, b: 0.8)
            )
        ),
        Sphere(
            origin: Vector3(x: 1, y: 0, z: -1),
            radius: 0.5,
            material: LambertianMaterial(
                albedo: Vector3(r: 0.8, g: 0.8, b: 0.1)
            )
        ),
        Sphere(
            origin: Vector3(x: 0, y: 0, z: -1),
            radius: 0.5,
            material: MetalMaterial(
                albedo: Vector3(r: 0.9, g: 0.1, b: 0.1),
                fuzz: 0.1
            )
        ),
        Sphere(
            origin: Vector3(x: -1, y: 0, z: -1),
            radius: 0.5,
            material: LambertianMaterial(
                albedo: Vector3(r: 0.1, g: 0.1, b: 0.8)
            )
        ),
    ]
    return HitableList(items: items)
}

private func makeTestWorld4() -> Hitable {
    let items = [
        // Ground
        Sphere(
            origin: Vector3(x: 0, y: 100.5, z: -1),
            radius: 100,
            material: MetalMaterial(
                albedo: Vector3(r: 0.66, g: 0.66, b: 0.66),
                fuzz: 0.5
            )
        ),
        Sphere(
            origin: Vector3(x: 0.51, y: 0.1, z: -1),
            radius: 0.4,
            material: MetalMaterial(
                albedo: Vector3(r: 0.9, g: 0.1, b: 0.1),
                fuzz: 0.1
            )
        ),
        Sphere(
            origin: Vector3(x: -0.51, y: 0, z: -1),
            radius: 0.5,
            material: DielectricMaterial(
                refractiveIndex: 1.5
            )
        ),
    ]
    return HitableList(items: items)
}

private func makeTestWorld3() -> Hitable {
    let items = [
        // Ground
        Sphere(
            origin: Vector3(x: 0, y: 100.5, z: -1),
            radius: 100,
            material: LambertianMaterial(
                albedo: Vector3(r: 0.8, g: 0.8, b: 0.0)
            )
        ),
        Sphere(
            origin: Vector3(x: 0.51, y: 0, z: -1),
            radius: 0.5,
            material: DielectricMaterial(
                refractiveIndex: 1.5
            )
        ),
        Sphere(
            origin: Vector3(x: -0.51, y: 0, z: -1),
            radius: 0.5,
            material: LambertianMaterial(
                albedo: Vector3(r: 0.8, g: 0.8, b: 0.8)
            )
        ),
    ]
    return HitableList(items: items)
}

private func makeTestWorld2() -> Hitable {
    let items = [
        // Ground
        Sphere(
            origin: Vector3(x: 0, y: 100.5, z: -1),
            radius: 100,
            material: LambertianMaterial(
                albedo: Vector3(r: 0.8, g: 0.8, b: 0)
            )
        ),
        Sphere(
            origin: Vector3(x: 0.51, y: 0, z: -1),
            radius: 0.5,
            material: LambertianMaterial(
                albedo: Vector3(r: 0.1, g: 0.2, b: 0.5)
            )
        ),
        Sphere(
            origin: Vector3(x: -0.51, y: 0, z: -1),
            radius: 0.5,
            material: MetalMaterial(
                albedo: Vector3(r: 0.8, g: 0.6, b: 0.2),
                fuzz: 0.5
            )
        ),
    ]
    return HitableList(items: items)
}

private func makeTestWorld1() -> Hitable {
    let items = [
        // Ground
        Sphere(
            origin: Vector3(x: 0, y: 100.5, z: -1),
            radius: 100,
            material: LambertianMaterial(
                albedo: Vector3(r: 0.8, g: 0.8, b: 0.8)
            )
        ),
        Sphere(
            origin: Vector3(x: 0.51, y: 0, z: -1),
            radius: 0.5,
            material: LambertianMaterial(
                albedo: Vector3(r: 0.1, g: 0.1, b: 0.8)
            )
        ),
        Sphere(
            origin: Vector3(x: -0.51, y: 0, z: -1),
            radius: 0.5,
            material: LambertianMaterial(
                albedo: Vector3(r: 0.8, g: 0.1, b: 0.1)
            )
        ),
    ]
    return HitableList(items: items)
}

class ViewController: UIViewController {
    
    var kernelView: KernelView? {
        return self.view as? KernelView
    }
    
    private let renderQueue = DispatchQueue(label: "render-queue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let viewportSize = IntegralCoordinate(
            x: 32 * 10,
            y: 32 * 10
        )
        
//        let lookOrigin = Vector3(x: 0, y: -0.5, z: 2)
        let lookOrigin = Vector3(x: -3, y: -0.5, z: 2)
        let lookTarget = Vector3(x: 0, y: 0, z: -1)
        let focusDistance = (lookOrigin - lookTarget).length()
        let aperture = Double(0.1)
        
        let camera = Camera(
            lookOrigin: lookOrigin,
            lookTarget: lookTarget,
            up: Vector3(x: 0, y: 1, z: 0),
            fieldOfView: 30,
            aspect: Double(viewportSize.x) / Double(viewportSize.y),
            aperture: aperture,
            focusDistance: focusDistance
        )
        
        //    let world = makeRandomWorld()
        let world = makeTestWorld4()

        let renderer = Raytracer(
            viewportSize: viewportSize,
            camera: camera,
            world: world,
            background: sky,
            config: Raytracer.Config(
                sampleCount: 500,
                sampleDepth: 20
            )
        )

        renderer.render() { image in
            self.kernelView?.image = image
        }
    }
}

