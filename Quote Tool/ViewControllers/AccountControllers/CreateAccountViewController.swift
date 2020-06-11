//************************************************//
//          Imperial Systems Inc.                 //
//************************************************//
//                                                //
//  Filename:   CreateAccountViewController.swift //
//                                                //
//  Desc:       Search for file functionality     //
//                                                //
//  Creation:   03Mar20                           //
//************************************************//

import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    var account_delegate: AccountProtocol?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var street2TextField: UITextField!
    @IBOutlet weak var street1TextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var faxTextField: UITextField!
    
    @IBOutlet weak var createAccountButton: UIButton!
    
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
        nameTextField.delegate = self
        phoneTextField.delegate = self
        zipCodeTextField.delegate = self
        faxTextField.delegate = self
        websiteTextField.delegate = self
        street1TextField.delegate = self
        street2TextField.delegate = self
        cityTextField.delegate = self
        cityTextField.delegate = self
        stateTextField.delegate = self
        countryTextField.delegate = self
        
        //For Rounded Text Views
        nameTextField.layer.cornerRadius = 5
        nameTextField.clipsToBounds = true
        phoneTextField.layer.cornerRadius = 5
        phoneTextField.clipsToBounds = true
        zipCodeTextField.layer.cornerRadius = 5
        zipCodeTextField.clipsToBounds = true
        faxTextField.layer.cornerRadius = 5
        faxTextField.clipsToBounds = true
        websiteTextField.layer.cornerRadius = 5
        websiteTextField.clipsToBounds = true
        street1TextField.layer.cornerRadius = 5
        street1TextField.clipsToBounds = true
        street2TextField.layer.cornerRadius = 5
        street2TextField.clipsToBounds = true
        cityTextField.layer.cornerRadius = 5
        cityTextField.clipsToBounds = true
        stateTextField.layer.cornerRadius = 5
        stateTextField.clipsToBounds = true
        countryTextField.layer.cornerRadius = 5
        countryTextField.clipsToBounds = true
        createAccountButton.layer.cornerRadius = createAccountButton.bounds.size.height/2
    }
    
    //**********************************************//
    //                                              //
    //  func:   textFieldShouldReturn               //
    //                                              //
    //  Desc:   On return key pressed, move to the  //
    //          next editable data field            //
    //                                              //
    //  args:   textField - UITextField             //
    //**********************************************//
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    //**********************************************//
    //                                              //
    //  func:   createAccountClicked                //
    //                                              //
    //  Desc:   Upon button press, attempt to create//
    //          a new account using the data fields //
    //          in the view. This performs some     //
    //          error checking to avoid blanks      //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func createAccountClicked(_ sender: Any) {
        if (!nameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty && !cityTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty && !stateTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty) {
            var account = Account.init(name: nameTextField.text!, state: stateTextField.text ?? "", city: cityTextField.text ?? "", country: countryTextField.text ?? "", street_1: street1TextField.text ?? "", postal_code: zipCodeTextField.text ?? "", fax: faxTextField.text ?? "", phone: phoneTextField.text ?? "", website: websiteTextField.text ?? "")
            let id = apiDispatcher.dispatcher.postNewAccount(accountObj: account)
            if(id == 0){
                let alert = UIAlertController(title: "Internal Server Error", message:
                    "Please try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                account = apiDispatcher.dispatcher.getAccount(id: id)
                account_delegate?.passData(account: account, new: true)
                self.navigationController?.popViewController(animated: true)
            }
        }
        else{
            var alertText : String = ""
            if(nameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty){
                alertText.append("Name can't be blank.\n")
            }
            if(cityTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty){
                alertText.append("City can't be blank.\n")
            }
            if(stateTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty){
                alertText.append("State can't be blank.\n")
            }
            let alert = UIAlertController(title: "Required fields blank", message:
                alertText, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
