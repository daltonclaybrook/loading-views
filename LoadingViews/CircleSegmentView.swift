//
//  CircleSegmentView.swift
//  LoadingViews
//
//  Created by Dalton Claybrook on 2/12/17.
//  Copyright © 2017 Claybrook Software. All rights reserved.
//

import UIKit

class CircleSegmentView: UIView {
    
    enum MaskStyle {
        case outward, inward
    }
    
    var isAnimating = false
    var lineWidthRange: ClosedRange<CGFloat> = (20...60)
    var segmentLengthRange: ClosedRange<CGFloat> = (0.05...0.1) { didSet { configureLayout() } }
    var rotationDuration: CFTimeInterval = 7.5 { didSet { configureLayout() } }
    var maskStyle = MaskStyle.outward { didSet { configureLayout() } }
    
    private var shapeLayers = [CAShapeLayer]()
    override var bounds: CGRect {
        didSet { configureLayout() }
    }
    
    override var intrinsicContentSize: CGSize {
        let size: CGFloat = 100
        return CGSize(width: size, height: size)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clipsToBounds = false
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        configureLayout()
    }
    
    //MARK: Public
    
    func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true
        createAllAnimations()
    }
    
    func stopAnimating() {
        isAnimating = false
        shapeLayers.forEach { $0.removeAllAnimations() }
    }
    
    //MARK: Private
    
    private func configureLayout() {
        createShapeLayersIfNecessary()
        let path = UIBezierPath(ovalIn: bounds)
        shapeLayers.forEach { $0.path = path.cgPath }
        layer.mask = maskStyle == .outward ? createOutwardMask() : createInwardMask()
        createRotateAnimation()
    }
    
    private func createOutwardMask() -> CALayer {
        let path = UIBezierPath(rect: CGRect(x: -10000, y: -10000, width: 20000, height: 20000))
        path.append(UIBezierPath(ovalIn: bounds))
        path.usesEvenOddFillRule = true
        
        let maskLayer = CAShapeLayer()
        maskLayer.fillColor = UIColor.green.cgColor
        maskLayer.strokeColor = nil
        maskLayer.path = path.cgPath
        maskLayer.fillRule = kCAFillRuleEvenOdd
        return maskLayer
    }
    
    private func createInwardMask() -> CALayer {
        let path = UIBezierPath(ovalIn: bounds)
        
        let maskLayer = CAShapeLayer()
        maskLayer.fillColor = UIColor.green.cgColor
        maskLayer.strokeColor = nil
        maskLayer.path = path.cgPath
        return maskLayer
    }
    
    private func createAllAnimations() {
        shapeLayers.forEach { self.createAnimation(for: $0, fromValue: $0.lineWidth) }
    }
    
    private func createAnimation(for shapeLayer: CAShapeLayer, fromValue: CGFloat) {
        let toValue = randomLineWidth()
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self, weak shapeLayer] in
            guard let strongSelf = self, let shapeLayer = shapeLayer, strongSelf.isAnimating else { return }
            strongSelf.createAnimation(for: shapeLayer, fromValue: toValue)
        }
        let animation = CABasicAnimation(keyPath: "lineWidth")
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = CFTimeInterval(arc4random_uniform(1000) + 500) / 1000.0 // 0.5 - 1.5
        shapeLayer.lineWidth = toValue
        shapeLayer.add(animation, forKey: nil)
        CATransaction.commit()
    }
    
    private func createRotateAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0.0
        animation.toValue = CGFloat.pi * 2.0
        animation.duration = rotationDuration
        animation.repeatCount = .greatestFiniteMagnitude
        
        layer.removeAnimation(forKey: "rotation")
        layer.add(animation, forKey: "rotation")
    }
    
    private func createShapeLayersIfNecessary() {
        guard shapeLayers.count == 0 else { return }
        var lengthRemaining: CGFloat = 1.0
        while lengthRemaining > 0.0 {
            var length = randomSegmentLength()
            length = min(length, lengthRemaining)
            let epsilon: CGFloat = 0.005
            
            let shape = CAShapeLayer()
            shape.strokeStart = 1.0 - lengthRemaining + epsilon
            shape.strokeEnd = shape.strokeStart + length - epsilon
            shape.fillColor = nil
            shape.strokeColor = UIColor.black.cgColor
            shape.lineWidth = randomLineWidth()
            shape.lineCap = kCALineCapButt
            layer.addSublayer(shape)
            shapeLayers.append(shape)
            
            lengthRemaining -= length
        }
    }
    
    private func randomLineWidth() -> CGFloat {
        return CGFloat(arc4random_uniform(UInt32(lineWidthRange.upperBound-lineWidthRange.lowerBound))) + lineWidthRange.lowerBound
    }
    
    private func randomSegmentLength() -> CGFloat {
        let largeUpper = UInt32(segmentLengthRange.upperBound * 1000)
        let largeLower = UInt32(segmentLengthRange.lowerBound * 1000)
        let largeLength = arc4random_uniform(largeUpper-largeLower) + largeLower
        return CGFloat(largeLength) / 1000.0
    }
}
