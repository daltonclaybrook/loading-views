//
//  CircleSegmentView.swift
//  LoadingViews
//
//  Created by Dalton Claybrook on 2/12/17.
//  Copyright © 2017 Claybrook Software. All rights reserved.
//

import UIKit

class CircleSegmentView: UIView {
    
    var isAnimating = false
    private var shapeLayers = [CAShapeLayer]()
    override var bounds: CGRect {
        didSet { configureLayout() }
    }
    
    override var intrinsicContentSize: CGSize {
        let size: CGFloat = 60
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
        createRotateAnimation()
    }
    
    private func createAllAnimations() {
//        createAnimation(for: shapeLayers.first!, fromValue: shapeLayers.first!.lineWidth)
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
        animation.duration = 10.0
        animation.repeatCount = .greatestFiniteMagnitude
        layer.add(animation, forKey: nil)
    }
    
    private func createShapeLayersIfNecessary() {
        guard shapeLayers.count == 0 else { return }
        var lengthRemaining: CGFloat = 1.0
        while lengthRemaining > 0.0 {
            var length = CGFloat(arc4random_uniform(50) + 50) / 1000.0 // 0.05 - 0.1
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
        return CGFloat(arc4random_uniform(25) + 5)
    }
}
