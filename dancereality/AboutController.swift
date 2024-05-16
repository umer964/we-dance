//
//  AboutController.swift
//  dancereality
//
//  Created by Saad Bin Khalid on 18.01.24.
//

import UIKit

class AboutController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
        view.backgroundColor = UIColor.white

        let aboutLabel = UILabel()
        aboutLabel.text = "Please note that this is the beta version of our app! Buttons that are gray are not yet stored with 3-D models or videos! Thanx!"
        aboutLabel.textAlignment = .center
        aboutLabel.numberOfLines = 0
        aboutLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(aboutLabel)

        NSLayoutConstraint.activate([
            aboutLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            aboutLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            aboutLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            aboutLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor, constant: 20),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
