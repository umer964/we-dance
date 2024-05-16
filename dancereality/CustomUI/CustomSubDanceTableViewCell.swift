//
//  CustomSubDanceTableViewCell.swift
//  dancereality
//
//  Created by Saad Bin Khalid on 26.09.23.
//

import UIKit

class CustomSubDanceTableViewCell: UITableViewCell {
    @IBOutlet weak var des: UILabel!
    
    @IBOutlet weak var female: UIImageView!
    @IBOutlet weak var male: UIImageView!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        female.isHidden = true
        male.isHidden = true
        des.isHidden = true
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if(!selected){
            female.isHidden = true
            male.isHidden = true
            des.isHidden = true
        } else {
            female.isHidden = false
            male.isHidden = false
            des.isHidden = false
        }
        // Configure the view for the selected state
    }
    
}
