//
//  CustomTableView.swift
//  dancereality
//
//  Created by Saad Bin Khalid on 25.09.23.
//

import UIKit

class CustomSubDanceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var male: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var femlae: UIImageView!
    @IBOutlet weak var video: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMaleTap(_:)))
              
              // Add the gesture recognizer to the cell's content view
        contentView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleMaleTap(_ gesture: UITapGestureRecognizer) {
            // Implement your tap handling code here
            // For example, you can notify your delegate or perform a segue
        print("mfeale")
    }
    
}
