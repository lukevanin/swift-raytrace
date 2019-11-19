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
    
    var buffer: Buffer?
    
    var kernels = [Kernel]()
    
    private var renderTimer: Timer?
    private var isRendering = false
    private var renderQueue = DispatchQueue(
        label: "render-queue",
        qos: .userInteractive
    )

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
        initializeRenderTimer()
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
    
    private func initializeRenderTimer() {
        guard renderTimer == nil else {
            return
        }
        renderTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.updateDisplay()
        }
    }
    
    func render() {
        // TODO: Render to CGImage. Set CGImage on CALayer directly
        guard let buffer = self.buffer else {
            return
        }
        renderQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            guard self.isRendering == false else {
                return
            }
            self.isRendering = true
            self.renderLine(y: 0, stride: 2, buffer: buffer)
            self.renderLine(y: 1, stride: 2, buffer: buffer)
        }
    }
    
    private func renderLine(y: Int, stride: Int, buffer: Buffer) {
        renderQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            let size = buffer.size
            guard y < size.y else {
                return
            }
//            let startTime = Date()
            for kernel in self.kernels {
                for x in 0 ..< size.x {
                    let coordinate = IntegralCoordinate(
                        x: x,
                        y: y
                    )
                    let color = kernel(coordinate)
                    buffer.set(color: color, at: coordinate)
                }
            }
//            let endTime = Date()
//            let elapsedTime = endTime.timeIntervalSince(startTime)
//            print("Line #\(y) render time = \(elapsedTime) seconds")
            self.renderLine(y: y + stride, stride: stride, buffer: buffer)
        }
    }
    
    private func updateDisplay() {
        renderQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            guard let cgImage = self.buffer?.cgImage() else {
                return
            }
            let image = UIImage(cgImage: cgImage)
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
}
