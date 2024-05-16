//
//  AlertViewController.swift
//  dancereality
//
//  Created by Saad Khalid on 26.08.22.
//

import Foundation
import UIKit

class AlertViewController: UIViewController {
    @IBOutlet weak var alertUi: UIView!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    public var tag = 0
    private var subject: String = "Default"
    public var center: CGPoint = CGPoint(x: 0.0, y: 0.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        let screen = UIScreen.main.bounds
        alertUi.center = CGPoint(x: screen.midX, y: screen.midY)
        indicator.startAnimating()
        status.text = subject
    }
    
    public func setStatus(title: String) {
        self.subject = title
    }
    
    public func resetStatus() {
        self.status.text = self.subject
    }
    
}
