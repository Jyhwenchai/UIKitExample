//
//  CameraOld.swift
//  CameraOld
//
//  Created by 蔡志文 on 2021/9/8.
//

import UIKit
import AVFoundation
import AssetsLibrary

class CameraOld: NSObject {
    
    enum CaptureMode: Int {
        case photo = 0
        case video = 1
    }
    
    enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed(String)
    }
    
    weak var delegate: CameraOldDelegate?
    /// 捕获图片代理对象
    private var inProgressPhotoCaptureDelegates = [Int64: NewPhotoCaptureProcessor]()
    private var videoCaptureProcessor: VideoCaptureProcessor!
    
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "session.queue")
    
    // video input
    var videoDeviceInput: AVCaptureDeviceInput!
    
    // Photo output
    let photoOutput = AVCapturePhotoOutput()
    let movieOutput = AVCaptureMovieFileOutput()
    
    var captureMode: CaptureMode = .photo
    var flashMode: AVCaptureDevice.FlashMode = .auto
    
    var setupResult: SessionSetupResult = .success
    
    // MARK: - Session configure
    func setupSession() -> Bool {
        return configureSession()
    }
    
    
    /// 初始化 session 的配置。包括添加输入输出设备
    private func configureSession() -> Bool {
        session.beginConfiguration()
        
        // 设置会话输出质量预设，可在 `AVCaptureSession.Preset` 中查看所有类型
        session.sessionPreset = .photo  // 默认的这里使用 photo 类型
        
        // 添加输入设备
        // 包括视频输入和音频输入
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            setupResult = .configurationFailed("Could not fetch a video device.")
            return false
        }
        
        // 添加视频设备
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            setupResult = .configurationFailed("Could not create video device input.")
            return false
        }
        

        if session.canAddInput(videoDeviceInput) {
            session.addInput(videoDeviceInput)
            self.videoDeviceInput = videoDeviceInput
        } else {
            setupResult = .configurationFailed("Could not add video device input.")
            return false
        }
        
        // 添加音频设备
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
            setupResult = .configurationFailed("Could not fetch a audio device.")
            return false
        }
        
        guard let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice) else {
            setupResult = .configurationFailed("Could not create audio device input.")
            return false
        }
        
        if session.canAddInput(audioDeviceInput) {
            session.addInput(audioDeviceInput)
        } else {
            setupResult = .configurationFailed("Could not add audio device input.")
            return false
        }
        
        // 添加输出配置
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        }
        
        session.commitConfiguration()
        
        return true

    }
    
    /// 开始启动会话捕获数据
    func startSession() {
        if !session.isRunning {
            sessionQueue.async {
                self.session.startRunning()
            }
        }
    }
    
    /// 停止会话捕捉数据
    func stopSession() {
        if session.isRunning {
            sessionQueue.async {
                self.session.stopRunning()
            }
        }
    }
    
}

// MARK: - 切换前后置摄像头
extension CameraOld {
    
    /// 当前使用的摄像头设备
    private var activeCamera: AVCaptureDevice {
        self.videoDeviceInput.device
    }
    
    /// builtInMicrophone    内置麦克风。iOS 10.0
    /// builtInWideAngleCamera    内置广角相机。 iOS 10.0
    /// builtInTelephotoCamera    内置摄像头设备的焦距比广角摄像头更长。iOS 10.0
    /// builtInUltraWideCamera    内置相机的焦距比广角相机的焦距短。iOS 13.0
    /// builtInDualCamera    广角相机和远摄相机的组合 iOS 10.2
    /// builtInDualWideCamera    一种设备，包括两个固定焦距的相机，一个超广角和一个广角 iOS 13.0
    /// builtInTripleCamera    一种设备，该设备由三个固定焦距的相机，一个超广角，一个广角和一个长焦相机组成。 iOS 13.0
    /// builtInTrueDepthCamera    相机和其他传感器的组合，可创建能够进行照片，视频和深度捕捉的捕捉设备。iOS 11.1
    /// builtInDuoCamera    iOS 10.2 之后不推荐使用。#available(iOS 10.0, iOS)

