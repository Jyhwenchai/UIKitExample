//
//  QRCodeCreaterViewController.swift
//  QRCodeScanner
//
//  Created by 蔡志文 on 2021/9/26.
//

import UIKit

class QRCodeCreaterViewController: UIViewController {

    @IBOutlet weak var codeImageVIew: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if #available(iOS 15, *) {
            Task {
                if let image = await QRCodeCreater.asyncCreateQRCodeImage(with: "hello, world!", size: CGSize(width: 300, height: 300)) {
                    codeImageVIew.image = image
                }
            }
        } else {
            if let codeImage = QRCodeCreater.createQRCodeImage(with: "hello, world!", size: CGSize(width: 300, height: 300), backgroundColor: UIColor.lightGray, frontColor: .orange, centerImage: UIImage(named: "logo_bank_00")) {
                codeImageVIew.image = codeImage
            }
            
        }
    }
    
}
