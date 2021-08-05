//
//  ColorCell.swift
//  ColorCell
//
//  Created by 蔡志文 on 2021/8/4.
//

import UIKit

class ColorCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.layer.shadowColor = UIColor.black.cgColor
        nameLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        nameLabel.layer.shadowRadius = 2
        nameLabel.layer.shadowOpacity = 0.6
        
        colorView.layer.cornerRadius = 15
        colorView.layer.shadowColor = UIColor.gray.cgColor
        colorView.layer.shadowOffset = CGSize(width: 2, height: 2)
        colorView.layer.shadowRadius = 2
        colorView.layer.shadowOpacity = 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
