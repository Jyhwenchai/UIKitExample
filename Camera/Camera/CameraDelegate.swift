//
//  CameraDelegate.swift
//  CameraDelegate
//
//  Created by 蔡志文 on 2021/9/7.
//

import UIKit

protocol CameraDelegate {
    func didAddVideoInputDevice()
}


protocol CameraOldDelegate: AnyObject {
    func camera(_ camera: CameraOld, sessionSetupResult: CameraOld.SessionSetupResult, error: Error?)
}

protocol VideoRecordingProcessDelegate {
    func videoRecordingDidStart()
    func videoRecordingDidFinished(_ outputFileURL: URL)
    func videoRecordingGenerateThumbnail(_ thumbnail: UIImage?)
    func videoRecordingError(_ error: Error)
}

protocol PhotoCaptureProcessDelegate {
    func photoCaptureWillBeginCapture()
    func photoCaptureWillCapturePhoto()
    func photoCaptureDidFinishCapture(_ data: Data)
    func photoCaptureError(_ error: Error)
}
