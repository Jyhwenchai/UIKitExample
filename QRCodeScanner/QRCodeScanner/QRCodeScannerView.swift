//
//  QRCodeScannerView.swift
//  QRCodeScannerView
//
//  Created by 蔡志文 on 2021/9/14.
//

import UIKit
import AVFoundation


class QRCodeScannerView: UIView, QRCodeScannerViewer {
    
    var session: AVCaptureSession? {
        get {
            videoPreviewLayer.session
        }
        
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
}
