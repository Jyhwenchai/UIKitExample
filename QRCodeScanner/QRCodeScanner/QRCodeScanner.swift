//
//  QRCodeScanner.swift
//  QRCodeScanner
//
//  Created by 蔡志文 on 2021/9/14.
//

import UIKit
import AVFoundation
import Vision

class QRCodeScanner: NSObject {
    
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "qr coder scanner queue.")
    private var deviceInput: AVCaptureDeviceInput!
    private var scannerViewer: QRCodeScannerViewer
    
    private lazy var barcodeDetectionRequest: VNDetectBarcodesRequest = {
        let request = VNDetectBarcodesRequest(completionHandler: self.handleDetectedBarcodes)
        request.symbologies = [.qr, .aztec, .upce]
        return request
    }()
    
    enum SearchResult {
        case notFound
        case success(String)
    }
    
    var scanResult: ((SearchResult) -> Void)?
    var monitorLight: ((Double) -> Void)?
    
    init?(with scannerViewer: QRCodeScannerViewer) {
        self.scannerViewer = scannerViewer
        super.init()
        if !self.setup() {
            return nil
        }
        self.scannerViewer.session = session
    }
    
    private func setup() -> Bool {
        configureSession()
    }
    
    private func configureSession() -> Bool {
        
        session.beginConfiguration()
        
//        let frontVideoDeviceDiscoverySession: AVCaptureDevice.DiscoverySession
//        let backVideoDeviceDiscoverySession: AVCaptureDevice.DiscoverySession
//
//        if #available(iOS 10.2, *) {
//            if #available(iOS 13, *) {
//                backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInDualWideCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
//            } else {
//                backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
//            }
//
//        } else {
//            backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDuoCamera], mediaType: .video, position: .back)
//        }
//
//        if #available(iOS 11.1, *) {
//            frontVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera], mediaType: .video, position: .front)
//        } else {
//            frontVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
//        }
//
        guard let device = AVCaptureDevice.default(for: .video) else {
            session.commitConfiguration()
            return false
        }
        
        try? device.lockForConfiguration()
        device.autoFocusRangeRestriction = .near
        device.focusMode = .continuousAutoFocus
        device.isSmoothAutoFocusEnabled = device.isSmoothAutoFocusSupported
//        device.exposureMode = .continuousAutoExposure
        device.unlockForConfiguration()
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: device) else {
            session.commitConfiguration()
            return false
        }
        self.deviceInput = deviceInput
        
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        } else {
            session.commitConfiguration()
            return false
        }
        
        // 创建二维码扫描结果的元数据输出流
        let metadataOutput = AVCaptureMetadataOutput()
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        // 设置采集扫描区域
        metadataOutput.rectOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
        

        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
        } else {
            session.commitConfiguration()
            return false
        }
        
        metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .code128]

        // 创建环境光感输出流
        let videoDataOutput = AVCaptureVideoDataOutput()
//        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        
        session.sessionPreset = .high
        session.commitConfiguration()
        return true
    }
    
    func startRunning() {
        sessionQueue.async {
            self.session.startRunning()
        }
    }
    
    func stopRunning() {
        sessionQueue.async {
            self.session.stopRunning()
        }
    }
    
    // 手电筒开关
    func openTorch(_ isOpen: Bool) {
        let torchMode: AVCaptureDevice.TorchMode = isOpen ? .on : .off
        if deviceInput.device.hasTorch && deviceInput.device.isTorchModeSupported(torchMode) {
            try? deviceInput.device.lockForConfiguration()
            deviceInput.device.torchMode = torchMode
            deviceInput.device.unlockForConfiguration()
        }
    }
    
    var isOpenTorch: Bool {
        return deviceInput.device.isTorchActive
    }
}

// MARK: - 处理二维码扫描数据
extension QRCodeScanner: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let data = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let result = data.stringValue {
            scanResult?(.success(result))
        } else {
            scanResult?(.notFound)
        }
    }
    
    
    func scanImageQRCode(_ image: UIImage) {
        if #available(iOS 11.0, *) {
            detectQRCodeImageIOS11Version(image)
        } else {
            detectQRCodeImageIOS11BeforeVersion(image)
        }
    }
    
    private func detectQRCodeImageIOS11Version(_ image: UIImage) {
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        performVisionRequest(image: image.cgImage!, orientation: cgOrientation)
    }
    
    private func detectQRCodeImageIOS11BeforeVersion(_ image: UIImage) {
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: CIImage(cgImage: image.cgImage!))
        if let feature = features?.first as? CIQRCodeFeature, let result = feature.messageString {
            scanResult?(.success(result))
        } else {
            scanResult?(.notFound)
        }
    }
}

extension QRCodeScanner: AVCaptureVideoDataOutputSampleBufferDelegate {
    /// 扫描过程中判断环境的黑暗程度
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait
        // kCMAttachmentMode_ShouldPropagate 请勿传播此附件
        guard let metadataDict = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate) else {
            return
        }
        
        guard let metadataDict = metadataDict as? [String: Any] else {
            return
        }
        
        guard let exifMetadata = metadataDict[kCGImagePropertyExifDictionary as String] as? [String: Any] else {
            return
        }
        
        guard let brightnessValue = exifMetadata[kCGImagePropertyExifBrightnessValue as String] as? Double else {
            return
        }
        
        if brightnessValue < 0 && deviceInput.device.hasTorch {
            // 环境太暗，可以打开手电筒
        }
        UIScreen.main.brightness = 0.3
        monitorLight?(brightnessValue)
       
        
    }
    
    func snapImage(with sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        
       let scale = UIScreen.main.scale
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { return nil }
        guard let cgImage = context.makeImage() else { return nil }
        let image = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
       return image
    }
}

// MARK: - Vision Request
extension QRCodeScanner {
    
    private func performVisionRequest(image: CGImage, orientation: CGImagePropertyOrientation) {
        let requests = self.barcodeDetectionRequest
        let imageRequestHandler = VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform([requests])
            } catch {
                print("execute image request handler errror: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleDetectedBarcodes(request: VNRequest?, error: Error?) {
        if let error = error as NSError? {
            print("error: \(error.localizedDescription)")
            return
        }
        
        guard let results = request?.results as? [VNBarcodeObservation] else {
           return
        }
        
        for result in results where result.symbology == .qr {
            if let payloadString = result.payloadStringValue {
                scanResult?(.success(payloadString))
            } else {
                print("empty info.")
            }
            
//            if let barcodeDescriptor = result.barcodeDescriptor {
//                imageFromBarcode(descriptor: barcodeDescriptor)
//            }
        }
    }
    
    private func imageFromBarcode(descriptor: CIBarcodeDescriptor) {
        let inputParams = ["inputBarcodeDescriptor": descriptor]
        let barcodeCreationFilter = CIFilter(name: "CIBarcodeGenerator", parameters: inputParams)
        if let outputImage = barcodeCreationFilter?.outputImage {
//            let image = UIImage(ciImage: outputImage)
        }
    }
    
}

private extension CGImagePropertyOrientation {
    init(_ uiImageOrientation: UIImage.Orientation) {
        switch uiImageOrientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        default: self = .up
        }
    }
}
