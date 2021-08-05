//
//  DeatilViewController.swift
//  DeatilViewController
//
//  Created by 蔡志文 on 2021/8/5.
//

import UIKit

class DetailViewController: UIViewController {

    private let color: Color

    init(_ color: Color) {
        self.color = color
        super.init(nibName: nil, bundle: nil)
    }


    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("This class does not support NSCoder")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = color.name
        view.backgroundColor = color.value
    }
    

}
