//************************************************//
//          Imperial Systems Inc.                 //
//************************************************//
//                                                //
//  Filename:   CreateContactViewController.swift //
//                                                //
//  Desc:       Allows the user to create a new   //
//              contact under a selected account. //
//              Upon a success, the user will be  //
//              brought back to an updated        //
//              SpecificAccountView               //
//                                                //
//  Creation:   24Nov19                           //
//************************************************//

import UIKit

class CreateContactViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var account_id: Int = 0
    var contact_delegate:ContactProtocol?
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var faxTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextView!
    @IBOutlet weak var createContactButton: UIButton!
    
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
        createContactButton.layer.cornerRadius = createContactButton.bounds.size.height/2
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        titleTextField.delegate = self
        phoneTextField.delegate = self
        faxTextField.delegate = self
        emailTextField.delegate = self
        notesTextField.delegate = self
        //For Rounded Text Views
        firstNameTextField.layer.cornerRadius = 5
        firstNameTextField.clipsToBounds = true
        lastNameTextField.layer.cornerRadius = 5
        lastNameTextField.clipsToBounds = true
        titleTextField.layer.cornerRadius = 5
        titleTextField.clipsToBounds = true
        faxTextField.layer.cornerRadius = 5
        faxTextField.clipsToBounds = true
        phoneTextField.layer.cornerRadius = 5
        phoneTextField.clipsToBounds = true
        emailTextField.layer.cornerRadius = 5
        emailTextField.clipsToBounds = true
    }
    
    //**********************************************//
    //                                              //
    //  func:   textView                            //
    //                                              //
    //  Desc:   Replaces the text in the passed     //
    //          UITextView with a newline character //
    //                                              //
    //  args:   textView - UITextView               //
    //          shouldChangeTextIn - NSRange        //
    //          replacementText - String            //
    //**********************************************//
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return text != "\n" //Makes return button do nothing
    }
    
    //**********************************************//
    //                                              //
    //  func:   createContactClicked                //
    //                                              //
    //  Desc:   Implements some error checking to   //
    //          ensure the contact's first and last //
    //          name are both entered. This then    //
    //          attempts to create a new contact for//
    //          the current user with the info      //
    //          provided in the UI elements.        //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func createContactClicked(_ sender: Any) {
        if firstNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty || lastNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            let alert = UIAlertController(title: "Blank Fields", message:
                "Please ensure first and last name fields are not blank.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let newContact = Contact.init(first_name: firstNameTextField.text!, last_name: lastNameTextField.text!, email: emailTextField.text!, fax: faxTextField.text!, phone: phoneTextField.text!, title: titleTextField.text!, notes: notesTextField.text!, id: 0, account_id: account_id, created: "", updated: "")
            let id = apiDispatcher.dispatcher.postNewContact(contactObj: newContact)
            if id == 0 {
                let alert = UIAlertController(title: "Error", message:
                    "A new contact could not be made at this time. Please try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                let contact = apiDispatcher.dispatcher.getContact(id: id)
                contact_delegate?.passContact(contact: contact, new: true) //add contact to table in specificAccountView
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
