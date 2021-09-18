//
//  Camera.swift
//  Camera
//
//  Created by 蔡志文 on 2021/9/3.
//

import UIKit
import AVFoundation
import CoreLocation
import Photos

class Camera: NSObject {
    
    var delegate: CameraDelegate?
    private var keyValueObservations = [NSKeyValueObservation]()
    
    enum CaptureMode: Int {
        case photo = 0
        case movie = 1
    }

    // MARK: - 权限检查
    /// 检查视频授权状态。需要视频访问和音频访问是可选的。如果用户拒绝音频访问，AVCam 将不会在电影录制期间录制音频。
    func checkVideoAuthorization(_ completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: completion)
        default:
            completion(false)
        }
    }
    

    // MARK: - Section Configure
    let session = AVCaptureSession()
    private var isSessionRunning = false
    private let sessionQueue = DispatchQueue(label: "section queue")
    @objc dynamic private var videoDeviceInput: AVCaptureDeviceInput!
    /// 一种定义可以与主图像一起捕获的分割遮罩图像类型的结构。
    private var selectedSemanticSegmentationMatteTypes = [AVSemanticSegmentationMatte.MatteType]()
    
    /// configure session, addInput device、output device
    func configureSession() {
        
        sessionQueue.async { [unowned self] in
            _configureSession()
        }
    }
    
    private func _configureSession() {
        // 在配置会话的开始前必须执行此方法
        session.beginConfiguration()
        
        // 设置会话输出质量类型，可在 `AVCaptureSession.Preset` 中查看所有类型
        session.sessionPreset = .photo
        
        // 添加视频输入设备
        do {
            // 选择默认的摄像头
            var defaultVideoDevice: AVCaptureDevice?
            
            /// ```class func `default`(_ deviceType: AVCaptureDevice.DeviceType,
            ///              for mediaType: AVMediaType?,
            ///              position: AVCaptureDevice.Position) -> AVCaptureDevice?`
            /// ```
            /// 此方法在 iOS10+ 上有效，`AVMediaType` 在 iOS11+ 上有效, 下面的 `DeviceType` 在 iOS13+ 有效
            ///
            
            if #available(iOS 13, *) {
                
                if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                    defaultVideoDevice = dualCameraDevice
                } else if let dualWideCameraDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
                    // If a rear dual camera is not available, default to the rear dual wide camera.
                    defaultVideoDevice = dualWideCameraDevice
                } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                    // If a rear dual wide camera is not available, default to the rear wide angle camera.
                    defaultVideoDevice = backCameraDevice
                } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                    // If the rear wide angle camera isn't available, default to the front wide angle camera.
                    defaultVideoDevice = frontCameraDevice
                }
                
            } else {
                // iOS11+ 有效，返回的捕获设备类型为 `builtInWideAngleCamera`
                defaultVideoDevice = AVCaptureDevice.default(for: .video)
            }
            
            guard let videoDevice = defaultVideoDevice else {
                print("Default video device is unavailable.")
                session.commitConfiguration()
                return
            }
            
            // 添加输入设备
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            // 检查是否可以添加选择的输入设备, 如果可以才添加
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                //TODO: ??Config previewView
                DispatchQueue.main.async { [self] in
                    delegate?.didAddVideoInputDevice()
                }
            }
        } catch {
            print("Default video device is unavailable.")
            session.commitConfiguration()
            return
        }
        
        // 添加音频摄入设备
        do {
            guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
                print("Could not create audio device input")
                return
            }
            
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            } else {
                print("Count not add audio device input to the session.")
            }
        } catch {
            print("Could not create audio device input: \(error)")
        }
    
        
        // 添加输出设备
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            
            // 指定是否为高分辨率静态图像捕获配置捕获管道
            photoOutput.isHighResolutionCaptureEnabled = true
            // 是否开启实况照片捕获
           // photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
            // 是否为深度数据捕获配置捕获管道, 这里 essionPreset 必须是为支持深度的格式
            // photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
            // iOS 12+, 指示捕获输出是否生成人像效果遮罩
            // photoOutput.isPortraitEffectsMatteDeliveryEnabled = photoOutput.isPortraitEffectsMatteDeliverySupported
            // 遮罩类型
