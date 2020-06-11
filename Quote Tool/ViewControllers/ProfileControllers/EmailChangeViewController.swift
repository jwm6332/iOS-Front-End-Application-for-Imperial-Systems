//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   EmailChangeViewController.swift  //
//                                              //
//  Desc:      Defines actions of change user   //
//             profile view                     //
//                                              //
//  Creation:   04Nov19                         //
//**********************************************//

import UIKit

class EmailChangeViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properites
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var confEmailTextField: UITextField!
    var defaults = UserDefaults.standard
    
    //**********************************************//
    //                                              //
    //  func:   viewDidLoad                         //
    //                                              //
    //  Desc:   Function that takes care of         //
    //          initializing the view and all of its//
    //          components. Many styling adjustments//
    //          exist here.                         //
    //                                              //
    //  args:                                       //
    //**********************************************//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Reset strings in text fields
        emailTextField.text = ""
        confEmailTextField.text = ""
        //Add Tags to text fields for easy tabbing
        emailTextField.delegate = self
        emailTextField.tag = 0
        confEmailTextField.delegate = self
        confEmailTextField.tag = 1
        submit.layer.cornerRadius = submit.bounds.size.height/2
    }
    
    //**********************************************//
    //                                              //
    //  func:   textFieldShouldReturn               //
    //                                              //
    //  Desc:   Move to next text field when the    //
    //          return key is pressed               //
    //                                              //
    //  args:   textField - UITextField             //
    //**********************************************//
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next text field with next tag
        if let nextTextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextTextField.becomeFirstResponder()
        }
        else
        {
            // No next text field found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
        
    }
    
    //**********************************************//
    //                                              //
    //  func:   submitClicked                       //
    //                                              //
    //  Desc:   When the submit button is clicked,  //
    //          this attempts to change the user's  //
    //          email. Error checking exists to     //
    //          confirm the fields are not blank,   //
    //          inconsistent, or invalid.           //
    //          If the email changes successfully   //
    //          the user is logged out and brought  //
    //          to the login view.                  //
    //                                              //
    //  args:                                       //
    //**********************************************//
    @IBAction func submitClicked(_ sender: Any) {
        if emailTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
            || confEmailTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            let alert = UIAlertController(title: "Blank Fields", message:
                "Please fill in both username fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            
            self.present(alert, animated: true, completion: nil)
        }
        else if !emailTextField.text!.contains("@"){
            let alert = UIAlertController(title: "Email Invalid", message:
                "Please provide an email address including @ symbol.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
        else if emailTextField.text != confEmailTextField.text
        {
            let alert = UIAlertController(title: "Inconsistent Emails", message:
                "Email and Email confirmation do not match", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            //everything is correct and we can change the username and password
            let code = apiDispatcher.dispatcher.updateUserEmail(user: emailTextField.text!)
            //Go to the tabbed view
            if(code == 200 || code == 202)
            {
                User.current_user.id = 0
                User.current_user.email = ""
                User.current_user.jwt = ""
                emailTextField.text = ""
                confEmailTextField.text = ""
                //Successful Change
                let alert = UIAlertController(title: "Success", message:
                    "Your email has been changed!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: {_ in
                    //goes back to main screen to re-login because all calls will be invalid until relogging in
                    for v in self.view.subviews{
                        v.removeFromSuperview()
                    }
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let loginController = storyBoard.instantiateViewController(withIdentifier: "LoginController") as! LoginViewController
                    loginController.modalPresentationStyle = .fullScreen
                    self.present(loginController, animated:true, completion:nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                //Internal Server Error
                let alert = UIAlertController(title: "Error", message:
                    "Please check your internet connection and try again!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
