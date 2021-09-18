//
//  VideoCaptureDelegate.swift
//  VideoCaptureDelegate
//
//  Created by 蔡志文 on 2021/9/10.
//

import UIKit
import Photos
import AVFoundation

class VideoCaptureProcessor: NSObject {
    
    enum RecordingFailedType: Error {
        case recordingFailed
        case saveToLibraryFailed
        case notPhotoLibraryAuth
    }
    
    private var backgroundRecordingID: UIBackgroundTaskIdentifier?
    private let delegate: VideoRecordingProcessDelegate
    init(delegate: VideoRecordingProcessDelegate) {
        backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        self.delegate = delegate
    }
}

extension VideoCaptureProcessor: AVCaptureFileOutputRecordingDelegate {
    
    /// 开始录制视频
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        delegate.videoRecordingDidStart()
    }
    
    /// 结束录制视频
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
       
        if let error = error {
            // error handle
            print("Movie file finishing error: \(String(describing: error))")
            let success = (((error as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue)!
            if !success {
                cleanup(outputFileURL.path)
            }
            delegate.videoRecordingError(RecordingFailedType.recordingFailed)
            return
        }
        
        writeVideoToPhotosLibrary(outputFileURL)
        
    }
    
    private func writeVideoToPhotosLibrary(_ url: URL) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges {
                    let options = PHAssetResourceCreationOptions()
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .video, fileURL: url, options: options)
                } completionHandler: { success, error in
                    if let _ = error {
                        self.delegate.videoRecordingError(RecordingFailedType.saveToLibraryFailed)
                        return
                    }
                    self.delegate.videoRecordingDidFinished(url)
                    self.generateThumbnail(for: url)
                }
            } else {
                self.cleanup(url.path)
                self.delegate.videoRecordingError(RecordingFailedType.notPhotoLibraryAuth)
            }
        }
    }
    
    private func generateThumbnail(for videoURL: URL) {
        DispatchQueue.global().async {
            
            defer { self.cleanup(videoURL.path) }
            
            let asset = AVAsset(url: videoURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)

            // 设置 maximumSize 宽为100，高为0 根据视频的宽高比来计算图片的高度
            imageGenerator.maximumSize = CGSize(width: 100, height: 0)

            // 捕捉视频缩略图会考虑视频的变化（如视频的方向变化），如果不设置，缩略图的方向可能出错
            imageGenerator.appliesPreferredTrackTransform = true

            var image: UIImage?
            do {
                let imageRef = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
                image = UIImage(cgImage: imageRef)

            } catch {
                print(error.localizedDescription)
            }
            DispatchQueue.main.async {
                self.delegate.videoRecordingGenerateThumbnail(image)
            }
        }
    }
    
    private func cleanup(_ path: String) {
        
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                print("Count not remove file at url: \(path)")
            }
        }
        
        if let currentBackgroundRecordingID = backgroundRecordingID {
            backgroundRecordingID = UIBackgroundTaskIdentifier.invalid
            if currentBackgroundRecordingID != UIBackgroundTaskIdentifier.invalid {
                UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
            }
        }
    }
}