//            selectedSemanticSegmentationMatteTypes = photoOutput.availableSemanticSegmentationMatteTypes
            // iOS13+, 设置照片输出的最高质量
            photoOutput.maxPhotoQualityPrioritization = .quality
            // 是否开启实况照片
//            livePhotoMode = photoOutput.isLivePhotoCaptureSupported ? .on : .off
//            depthDataDeliveryMode = photoOutput.isDepthDataDeliverySupported ? .on : .off
//            portraitEffectsMatteDeliveryMode = photoOutput.isPortraitEffectsMatteDeliverySupported ? .on : .off
            // 指示如何相对于捕获速度优先考虑照片质量的常量。
//            photoQualityPrioritizationMode = .balanced
        } else {
            print("Could not add photo output to the session")
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    func startSession() {
        sessionQueue.async { [unowned self] in
            self.addObservers()
            self.session.startRunning()
            self.isSessionRunning = self.session.isRunning
        }
    }
    
    func stopSession() {
        DispatchQueue.main.async {
            self.session.stopRunning()
            self.isSessionRunning = self.session.isRunning
            self.removeObservers()
        }
    }
    
    /// 恢复中断的会话
    func resumeInterruptedSession() {
        sessionQueue.async {
            self.session.startRunning()
            self.isSessionRunning = self.session.isRunning
            //TODO: ??Need call delegate to update UI
            if self.session.isRunning {
            
            } else {
                
            }
        }
    }
    
    /// 切换捕获模式
    ///
    /// 切换捕获模式需重新设置对应模式的输入输出的配置
    func switchCaptureMode(_ mode: CaptureMode) {
        selectedMovieMode10BitDeviceFormat = nil
        
        switch mode {
        case .photo:
            sessionQueue.async {
                
                self.session.beginConfiguration()
                if let movieFileOutput = self.movieFileOutput {
                    self.session.removeOutput(movieFileOutput)
                    self.movieFileOutput = nil
                }
                self.session.sessionPreset = .photo
                
                // 如果支持实况照片就启用此功能
                if self.photoOutput.isLivePhotoCaptureSupported {
                    self.photoOutput.isLivePhotoCaptureEnabled = true
                }
                
                // 如果支持深度数据就启用此功能
                if self.photoOutput.isDepthDataDeliverySupported {
                    self.photoOutput.isDepthDataDeliveryEnabled = true
                }
                
                // 如果支持人像遮罩就启用此功能
                if self.photoOutput.isPortraitEffectsMatteDeliverySupported {
                    self.photoOutput.isPortraitEffectsMatteDeliveryEnabled = true
                }
                
                if !self.photoOutput.availableSemanticSegmentationMatteTypes.isEmpty {
                    self.photoOutput.enabledSemanticSegmentationMatteTypes = self.photoOutput.availableSemanticSegmentationMatteTypes
                    self.selectedSemanticSegmentationMatteTypes = self.photoOutput.availableSemanticSegmentationMatteTypes
                    
                    //                DispatchQueue.main.async {
                    //                    self.semanticSegmentationMatteDeliveryButton.isEnabled = (self.depthDataDeliveryMode == .on) ? true : false
                    //                }
                }
                self.session.commitConfiguration()
                
            }
        case .movie:
            sessionQueue.async {
                let movieFileOutput = AVCaptureMovieFileOutput()
                
                if self.session.canAddOutput(movieFileOutput) {
                    self.session.beginConfiguration()
                    self.session.addOutput(movieFileOutput)
                    self.session.sessionPreset = .high
                    
                    self.selectedMovieMode10BitDeviceFormat = self.tenBitVariantOfFormat(activeFormat: self.videoDeviceInput.device.activeFormat)
                    
                    if self.selectedMovieMode10BitDeviceFormat != nil {
                        // 应用HDR模式录制视频
                        if self.HDRVideoMode == .on {
                            do {
                                try self.videoDeviceInput.device.lockForConfiguration()
                                self.videoDeviceInput.device.activeFormat = self.selectedMovieMode10BitDeviceFormat!
                                print("Setting 'x420' format \(String(describing: self.selectedMovieMode10BitDeviceFormat)) for video recording")
                                self.videoDeviceInput.device.unlockForConfiguration()
                            } catch {
                                print("Could not lock device for configuration: \(error)")
                            }
                        }
                    }
                    
                    // 设置最适合与连接一起使用的稳定模式。
                    if let connection = movieFileOutput.connection(with: .video), connection.isVideoStabilizationSupported {
                        connection.preferredVideoStabilizationMode = .auto
                    }
                    
                    self.session.commitConfiguration()
                    
                    self.movieFileOutput = movieFileOutput
                }
            }
        }
   
    }
    
    /// 切换前后置摄像头
    func toggleCamera() {
        // 切换摄像头要重新设置媒体格式和捕获设置
        self.selectedMovieMode10BitDeviceFormat = nil
        
        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            // 获取当前设备的方向（处于前置摄像头还是后置摄像头）
            let currentPosition = currentVideoDevice.position
            
            let backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInDualWideCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
            
            let frontVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera], mediaType: .video, position: .front)
            
            var newVideoDevice: AVCaptureDevice? = nil
            
            switch currentPosition {
            case .unspecified, .front:
                newVideoDevice = frontVideoDeviceDiscoverySession.devices.first
            case .back:
                newVideoDevice = backVideoDeviceDiscoverySession.devices.first
            default:
                print("Unknown capture position. Defaulting to back, dual-camera.")
                newVideoDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
            }
            
            if let videoDevice = newVideoDevice {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    
                    self.session.beginConfiguration()
                    
                    // 首先删除现有的设备输入，因为 AVCaptureSession 不支持同时使用后置和前置摄像头。
                    self.session.removeInput(self.videoDeviceInput)
                    
                    if self.session.canAddInput(videoDeviceInput) {
                        // 重置对捕捉范围的监听
                        NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
                        NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
                        
                        self.session.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        self.session.addInput(self.videoDeviceInput)
                    }
                    
                    // 获取具有指定媒体类型的输入端口的连接数组中的第一个连接。
                    if let connection = self.movieFileOutput?.connection(with: .video) {
                        self.session.sessionPreset = .high
                        
                        self.selectedMovieMode10BitDeviceFormat = self.tenBitVariantOfFormat(activeFormat: self.videoDeviceInput.device.activeFormat)
                        
                        if self.selectedMovieMode10BitDeviceFormat != nil {
                            
                            if self.HDRVideoMode == .on {
                                do {
                                    try self.videoDeviceInput.device.lockForConfiguration()
                                    self.videoDeviceInput.device.activeFormat = self.selectedMovieMode10BitDeviceFormat!
                                    print("Setting 'x420' format \(String(describing: self.selectedMovieMode10BitDeviceFormat)) for video recording")
                                    self.videoDeviceInput.device.unlockForConfiguration()
                                } catch {
                                    print("Could not lock device for configuration: \(error)")
                                }
                            }
                        }
                        
                        if connection.isVideoStabilizationSupported {
                            connection.preferredVideoStabilizationMode = .auto
                        }
                    }
                    
                    /**
                     如果支持实况照片的捕获，那么设置实时照片捕获和深度数据传输。更换相机时，当视频设备与会话断开连接时，AVCapturePhotoOutput 的 `livePhotoCaptureEnabled` 和 `depthDataDeliveryEnabled` 属性设置为 false。新的视频设备后添加到会话中，如果要重新支持那么要在 AVCapturePhotoOutput 上重新启用它们。
                     */
                    self.photoOutput.isLivePhotoCaptureEnabled = self.photoOutput.isLivePhotoCaptureSupported
                    /// 以下配置需 iOS11+ 的高版本支持
                    self.photoOutput.isDepthDataDeliveryEnabled = self.photoOutput.isDepthDataDeliverySupported
                    self.photoOutput.isPortraitEffectsMatteDeliveryEnabled = self.photoOutput.isPortraitEffectsMatteDeliverySupported
                    self.photoOutput.enabledSemanticSegmentationMatteTypes = self.photoOutput.availableSemanticSegmentationMatteTypes
                    self.selectedSemanticSegmentationMatteTypes = self.photoOutput.availableSemanticSegmentationMatteTypes
                    self.photoOutput.maxPhotoQualityPrioritization = .quality
                    
                    self.session.commitConfiguration()
                } catch {
                    print("Error occurred while creating video device input: \(error)")
                }
            }
        }
    }
    
    
    //MARK: - Capturing Photos
    private let photoOutput = AVCapturePhotoOutput()
    private var selectedMovieMode10BitDeviceFormat: AVCaptureDevice.Format?
    
    /// 实况照片模式
    private enum LivePhotoMode {
        case on
        case off
    }
    
    /// 深度数据传递模式
    private enum DepthDataDeliveryMode {
        case on
        case off
    }
    
    /// 是否捕获人像遮罩
    private enum PortraitEffectsMatteDeliveryMode {
        case on
        case off
    }
    
    private var livePhotoMode: LivePhotoMode = .off
    private var depthDataDeliveryMode: DepthDataDeliveryMode = .off
    private var portraitEffectsMatteDeliveryMode: PortraitEffectsMatteDeliveryMode = .off
    private var photoQualityPrioritizationMode: AVCapturePhotoOutput.QualityPrioritization = .balanced
   
    /// 统计实况照片数量
    private var inProgressLivePhotoCapturesCount = 0
    
    /// 捕获图片代理对象
    private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
    
    /// 捕获照片
    /// - Parameter videoPreviewLayerOrientation: 当前视频的方向
    func capturePhoto(with videoPreviewLayerOrientation: AVCaptureVideoOrientation) {
        sessionQueue.async {
            if let photoOutConnection = self.photoOutput.connection(with: .video) {
                photoOutConnection.videoOrientation = videoPreviewLayerOrientation
            }
            
            // 为捕获配置的 AVCapturePhotoSettings 对象不能重用
            var photoSettings = AVCapturePhotoSettings()
            
            // 在支持捕获 HEIF 照片时。启用自动闪光和高分辨率照片。
            if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }
            
            // 指示当前是否可以使用闪光灯。
            if self.videoDeviceInput.device.isFlashAvailable {
                photoSettings.flashMode = .auto
            }
            
            // 指定是否支持最高分辨率捕获静止图像。
            photoSettings.isHighResolutionPhotoEnabled = true
            if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }
            
            // 实况照片的输出配置
            if self.livePhotoMode == .on && self.photoOutput.isLivePhotoCaptureSupported {
                let livePhotoMovieFileName = UUID().uuidString
                let livePhotoMovieFilePath = (NSTemporaryDirectory() as NSString)
                    .appendingPathComponent((livePhotoMovieFileName as NSString).appendingPathExtension("mov")!)
                photoSettings.livePhotoMovieFileURL = URL(fileURLWithPath: livePhotoMovieFilePath)
            }
            
            // 是否启用深度数据传递 iOS11+
            photoSettings.isDepthDataDeliveryEnabled = (self.depthDataDeliveryMode == .on
                && self.photoOutput.isDepthDataDeliveryEnabled)
            
            // 指定是否应与照片一起捕获人像效果遮罩。iOS12+
            photoSettings.isPortraitEffectsMatteDeliveryEnabled = (self.portraitEffectsMatteDeliveryMode == .on
                && self.photoOutput.isPortraitEffectsMatteDeliveryEnabled)
            
            if photoSettings.isDepthDataDeliveryEnabled {
                if !self.photoOutput.availableSemanticSegmentationMatteTypes.isEmpty {
                    photoSettings.enabledSemanticSegmentationMatteTypes = self.selectedSemanticSegmentationMatteTypes
                }
            }
            
            // 指示如何根据照片传送速度优先考虑照片质量的设置。iOS13+
            photoSettings.photoQualityPrioritization = self.photoQualityPrioritizationMode
            
            let photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings) {
                // 闪烁屏幕以表示 AVCam 拍摄了照片。
//                DispatchQueue.main.async {
//                    self.previewView.videoPreviewLayer.opacity = 0
//                    UIView.animate(withDuration: 0.25) {
//                        self.previewView.videoPreviewLayer.opacity = 1
//                    }
//                }
            } livePhotoCaptureHandler: { capturing in
                // 实况照片数量的统计
                self.sessionQueue.async {
                    if capturing {
                        self.inProgressLivePhotoCapturesCount += 1
                    } else {
                        self.inProgressLivePhotoCapturesCount -= 1
                    }
                    
                    let inProgressLivePhotoCapturesCount = self.inProgressLivePhotoCapturesCount
                    DispatchQueue.main.async {
//                        if inProgressLivePhotoCapturesCount > 0 {
//                            self.capturingLivePhotoLabel.isHidden = false
//                        } else if inProgressLivePhotoCapturesCount == 0 {
//                            self.capturingLivePhotoLabel.isHidden = true
//                        } else {
//                            print("Error: In progress Live Photo capture count is less than 0.")
//                        }
                    }
                }
            } completionHandler: { photoCaptureProcessor in
                self.sessionQueue.async {
                    // 捕获完成移除持有配置对象
                    self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = nil
                }
            } photoProcessingHandler: { animate in
                // 到此照片捕获完成
                // 如果捕获的是实况照片，那么如果实况照片超过1秒的长度时进行一些加载动画
                // 如果捕获的是普通照片，那么直接完成
            }

            self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
            // 捕获照片
            self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
        }
    }
    
    
    // MARK: Recording Movies
    private var movieFileOutput: AVCaptureMovieFileOutput?
    
    private var backgroundRecordingID: UIBackgroundTaskIdentifier?
    
    private enum HDRVideoMode {
        case on
        case off
    }
    

    private var HDRVideoMode: HDRVideoMode = .on
    
   
    /// 获取捕获的视频格式
    func tenBitVariantOfFormat(activeFormat: AVCaptureDevice.Format) -> AVCaptureDevice.Format? {
        let formats = self.videoDeviceInput.device.formats
        let formatIndex = formats.firstIndex(of: activeFormat)!
        
        let activeDimensions = CMVideoFormatDescriptionGetDimensions(activeFormat.formatDescription)
        let activeMaxFrameRate = activeFormat.videoSupportedFrameRateRanges.last?.maxFrameRate
        let activePixelFormat = CMFormatDescriptionGetMediaSubType(activeFormat.formatDescription)
        
        /*
         AVCaptureDeviceFormats are sorted from smallest to largest in resolution and frame rate.
         For each resolution and max frame rate there's a cluster of formats that only differ in pixelFormatType.
         Here, we're looking for an 'x420' variant of the current activeFormat.
        */
        if activePixelFormat != kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange {
            // Current activeFormat is not a 10-bit HDR format, find its 10-bit HDR variant.
            for index in formatIndex + 1..<formats.count {
                let format = formats[index]
                let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
                let maxFrameRate = format.videoSupportedFrameRateRanges.last?.maxFrameRate
                let pixelFormat = CMFormatDescriptionGetMediaSubType(format.formatDescription)
                
                // Don't advance beyond the current format cluster
                if activeMaxFrameRate != maxFrameRate || activeDimensions.width != dimensions.width || activeDimensions.height != dimensions.height {
                    break
                }
                
                if pixelFormat == kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange {
                    return format
                }
            }
        } else {
            return activeFormat
        }
        
        return nil
    }

    
    
}



