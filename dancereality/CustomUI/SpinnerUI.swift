//
//  SpinnerUI.swift
//  dancereality
//
//  Created by Saad Khalid on 19.08.22.
//

import Foundation
import UIKit

class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)

    override func loadView() {
        view = UIView()
        
        view.backgroundColor = UIColor.gray
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        label.textAlignment = .center
        label.text = "Preparing View"
        view.addSubview(label)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }
}