    /// 切换摄像头
    func switchCamera() -> Bool {
        
        let currentVideoDevice = activeCamera
        // 获取当前设备的方向（处于前置摄像头还是后置摄像头）
        let currentPosition = currentVideoDevice.position
        
        let frontVideoDeviceDiscoverySession: AVCaptureDevice.DiscoverySession
        let backVideoDeviceDiscoverySession: AVCaptureDevice.DiscoverySession
        
        if #available(iOS 10.2, *) {
            if #available(iOS 13, *) {
                backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInDualWideCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
            } else {
                backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
            }
            
        } else {
            backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDuoCamera], mediaType: .video, position: .back)
        }
        
        if #available(iOS 11.1, *) {
            frontVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera], mediaType: .video, position: .front)
        } else {
            frontVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        }
        
        var newVideoDevice: AVCaptureDevice? = nil
        
        switch currentPosition {
        case .unspecified, .front:
            newVideoDevice = backVideoDeviceDiscoverySession.devices.first
        case .back:
            newVideoDevice = frontVideoDeviceDiscoverySession.devices.first
        default:
            print("Unknown capture position. Defaulting to back, dual-camera.")
            newVideoDevice = backVideoDeviceDiscoverySession.devices.first
        }
        
        
        if let videoDevice = newVideoDevice {
            do {
                
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                
                self.session.beginConfiguration()
                
                // 首先删除现有的设备输入，因为 AVCaptureSession 不支持同时使用后置和前置摄像头。
                self.session.removeInput(self.videoDeviceInput)
                
                if self.session.canAddInput(videoDeviceInput) {
//                    // 重置对捕捉范围的监听
//                    NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
//                    NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
//
                    self.session.addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                } else {
                    self.session.addInput(self.videoDeviceInput)
                }
    
                self.session.commitConfiguration()
                
                return true
            } catch {
                print("Error occurred while creating video device input: \(error)")
                return false
            }
        }
        
        
        return false
    }
    
}

// MARK: - 聚焦和曝光功能
extension CameraOld {
    
    /// 是否支持对焦功能
    var isSupportFocus: Bool {
        activeCamera.isFocusPointOfInterestSupported
    }
    
    /// 聚焦功能
    /// - Parameter point: 对焦兴趣点
    func focus(at point: CGPoint) {
        // 检查是否支持对焦及自动对焦
        if activeCamera.isFocusPointOfInterestSupported,
           activeCamera.isFocusModeSupported(.autoFocus) {
            
            do {
                try activeCamera.lockForConfiguration()
                // 设置对焦兴趣点
                activeCamera.focusPointOfInterest = point
                // 设置对焦模式为自动对焦
                activeCamera.focusMode = .autoFocus
                
                activeCamera.unlockForConfiguration()
            } catch {
                // TODO: error handle
            }
        }
    }
    
    /// 曝光功能
    /// - Parameter point: 曝光兴趣点
    func exposure(at point: CGPoint) {
        // 检查是否支持曝光及自动曝光
        if activeCamera.isExposurePointOfInterestSupported,
           activeCamera.isExposureModeSupported(.autoExpose) {
            do {
                try activeCamera.lockForConfiguration()
                // 设置曝光兴趣点
                activeCamera.exposurePointOfInterest = point
                // 设置曝光模式为自动曝光
                activeCamera.exposureMode = .autoExpose
                
                activeCamera.unlockForConfiguration()
                
            } catch  {
                // TODO: error handle
            }
        }
    }
    
}

// MARK: - 闪光灯和手电筒
extension CameraOld {
    
    /// 指示捕获设备是否有闪光灯。
    var hasFlash: Bool {
        activeCamera.hasFlash
    }
    /// 设置上闪光灯模式
    func configureFlashMode(_ mode: AVCaptureDevice.FlashMode) {
       flashMode = mode
    }
    
    /// 指示不过设备是否有手电筒
    var hasTorch: Bool {
        activeCamera.hasTorch
    }
    
