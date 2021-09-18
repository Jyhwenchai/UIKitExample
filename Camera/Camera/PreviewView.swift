//
//  PreviewView.swift
//  PreviewView
//
//  Created by 蔡志文 on 2021/9/3.
//

import UIKit
import AVFoundation

class PreviewView: UIView {
    
    var session: AVCaptureSession? {
        get {
            videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
}
