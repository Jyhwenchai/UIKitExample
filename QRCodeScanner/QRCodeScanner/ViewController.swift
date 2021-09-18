//
//  ViewController.swift
//  QRCodeScanner
//
//  Created by 蔡志文 on 2021/9/14.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var previewView: QRCodeScannerView!
    
    var qrCodeScannner: QRCodeScanner!
    
    @IBOutlet weak var torchButton: UIButton!
    @IBOutlet weak var torchLabel: UILabel!
    
    let label: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let scanner = QRCodeScanner(with: previewView) {
            qrCodeScannner = scanner
            scanner.startRunning()
            scanner.monitorLight = { brightnessValue in
                if brightnessValue < 0 && !scanner.isOpenTorch {
                    self.showTorchUI()
                } else if brightnessValue > 0 && !scanner.isOpenTorch {
                    self.hiddenTorchUI()
                }
            }
            scanner.scanResult = { value in
                DispatchQueue.main.async {
                    if case .success(let text) = value {
                        self.label.text = "find qr code text:\n \(text) "
                    }
                }
            }
            
        }
        
        label.numberOfLines = 0
        label.frame = CGRect(x: 50, y: 100, width: view.frame.width - 100, height: 60)
        view.addSubview(label)
    }
    
    func showTorchUI() {
        torchButton.isHidden = false
        torchLabel.isHidden = false
        torchLabel.text = "轻触照亮"
    }
    
    func closeTorchUI() {
        torchButton.isHidden = false
        torchLabel.isHidden = false
        torchLabel.text = "轻触关闭"
    }

    func hiddenTorchUI() {
        torchButton.isHidden = true
        torchLabel.isHidden = true
    }

    @IBAction func torchAction(_ sender: Any) {
        if !qrCodeScannner.isOpenTorch {
            qrCodeScannner.openTorch(true)
            closeTorchUI()
        } else {
            qrCodeScannner.openTorch(false)
        }
    }
    
    @IBAction func pickerAction(_ sender: Any) {
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            picker.dismiss(animated: true) {
                self.qrCodeScannner.scanImageQRCode(image)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

