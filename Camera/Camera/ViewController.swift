//
//  ViewController.swift
//  Camera
//
//  Created by 蔡志文 on 2021/9/3.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var windowOrientation: UIInterfaceOrientation {
        return view.window?.windowScene?.interfaceOrientation ?? .unknown
    }
   
    let camera = CameraOld()

    @IBOutlet weak var previewView: PreviewView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if camera.setupSession() {
            previewView.session = camera.session
            camera.startSession()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        camera.startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        camera.stopSession()
        super.viewWillDisappear(animated)
    }
    
    @IBAction func flashButtonAction(_ sender: UIButton) {
        if camera.flashMode == .off {
            camera.configureFlashMode(.on)
        } else {
            camera.configureFlashMode(.off)
        }
        sender.tintColor = camera.flashMode == .off ? .white : .yellow
    }
    
    @IBAction func recordButtonAction(_ sender: UIButton) {
        if !camera.isRecording {
            sender.isSelected = true
            camera.startRecording(with: self, orientation: previewView.videoPreviewLayer.connection!.videoOrientation)
        } else {
            sender.isSelected = false
            camera.stopRecording()
        }
    }
    
    @IBAction func takePhotoAction(_ sender: UIButton) {
        camera.capturePhoto(with: self, orientation: previewView.videoPreviewLayer.connection!.videoOrientation)
    }
    
    @IBAction func switchCamera(_ sender: Any) {
        
        if camera.switchCamera() {
            camera.resetFocusAndExposure()
        }
        
    }
    
    @IBAction func captureModeChanged(_ sender: UISegmentedControl) {
        camera.captureMode = CameraOld.CaptureMode(rawValue: sender.tag)!
        camera.resetFocusAndExposure()
    }
}

extension ViewController: CameraDelegate {
    func didAddVideoInputDevice() {
        var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
        if self.windowOrientation != .unknown {
            if let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: windowOrientation) {
                initialVideoOrientation = videoOrientation
            }
        }
        
        previewView.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
    }
}

extension ViewController: VideoRecordingProcessDelegate {
    
    func videoRecordingGenerateThumbnail(_ thumbnail: UIImage?) {
        print(#function)
        print(thumbnail)
    }
    
    func videoRecordingDidStart() {
        print(#function)
    }
    
    func videoRecordingDidFinished(_ outputFileURL: URL) {
        print(#function)
    }
    
    func videoRecordingError(_ error: Error) {
        print(#function)
    }
    
    
}

extension ViewController: PhotoCaptureProcessDelegate {
    func photoCaptureWillBeginCapture() {
        print(#function)
    }
    
    func photoCaptureWillCapturePhoto() {
        print(#function)
    }
    
    func photoCaptureDidFinishCapture(_ data: Data) {
        print(#function)
    }
    

    func photoCaptureError(_ error: Error) {
        print(#function)
    }
    
    
}
