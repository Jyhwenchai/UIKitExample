//
//  LoadingView.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/19.
//

import UIKit

class LoadingView: UIView {
    
    var isAnimating: Bool = false
    
    var lineWidth: CGFloat = 5 {
        didSet {
            shapeLayer.lineWidth = lineWidth
        }
    }
    var font: UIFont = UIFont.systemFont(ofSize: 8)

    let animateLayer = CALayer()
    
    lazy var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0.75
        shapeLayer.lineCap = .round
        return shapeLayer
    }()
    
    lazy var gradientLayer: CAGradientLayer = {
        let colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.colors = colors
        return gradientLayer
    }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.text = "0%"
        label.font = font
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        animateLayer.backgroundColor = UIColor.white.cgColor
        layer.addSublayer(animateLayer)
        animateLayer.addSublayer(gradientLayer)
        animateLayer.mask = shapeLayer
        addSubview(textLabel)
        animateLayer.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        animateLayer.frame = bounds
        gradientLayer.frame = bounds
        shapeLayer.frame = bounds
        let bezierPath = UIBezierPath(arcCenter: CGPoint(x: bounds.width / 2, y: bounds.height / 2), radius: bounds.width / 2 - lineWidth, startAngle: 0, endAngle: Double.pi * 2, clockwise: true)
        shapeLayer.path = bezierPath.cgPath
        gradientLayer.shadowPath = bezierPath.cgPath
        textLabel.frame = bounds
    }
    
    func startAnimating() {
        if isAnimating { return }
        textLabel.isHidden = false
        animateLayer.isHidden = false
        isAnimating = true
        let rotationAnimtion = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimtion.fromValue = 0
        rotationAnimtion.toValue = Double.pi * 2
        rotationAnimtion.repeatCount = Float.greatestFiniteMagnitude
        rotationAnimtion.duration = 1
        animateLayer.add(rotationAnimtion, forKey: nil)
    }
    
    func stopAnimating() {
        animateLayer.isHidden = true
        animateLayer.removeAllAnimations()
        isAnimating = false
        textLabel.text = "0%"
        textLabel.isHidden = true
    }

}