    /// 当前设备的手电筒模式
    var torchMode: AVCaptureDevice.TorchMode {
        activeCamera.torchMode
    }
    
    
    /// 设置手电筒模式
    func configureTorchMode(_ mode: AVCaptureDevice.TorchMode) {
        if activeCamera.isTorchModeSupported(mode) {
            do {
                try activeCamera.lockForConfiguration()
                activeCamera.torchMode = mode
                activeCamera.unlockForConfiguration()
            } catch {
                // error handle
            }
        }
    }
    
    func resetFocusAndExposure() {
        let canSetFocus =  activeCamera.isFocusPointOfInterestSupported && activeCamera.isFocusModeSupported(.autoFocus)
        let canSetExposure = activeCamera.isExposurePointOfInterestSupported && activeCamera.isExposureModeSupported(.autoExpose)
        
        let point = CGPoint(x: 0.5, y: 0.5)
        
        do {
            try activeCamera.lockForConfiguration()
            if canSetFocus {
                activeCamera.focusMode = .autoFocus
                activeCamera.focusPointOfInterest = point
            }
            
            if canSetExposure {
                activeCamera.exposureMode = .autoExpose
                activeCamera.exposurePointOfInterest = point
            }
            
            activeCamera.unlockForConfiguration()
        } catch {
           // error handle
        }
    }
}

// MARK: - 捕获输出静态图片
extension CameraOld {
    
    func capturePhoto(with delegate: PhotoCaptureProcessDelegate, orientation: AVCaptureVideoOrientation) {
        let connection = photoOutput.connection(with: .video)!
        // 程序只支持纵向，但是如果用户横向拍照时，需要调整结果照片的方向
        // 判断是否支持设置视频方向
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = orientation
        }
        
        let photoSettings = AVCapturePhotoSettings()
        if activeCamera.isFlashAvailable {
            photoSettings.flashMode = flashMode
        }
        let photoCaptureDelegate = NewPhotoCaptureProcessor(with: photoSettings, delegate: delegate) { processor in
            // 完成捕获照片后要移除捕获代理对象
            self.inProgressPhotoCaptureDelegates[processor.requestedPhotoSettings.uniqueID] = nil
        }
        inProgressPhotoCaptureDelegates[photoSettings.uniqueID] = photoCaptureDelegate
        photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureDelegate)
        
    }
}


// MARK: - 捕获视频
extension CameraOld {
   
    var isRecording: Bool {
        movieOutput.isRecording
    }
    
    
    func startRecording(with delegate: VideoRecordingProcessDelegate, orientation: AVCaptureVideoOrientation) {
        
        if isRecording {
            return
        }
        
        guard let connection = movieOutput.connection(with: .video) else { return }
        
        // 检查并修改当前视频方向
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = orientation
        }
        
        // 设置视频稳定模式如果支持的话
        if connection.isVideoStabilizationSupported {
            connection.preferredVideoStabilizationMode = .auto
        }
        
        // 摄像头可以进行平滑对焦模式操作。即减慢摄像头镜头对焦速度。当用户移动拍摄时摄像头会尝试快速自动对焦。
        if activeCamera.isSmoothAutoFocusEnabled {
            do {
                try activeCamera.lockForConfiguration()
                activeCamera.isSmoothAutoFocusEnabled = true
                activeCamera.unlockForConfiguration()
            } catch  {
                // 放弃设置平滑对焦
            }
        }

        videoCaptureProcessor = VideoCaptureProcessor(delegate: delegate)
        movieOutput.startRecording(to: videoOutputFilePath(), recordingDelegate: videoCaptureProcessor)
    }
    
    func stopRecording() {
        if isRecording {
            movieOutput.stopRecording()
        }
    }
    
    private func videoOutputFilePath() -> URL {
        let fileName = UUID().uuidString
        let filePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((fileName as NSString).appendingPathExtension("mov")!)
        return URL(fileURLWithPath: filePath)
    }
}

