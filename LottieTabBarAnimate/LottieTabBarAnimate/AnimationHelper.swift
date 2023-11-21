//
//  Animationhelper.swift
//  LottieTabBarAnimate
//
//  Created by 蔡志文 on 11/9/23.
//

import UIKit
import QuartzCore
import Lottie

class AnimationHelper: CAAnimation {
  class func gravityAnimation(_ animationView: UIView) {
    let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
    animation.values = [0.0, -4.15, -7.26, -9.34, -10.37, -9.34, -7.26, -4.15, 0.0, 2.0, -2.9, -4.94, -6.11, -6.42, -5.86, -4.44, -2.16, 0.0]
    animation.duration = 0.55
    animation.beginTime = CACurrentMediaTime() + 0.5
    animationView.layer.add(animation, forKey: nil)
  }

  class func zoomIntoZoomOutAnimation(_ animationView: UIView) {
    let animation = CABasicAnimation(keyPath: "transform.scale")
    animation.duration = 0.2
    animation.repeatCount = 1
    animation.autoreverses = true
    animation.fromValue = 0.7
    animation.toValue = 1.3
    animationView.layer.add(animation, forKey: nil)
  }

  class func zAxisRotationAnimation(_ animationView: UIView) {
    let animation = CABasicAnimation(keyPath: "transform.rotation.z")
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    animation.duration = 0.2
    animation.repeatCount = 1
    animation.isRemovedOnCompletion = true
    animation.fromValue = 0
    animation.toValue = CGFloat.pi
    animationView.layer.add(animation, forKey: nil)
  }


  class func yAxisMovementAnimation(_ animationView: UIView) {
    let animation = CABasicAnimation(keyPath: "transform.translation.y")
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    animation.duration = 0.2
    animation.repeatCount = 1
    animation.isRemovedOnCompletion = true
    animation.fromValue = 0
    animation.toValue = -10
    animationView.layer.add(animation, forKey: nil)
  }

  class func zoomInKeepEffectAnimation(_ views: [UIView], index: Int) {
    let animation = CABasicAnimation(keyPath: "transform.scale")
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    animation.duration = 0.2
    animation.repeatCount = 1
    animation.isRemovedOnCompletion = false
    animation.fillMode = .forwards
    animation.fromValue = 1.0
    animation.toValue = 1.5
    views[index].layer.add(animation, forKey: nil)
    for (i, view) in views.enumerated() where index != i {
      view.layer.removeAllAnimations()
    }
  }

  class func lottieAnimation(_ animationView: UIView, index: Int) {
    var frame = animationView.frame
    frame.origin.x = 0
    frame.origin.y = 0
    var lottieAnimationView: LottieAnimationView? = LottieAnimationView(name: "tabbar\(index+1)")
    lottieAnimationView?.frame = frame
    lottieAnimationView?.contentMode = .scaleAspectFill
    lottieAnimationView?.animationSpeed = 1

    lottieAnimationView?.center = animationView.center
    animationView.superview?.addSubview(lottieAnimationView!)
    animationView.isHidden = true
    lottieAnimationView?.play(fromProgress: 0, toProgress: 1) { finished in
      animationView.isHidden = false
      lottieAnimationView?.removeFromSuperview()
      lottieAnimationView = nil
    }
  }
}
