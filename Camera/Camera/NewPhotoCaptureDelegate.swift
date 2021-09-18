//
//  NewPhotoCaptureDelegate.swift
//  NewPhotoCaptureDelegate
//
//  Created by 蔡志文 on 2021/9/10.
//

import UIKit
import Photos
import AVFoundation

class NewPhotoCaptureProcessor: NSObject {
    
    enum CaptureFailedType: Error {
        case captureFailed
        case saveToLibraryFailed
        case notPhotoLibraryAuth
    }
    
    private var photoData: Data?
    
    private(set) var requestedPhotoSettings: AVCapturePhotoSettings
    private let completionCapturePhotoHandler: (NewPhotoCaptureProcessor) -> Void
    private let delegate: PhotoCaptureProcessDelegate
    
    init(with requestedPhotoSettings: AVCapturePhotoSettings,
         delegate: PhotoCaptureProcessDelegate,
         completionCapturePhotoHandler: @escaping (NewPhotoCaptureProcessor) -> Void) {
        self.requestedPhotoSettings = requestedPhotoSettings
        self.delegate = delegate
        self.completionCapturePhotoHandler = completionCapturePhotoHandler
    }
    
    private func finishCapturePhoto() {
        completionCapturePhotoHandler(self)
    }
    
}

extension NewPhotoCaptureProcessor: AVCapturePhotoCaptureDelegate {

    /// 通知委托捕获输出已解析设置并将很快开始其捕获过程。
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        delegate.photoCaptureWillBeginCapture()
    }
    
    /// 通知代表即将进行照片捕获。
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        delegate.photoCaptureWillCapturePhoto()
    }
    
    /// - Tag: DidFinishProcessingPhoto
    /// 完成处理照片的过程，向委托提供捕获的图像和由照片捕获产生所关联的元数据。
    /// 在这个方法中我们可以获取捕获图片相关的元数据进行进一步的加工处理图片
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        photoProcessingHandler(false)
        print(#function)

        if let error = error {
            print("Error capturing photo: \(error)")
            return
        } else {
            photoData = photo.fileDataRepresentation()
        }
    }
    
    /// - Tag: DidFinishRecordingLive
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishRecordingLivePhotoMovieForEventualFileAt outputFileURL: URL, resolvedSettings: AVCaptureResolvedPhotoSettings) {
//        livePhotoCaptureHandler(false)
        print(#function)
    }
    
    /// - Tag: DidFinishProcessingLive
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL, duration: CMTime, photoDisplayTime: CMTime, resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
//        if error != nil {
//            print("Error processing Live Photo companion movie: \(String(describing: error))")
//            return
//        }
//        livePhotoCompanionMovieURL = outputFileURL
        print(#function)
    }
    
    /// 最后一步，照片捕获完成
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        print(#function)
        if let _ = error {
            delegate.photoCaptureError(CaptureFailedType.captureFailed)
            finishCapturePhoto()
            return
        }

        
        guard let photoData = photoData else {
            delegate.photoCaptureError(CaptureFailedType.captureFailed)
            finishCapturePhoto()
            return
        }
        
        writePhotoDataToPhotoLibrary(photoData)
    }
}

extension NewPhotoCaptureProcessor {
    func writePhotoDataToPhotoLibrary(_ data: Data) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges {
                    // 一组影响从基础资源创建新照片资产的选项。
                    let options = PHAssetResourceCreationOptions()
                    // 用于从基础底层数据资源创建一个新的照片资产的请求
                    // `PHAssetCreationRequest` 还可以为图片添加收藏、喜欢、拍摄地点等信息
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    // 资源的统一类型标识符。
                    options.uniformTypeIdentifier = self.requestedPhotoSettings.processedFileType.map { $0.rawValue }
                    creationRequest.addResource(with: .photo, data: data, options: options)
                } completionHandler: { _, error in
                    if let _ = error {
                        self.delegate.photoCaptureError(CaptureFailedType.saveToLibraryFailed)
                    } else {
                        self.delegate.photoCaptureDidFinishCapture(data)
                    }
                }

            } else {
                // 无权限，放弃保存
                self.delegate.photoCaptureError(CaptureFailedType.notPhotoLibraryAuth)
                self.finishCapturePhoto()
            }
        }
    }
}