// MARK: - 其它配置（焦点、曝光等）
extension Camera {
    
    func focus(with focusMode: AVCaptureDevice.FocusMode,
               exposureMode: AVCaptureDevice.ExposureMode,
               at devicePoint: CGPoint,
               monitorSubjectAreaChange: Bool) {
        sessionQueue.async {
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()
                
                // 设置对焦
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }
                
                // 是否启用对主题区域改变的监听（例如当对焦、曝光、白平衡改变时会发出 `AVCaptureDeviceSubjectAreaDidChange` 通知）
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                
                device.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
    
    
    
}

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
    
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}

extension AVCaptureDevice.DiscoverySession {
    var uniqueDevicePositionsCount: Int {
        
        var uniqueDevicePositions = [AVCaptureDevice.Position]()
        
        for device in devices where !uniqueDevicePositions.contains(device.position) {
            uniqueDevicePositions.append(device.position)
        }
        
        return uniqueDevicePositions.count
    }
}

// MARK: - Observers
extension Camera {
    func addObservers() {
        
        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            let isLivePhotoCaptureEnabled = self.photoOutput.isLivePhotoCaptureEnabled
            let isDepthDeliveryDataEnabled = self.photoOutput.isDepthDataDeliveryEnabled
            let isPortraitEffectsMatteEnabled = self.photoOutput.isPortraitEffectsMatteDeliveryEnabled
            let isSemanticSegmentationMatteEnabled = !self.photoOutput.enabledSemanticSegmentationMatteTypes.isEmpty
            
//            DispatchQueue.main.async {
//                // Only enable the ability to change camera if the device has more than one camera.
//                self.cameraButton.isEnabled = isSessionRunning && self.videoDeviceDiscoverySession.uniqueDevicePositionsCount > 1
//                self.recordButton.isEnabled = isSessionRunning && self.movieFileOutput != nil
//                self.photoButton.isEnabled = isSessionRunning
//                self.captureModeControl.isEnabled = isSessionRunning
//                self.livePhotoModeButton.isEnabled = isSessionRunning && isLivePhotoCaptureEnabled
//                self.depthDataDeliveryButton.isEnabled = isSessionRunning && isDepthDeliveryDataEnabled
//                self.portraitEffectsMatteDeliveryButton.isEnabled = isSessionRunning && isPortraitEffectsMatteEnabled
//                self.semanticSegmentationMatteDeliveryButton.isEnabled = isSessionRunning && isSemanticSegmentationMatteEnabled
//                self.photoQualityPrioritizationSegControl.isEnabled = isSessionRunning
//            }
        }
        keyValueObservations.append(keyValueObservation)
        // iOS11.1+ support
        // 监听影响捕获系统性能和可用性的当前操作系统和硬件状态。
        let systemPressureStateObservation = observe(\.videoDeviceInput.device.systemPressureState, options: .new) { _, change in
            guard let systemPressureState = change.newValue else { return }
            self.setRecommendedFrameRateRangeForPressureState(systemPressureState: systemPressureState)
        }
        keyValueObservations.append(systemPressureStateObservation)
        
