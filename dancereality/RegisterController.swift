//
//  RegisterController.swift
//  dancereality
//
//  Created by Saad Bin Khalid on 28.11.23.
//

import Foundation
import UIKit
import Lottie
class RegisterController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var verificationLink: UITextView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var error: UILabel!
    @IBOutlet weak var gender: UIButton!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var rePassword: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var rePasswordLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var animationView: UIView!
    private var animationViewHolder : AnimationView = .init(name: "tanzapp_start")
    private let dropdownTableView: UITableView = {
            let tableView = UITableView()
            tableView.isHidden = true
            return tableView
    }()

    private let options = ["MALE", "FEMALE"]

    override func viewDidLoad() {
        initiateViews()
        animationViewHolder.frame = view.bounds
        
        // 3. Set animation content mode
        
        animationViewHolder.contentMode = .scaleAspectFit
        
        // 4. Set animation loop mode
        
        animationViewHolder.loopMode = .playOnce
        
        // 5. Adjust animation speed
        
        animationViewHolder.animationSpeed = 1.0
        
        animationView.addSubview(animationViewHolder)
        animationViewHolder.play()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        age.resignFirstResponder()
        gender.resignFirstResponder()
        password.resignFirstResponder()
        rePassword.resignFirstResponder()
        gender.resignFirstResponder()
    }
    
    private func makeRegisterRequest(email: String, password: String, firstName: String, lastName: String, age: Int, gender: String){
        let user = User(name: lastName, firstName: firstName, gender: gender, age: age, password: password, email: email, isActive: false)
        NetworkManager.registerUserRequest(user: user){(data: UserRegister?) in
            if let data = data {
                self.error.isHidden = true
                self.hideAllViewsAndShowCode(email: data.user.email, code: data.verification.code)
            } else {
                self.error.isHidden = false
                self.error.text = "Something Went Wrong"
            }
        }
    }
    
    private func hideAllViewsAndShowCode(email: String, code: String){
        registerLabel.text = "Verification"
        error.isHidden = true
        firstName.isHidden = true
        firstNameLabel.isHidden = true
        lastName.isHidden = true
        lastNameLabel.isHidden = true
        emailLabel.isHidden = true
        self.email.isHidden = true
        password.isHidden = true
        passwordLabel.isHidden = true
        rePassword.isHidden = true
        rePasswordLabel.isHidden = true
        age.isHidden = true
        ageLabel.isHidden = true
        gender.isHidden = true
        genderLabel.isHidden = true
        registerBtn.isHidden = true
        verificationLink.text = "Please Verify Your Identity By Email"
        verificationLink.isHidden = false
        verificationLink.isEditable = false
        verificationLink.isSelectable = true
        verificationLink.dataDetectorTypes = .link

                // Set link text attributes (you can customize the appearance)
        verificationLink.linkTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.blue,
                    NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        verificationLink.delegate = self

    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            // Handle link tap here
        print("Link tapped: \(URL.absoluteString)")
        self.dismiss(animated: true)
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return false // Return false to allow default behavior (open link), or return true to handle it yourself
    }
    
    private func validateRegisterRequest() -> Bool{
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            // Perform actions when the view is about to appear

            // Example: Update data or refresh UI
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

            // Perform actions when the view controller is focused or becomes active
        guard let registerResponse = FileHelper.getObjectFromUserRegisterDefaults(key: "USER_REGISTER") else {
            return
        }
        NetworkManager.loginRequest(email: registerResponse.user.email, password: registerResponse.user.password){(data: LoginPassed?) in
            if(data != nil){
                FileHelper.saveObjectToUserRegisterDefaults(object: nil, key: "USER_REGISTER")
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "controller") as! ViewController
                nextViewController.modalPresentationStyle = .fullScreen
                self.present(nextViewController, animated:true, completion:nil)
            } else {
               return
            }
        }
    }
    @IBAction func loginBtnTapped(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    @IBAction func registerBtnTapped(_ sender: Any) {
        guard let email = email.text,
              let password = password.text,
              let rePassword = rePassword.text,
              let age = age.text,
              let firstName = firstName.text,
              let gender = gender.titleLabel?.text,
              let name = lastName.text
              
        else {
            error.isHidden = false
            error.text = "Please Fill All Fields"
            return
        }
        
        if(!isValidEmail(email)){
            error.isHidden = false
            error.text = "Please Enter a Valid Email"
            return
        }
        
        guard let ageToNumber = Int(age) else {
            error.isHidden = false
            error.text = "Please Enter Valid Age"
            return
        }
        
        if(password != rePassword){
            error.isHidden = false
            error.text = "Passwords Not Matched"
            return
        }
        error.isHidden = true
        makeRegisterRequest(
            email: email, password: password, firstName: firstName, lastName: name, age: ageToNumber, gender: gender)
    }
    
    private func initiateViews(){
        error.isHidden = true
        verificationLink.isHidden = true
        let popUpButtonClosure = { (action: UIAction) in
                print("Pop-up action")
            }
                    
        gender.menu = UIMenu(children: [
                UIAction(title: "MALE", handler: popUpButtonClosure),
                UIAction(title: "FEMALE", handler: popUpButtonClosure)
            ])
        gender.showsMenuAsPrimaryAction = true
        gender.addTarget(self, action: #selector(dropdownButtonTapped), for: .touchUpInside)
    }

    private func setupDropdownTableView() {
        view.addSubview(dropdownTableView)
        dropdownTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                dropdownTableView.topAnchor.constraint(equalTo: gender.bottomAnchor, constant: 5),
                dropdownTableView.leadingAnchor.constraint(equalTo: gender.leadingAnchor),
                dropdownTableView.widthAnchor.constraint(equalTo: gender.widthAnchor),
                dropdownTableView.heightAnchor.constraint(equalToConstant: 120)
        ])

        dropdownTableView.dataSource = self
        dropdownTableView.delegate = self
        dropdownTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @objc private func dropdownButtonTapped() {
           dropdownTableView.isHidden.toggle()
    }

       // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
           cell.textLabel?.text = options[indexPath.row]
           return cell
    }

       // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           let selectedOption = options[indexPath.row]
           gender.setTitle(selectedOption, for: .normal)
           dropdownTableView.isHidden = true
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
