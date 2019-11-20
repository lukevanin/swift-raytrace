//
//  KernelView.swift
//  GraphicsKernelTest
//
//  Created by Luke Van In on 2019/11/18.
//  Copyright © 2019 eventcloud. All rights reserved.
//

import UIKit

typealias Kernel = (IntegralCoordinate) -> Color

final class KernelView: UIView {
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        initializeImageView()
//        initializeRenderTimer()
    }
    
    private func initializeImageView() {
        guard imageView.superview == nil else {
            return
        }
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.frame = CGRect(origin: .zero, size: bounds.size)
        addSubview(imageView)
    }
    
//    private func initializeRenderTimer() {
//        guard renderTimer == nil else {
//            return
//        }
//        renderTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
//            self?.updateDisplay()
//        }
//    }
    
//    func render() {
//        // TODO: Render to CGImage. Set CGImage on CALayer directly
//        guard let buffer = self.buffer else {
//            return
//        }
//        renderQueue.async { [weak self] in
//            guard let self = self else {
//                return
//            }
//            let size = buffer.size
//            let startTime = Date()
//            for kernel in self.kernels {
//                for y in 0 ..< size.y {
//                    for x in 0 ..< size.x {
//                        let coordinate = IntegralCoordinate(
//                            x: x,
//                            y: y
//                        )
//                        let color = kernel(coordinate)
//                        buffer.set(color: color, at: coordinate)
//                    }
//                }
//            }
//            let endTime = Date()
//            let elapsedTime = endTime.timeIntervalSince(startTime)
//            print("Render time = \(elapsedTime) seconds")
////            self.renderLine(y: y + stride, stride: stride, buffer: buffer)
//            DispatchQueue.main.async {
//                self.updateDisplay()
//            }
//        }
//    }
}