        // 监听设备捕获区域发生变化的通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subjectAreaDidChange),
                                               name: .AVCaptureDeviceSubjectAreaDidChange,
                                               object: videoDeviceInput.device)
        
        // 监听会话运行时错误通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: session)
        
        /*
         A session can only run when the app is full screen. It will be interrupted
         in a multi-app layout, introduced in iOS 9, see also the documentation of
         AVCaptureSessionInterruptionReason. Add observers to handle these session
         interruptions and show a preview is paused message. See the documentation
         of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
         */
        // 监听捕获会话中断通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionWasInterrupted),
                                               name: .AVCaptureSessionWasInterrupted,
                                               object: session)
        // 监听捕获会话的中断完成通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionInterruptionEnded),
                                               name: .AVCaptureSessionInterruptionEnded,
                                               object: session)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        
        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
    }
    
    @objc
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    
    /// - Tag: HandleRuntimeError
    @objc
    func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        
        print("Capture session runtime error: \(error)")
        // If media services were reset, and the last start succeeded, restart the session.
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                } else {
                    DispatchQueue.main.async {
//                        self.resumeButton.isHidden = false
                    }
                }
            }
        } else {
//            resumeButton.isHidden = false
        }
    }
    
    /// - Tag: HandleSystemPressure
    /// 处理系统压力
    private func setRecommendedFrameRateRangeForPressureState(systemPressureState: AVCaptureDevice.SystemPressureState) {
        /*
         The frame rates used here are only for demonstration purposes.
         Your frame rate throttling may be different depending on your app's camera configuration.
         */
        let pressureLevel = systemPressureState.level
        if pressureLevel == .serious || pressureLevel == .critical {
            if self.movieFileOutput == nil || self.movieFileOutput?.isRecording == false {
                do {
                    try self.videoDeviceInput.device.lockForConfiguration()
                    print("WARNING: Reached elevated system pressure level: \(pressureLevel). Throttling frame rate.")
                    self.videoDeviceInput.device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 20)
                    self.videoDeviceInput.device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 15)
                    self.videoDeviceInput.device.unlockForConfiguration()
                } catch {
                    print("Could not lock device for configuration: \(error)")
                }
            }
        } else if pressureLevel == .shutdown {
            print("Session stopped running due to shutdown system pressure level.")
        }
    }
    
    /// - Tag: HandleInterruption
    @objc
    func sessionWasInterrupted(notification: NSNotification) {
        /*
         In some scenarios you want to enable the user to resume the session.
         For example, if music playback is initiated from Control Center while
         using AVCam, then the user can let AVCam resume
         the session running, which will stop music playback. Note that stopping
         music playback in Control Center will not automatically resume the session.
         Also note that it's not always possible to resume, see `resumeInterruptedSession(_:)`.
         */
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
            let reasonIntegerValue = userInfoValue.integerValue,
            let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Capture session was interrupted with reason \(reason)")
            
            var showResumeButton = false
            if reason == .audioDeviceInUseByAnotherClient || reason == .videoDeviceInUseByAnotherClient {
                showResumeButton = true
            } else if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                // Fade-in a label to inform the user that the camera is unavailable.
//                cameraUnavailableLabel.alpha = 0
//                cameraUnavailableLabel.isHidden = false
//                UIView.animate(withDuration: 0.25) {
//                    self.cameraUnavailableLabel.alpha = 1
//                }
            } else if reason == .videoDeviceNotAvailableDueToSystemPressure {
                print("Session stopped running due to shutdown system pressure level.")
            }
            if showResumeButton {
                // Fade-in a button to enable the user to try to resume the session running.
//                resumeButton.alpha = 0
//                resumeButton.isHidden = false
//                UIView.animate(withDuration: 0.25) {
//                    self.resumeButton.alpha = 1
//                }
            }
        }
    }
    
    @objc
    func sessionInterruptionEnded(notification: NSNotification) {
        print("Capture session interruption ended")
        
//        if !resumeButton.isHidden {
//            UIView.animate(withDuration: 0.25,
//                           animations: {
//                            self.resumeButton.alpha = 0
//            }, completion: { _ in
//                self.resumeButton.isHidden = true
//            })
//        }
//        if !cameraUnavailableLabel.isHidden {
//            UIView.animate(withDuration: 0.25,
//                           animations: {
//                            self.cameraUnavailableLabel.alpha = 0
//            }, completion: { _ in
//                self.cameraUnavailableLabel.isHidden = true
//            }
//            )
//        }
    }
}
