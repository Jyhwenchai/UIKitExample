//
//  QRCodeScannerViewer.swift
//  QRCodeScannerViewer
//
//  Created by 蔡志文 on 2021/9/14.
//

import Foundation
import AVFoundation

protocol QRCodeScannerViewer {
    var session: AVCaptureSession? { get set }
}

