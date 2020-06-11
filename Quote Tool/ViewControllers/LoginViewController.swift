//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   LoginViewController.swift       //
//                                              //
//  Desc:       Defines loginc of the loginview //
//                                              //
//  Creation:   04Nov19                         //
//**********************************************//

import UIKit
import SafariServices

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties of ViewController
    @IBOutlet weak private var rememberMeSwitch: UISwitch!
    @IBOutlet weak private var usernameTextField: UITextField!
    @IBOutlet weak private var passwordTextField: UITextField!
    var defaults = UserDefaults.standard
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidAppear(_ animated: Bool) {
        User.current_user.jwt = defaults.string(forKey: "jwt") ?? ""
        User.current_user.email = defaults.string(forKey: "email") ?? ""
        User.current_user.id = defaults.integer(forKey: "id")
        
        //if there are stored default values
        if !User.current_user.jwt.isEmpty && !User.current_user.email.isEmpty && User.current_user.id != 0
        {
            activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.activityIndicator.startAnimating()
            DispatchQueue.global(qos: .background).async {
                let code = apiDispatcher.dispatcher.extendLogin()
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    if(code == 200){
                        //if code works go right into app
                        let userCode = apiDispatcher.dispatcher.getUser()
                        if userCode == 500 {
                            //Internal Server Error
                            let alert = UIAlertController(title: "User Retrieval Error", message:
                                "An internal server error has been encountered. Please try again later.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                            self.present(alert, animated: true, completion: nil)
                        }
                        else {
                            //save all values persistently into defaults
                            self.defaults.setValue(User.current_user.jwt, forKey: "jwt")
                            self.defaults.setValue(User.current_user.email, forKey: "email")
                            self.defaults.setValue(User.current_user.id, forKey: "id")
                            self.performSegue(withIdentifier: "loginSegue", sender: self)
                        }
                    }
                }
            }
        }
    }
    //Upon Loading perform these actions
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        //Reset values of username and password
        usernameTextField.text = ""
        passwordTextField.text = ""
        
        //Add Tags to text fields for easy tabbing
        usernameTextField.delegate = self
        usernameTextField.tag = 0
        passwordTextField.delegate = self
        passwordTextField.tag = 1
        
        usernameTextField.textContentType = .emailAddress
        passwordTextField.textContentType = .password
        activityIndicator.hidesWhenStopped = true
    }
    
    @IBAction func forgetPasswordClicked(_ sender: Any) {
        //Send user to imperial systems website for forgot password
        let url = URL(string: "https://quote.isystemsweb.com/users/password/new")!
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
    
    
    //for when the return button is hit on a text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next text field with next tag
        if let nextTextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextTextField.becomeFirstResponder()
        }
        else {
            // No next text field found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    @IBAction func LoginClick(_ sender: Any) {
        //If username or password fields are left blank create an alert
        if passwordTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty || usernameTextField.text!.isEmpty
        {
            let alert = UIAlertController(title: "Blank Fields", message:
                "Please fill in username and password fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            let username = self.usernameTextField.text!.lowercased()
            let pass = self.passwordTextField.text!
            let rememberIsOn = self.rememberMeSwitch.isOn
            activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.activityIndicator.startAnimating()
            DispatchQueue.global(qos: .background).async {
                //Try for login
                let code = apiDispatcher.dispatcher.submitLogin(user: username, pass: pass)
                DispatchQueue.main.async {
                    //Go to the tabbed view
                    if(code == 200 || code == 202)
                    {
                        DispatchQueue.global(qos: .background).async {
                            //Successful Login
                            let userCode = apiDispatcher.dispatcher.getUser()
                            if userCode == 500 {
                                DispatchQueue.main.async {
                                    self.activityIndicator.stopAnimating()
                                    //Internal Server Error
                                    let alert = UIAlertController(title: "User Retrieval Error", message:
                                        "An internal server error has been encountered. Please try again later.", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                            else {
                                if rememberIsOn {
                                    //User wants to be remembered: save all values persistently into defaults
                                    self.defaults.setValue(User.current_user.jwt, forKey: "jwt")
                                    self.defaults.setValue(User.current_user.email, forKey: "email")
                                    self.defaults.setValue(User.current_user.id, forKey: "id")
                                }
                                else{
                                    //User doesn't want to be remembered: clear all values persistently into defaults
                                    self.defaults.removeObject(forKey: "jwt")
                                    self.defaults.removeObject(forKey: "email")
                                    self.defaults.removeObject(forKey: "id")
                                }
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                                }
                            }
                        }
                    }
                    else if(code == 401)
                    {
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            //Username/Password Invalid
                            let alert = UIAlertController(title: "Invalid username or password", message:
                                "Please check your credentials and try again.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            //Internal Server Error
                            let alert = UIAlertController(title: "Error", message:
                                "An unknown error has occured. Please check your internet connection.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}

