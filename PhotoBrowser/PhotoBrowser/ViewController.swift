//
//  ViewController.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/4.
//


import UIKit

class ViewController: UIViewController {
    
    let queue = OperationQueue()
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        layer.frame = CGRect(x: 100, y: 100, width: 110, height: 110)
        
        let bezierPath = UIBezierPath(arcCenter: CGPoint(x: 55, y: 55), radius: 50, startAngle: 0, endAngle: Double.pi * 2, clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 5
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0.75
        shapeLayer.lineCap = .round
        shapeLayer.path = bezierPath.cgPath
        
        let colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        let gradientLayer = CAGradientLayer()
        gradientLayer.shadowPath = bezierPath.cgPath
        gradientLayer.frame = CGRect(x: 50, y: 50, width: 60, height: 60)
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.colors = colors
        layer.addSublayer(gradientLayer)
        layer.mask = shapeLayer
//        view.layer.addSublayer(layer)
        
        let rotationAnimtion = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimtion.fromValue = 0
        rotationAnimtion.toValue = Double.pi * 2
        rotationAnimtion.repeatCount = Float.greatestFiniteMagnitude
        rotationAnimtion.duration = 1
//        layer.add(rotationAnimtion, forKey: nil)
        
        view.backgroundColor = .black
        
        let loadingView = LoadingView(frame: CGRect(x: 100, y: 100, width: 110, height: 110))
        view.addSubview(loadingView)
        loadingView.startAnimating()
    }
    
    @IBAction func downLoadAction(_ sender: Any) {
        let url = "https://eoimages.gsfc.nasa.gov/images/imagerecords/8000/8108/ipcc_bluemarble_east_lrg.jpg"
    
        guard let operation = NetworkImageOperation(string: url, completion: { data, error in
        }) else { return }
        
        operation.progressClosure = { progress in
           print("progress: \(progress)")
        }
        operation.completionBlock = { [weak operation] in
            guard let operation = operation else { return }
            DispatchQueue.main.async {
                self.imageView.image = operation.image
            }
        }
        
        queue.addOperation(operation)
        


    }
    

}

