//
//  loginController.swift
//  dancereality
//
//  Created by Saad Bin Khalid on 02.11.23.
//

import UIKit
import Lottie

class LoginController: UIViewController {
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var registerBtnTapped: UIButton!
    @IBOutlet weak var error: UILabel!
    private var animationViewHolder : AnimationView = .init(name: "tanzapp_start")
    
    override func viewDidLoad() {
        error.isHidden = true
        error.text = "Invalid Credentials"
        password.isSecureTextEntry = true
        animationViewHolder.frame = view.bounds
        
        // 3. Set animation content mode
        
        animationViewHolder.contentMode = .scaleAspectFit
        
        // 4. Set animation loop mode
        
        animationViewHolder.loopMode = .playOnce
        
        // 5. Adjust animation speed
        
        animationViewHolder.animationSpeed = 1.0
        
        animationView.addSubview(animationViewHolder)
        animationViewHolder.play()
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        guard let email = email.text else {
            error.text = "Enter Email"
            error.isHidden = false
            return
        }
        guard let password = password.text else {
            error.text = "Enter Password"
            error.isHidden = false
            return
        }
        NetworkManager.loginRequest(email: email, password: password) { (data: LoginPassed?) in
            if (data == nil) {
                print("error login")
                self.error.isHidden = false
                self.error.text = "Invalid Credentials"
            } else {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "controller") as! ViewController
                nextViewController.modalPresentationStyle = .fullScreen
                self.present(nextViewController, animated:true, completion:nil)
            }
        }
    }
    
    @IBAction func registerBtnTapped(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "RegisterController") as! RegisterController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                         action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
