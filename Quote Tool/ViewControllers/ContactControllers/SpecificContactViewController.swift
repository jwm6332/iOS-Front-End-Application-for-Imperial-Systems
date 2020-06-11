//**************************************************//
//              Imperial Systems Inc.               //
//**************************************************//
//                                                  //
//  Filename:   SpecificContactViewController.swift //
//                                                  //
//  Desc:       View controller that presents the   //
//              user with information related to the//
//              selected contact. From this view the//
//              user can view, edit, and delete the //
//              contact.                            //
//                                                  //
//  Creation:   24Nov19                             //
//**************************************************//

import UIKit

class SpecificContactViewController: UIViewController, UITextViewDelegate {
    
    var contact = Contact()
    var contact_delegate:ContactProtocol?
    
    @IBOutlet weak var navigation: UINavigationItem!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextView!
    @IBOutlet weak var lastNameTextField: UITextView!
    @IBOutlet weak var titleTextField: UITextView!
    @IBOutlet weak var phoneTextField: UITextView!
    @IBOutlet weak var faxTextField: UITextView!
    @IBOutlet weak var emailTextField: UITextView!
    @IBOutlet weak var notesTextField: UITextView!
    
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
        //For limiting textfield lines to 1 and making sure overflow text is handled
        firstNameTextField.textContainer.maximumNumberOfLines = 1
        firstNameTextField.textContainer.lineBreakMode = .byTruncatingMiddle
        lastNameTextField.textContainer.maximumNumberOfLines = 1
        lastNameTextField.textContainer.lineBreakMode = .byTruncatingMiddle
        titleTextField.textContainer.maximumNumberOfLines = 1
        titleTextField.textContainer.lineBreakMode = .byTruncatingMiddle
        phoneTextField.textContainer.maximumNumberOfLines = 1
        phoneTextField.textContainer.lineBreakMode = .byTruncatingMiddle
        faxTextField.textContainer.maximumNumberOfLines = 1
        faxTextField.textContainer.lineBreakMode = .byTruncatingMiddle
        emailTextField.textContainer.maximumNumberOfLines = 1
        emailTextField.textContainer.lineBreakMode = .byTruncatingMiddle
        notesTextField.textContainer.maximumNumberOfLines = 10
        notesTextField.textContainer.lineBreakMode = .byTruncatingMiddle
        
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
        
        self.setupData()
        self.doneButton.isHidden = true
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        titleTextField.delegate = self
        phoneTextField.delegate = self
        faxTextField.delegate = self
        emailTextField.delegate = self
        notesTextField.delegate = self
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
        return text != "\n"
    }
    
    //**********************************************//
    //                                              //
    //  func:   editClicked                         //
    //                                              //
    //  Desc:   When the edit button is clicked,    //
    //          this adjusts the appropriate view   //
    //          elements to be editable and adjusts //
    //          the view styling to show the user   //
    //          what is editable.                   //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func editClicked(_ sender: Any) {
        //Making all fields editable
        firstNameTextField.isEditable = true
        lastNameTextField.isEditable = true
        titleTextField.isEditable = true
        faxTextField.isEditable = true
        phoneTextField.isEditable = true
        emailTextField.isEditable = true
        notesTextField.isEditable = true
        
        //Changing colors of text fields to make them noticeable
        firstNameTextField.backgroundColor = UIColor.gray
        lastNameTextField.backgroundColor = UIColor.gray
        titleTextField.backgroundColor = UIColor.gray
        faxTextField.backgroundColor = UIColor.gray
        phoneTextField.backgroundColor = UIColor.gray
        emailTextField.backgroundColor = UIColor.gray
        notesTextField.backgroundColor = UIColor.gray
        
        //Disabling buttons user should not be able to access
        self.deleteButton.isEnabled = false
        self.editButton.isEnabled = false
        self.doneButton.isHidden = false
        self.doneButton.isEnabled = true
    }
    
    //**********************************************//
    //                                              //
    //  func:   deleteClicked                       //
    //                                              //
    //  Desc:   First checks to see if the specified//
    //          contact has quotes logged under     //
    //          their contact_id. If true, an alert //
    //          is generated to warn the user and   //
    //          func is exitted. If false, the user //
    //          is asked to confirm their decision. //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func deleteClicked(_ sender: Any) {
        let quoteArray = apiDispatcher.dispatcher.getAllQuotes(DESC: false)
        var contactInUse = false
        for element in quoteArray{
            if(element.contact_id == contact.id){
                contactInUse = true
            }
        }
        if(contactInUse){
            let alert = UIAlertController(title: "Unable to delete", message: "This contact is currently being used in a quote.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            //Successful Change
            let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete \(contact.first_name!) \(contact.last_name!)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                let code = apiDispatcher.dispatcher.deleteContact(id: self.contact.id)
                if(code == 200){
                    //Set account for deletion on account view
                    self.contact.first_name = ""
                    self.contact_delegate?.passContact(contact: self.contact, new: false)
                    self.navigationController?.popViewController(animated: true)
                }
                else{
                    let alert = UIAlertController(title: "Error", message: "There was an error deleting that account. Try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   deleteClicked                       //
    //                                              //
    //  Desc:   First checks to see if the specified//
    //          contact has quotes logged under     //
    //          their contact_id. If true, an alert //
    //          is generated to warn the user and   //
    //          func is exitted. If false, the user //
    //          is asked to confirm their decision. //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func doneClicked(_ sender: Any) {
        if (!firstNameTextField.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty && !lastNameTextField.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty){
            //Used to save current state of contact if API doesn't update it
            let tempContact = Contact.init(first_name: contact.first_name, last_name: contact.last_name, email: contact.email!, fax: contact.fax!, phone: contact.phone!, title: contact.title!, notes: contact.notes!, id: contact.id, account_id: contact.account_id, created: contact.modified_dates.created_at, updated: contact.modified_dates.updated_at)
            contact.first_name = self.firstNameTextField.text
            contact.last_name = self.lastNameTextField.text
            contact.phone = self.phoneTextField.text
            contact.fax = self.faxTextField.text
            contact.email = self.emailTextField.text
            contact.title = self.titleTextField.text
            contact.notes = self.notesTextField.text
            
            //If account was edited
            if(!contact.equals(contact: tempContact)){
                let code = apiDispatcher.dispatcher.updateContact(contactObj: contact)
                if(code == 200){
                    contact = apiDispatcher.dispatcher.getContact(id: contact.id)
                    contact_delegate?.passContact(contact: contact, new: false)
                    self.setupData()
                }
                else{
                    contact = tempContact
                    self.setupData()
                    let alert = UIAlertController(title: "Internal Server Error", message:
                        "Please try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            if traitCollection.userInterfaceStyle == .light {
                //For light mode
                self.firstNameTextField.backgroundColor = UIColor.white
                self.lastNameTextField.backgroundColor = UIColor.white
                self.phoneTextField.backgroundColor = UIColor.white
                self.faxTextField.backgroundColor = UIColor.white
                self.titleTextField.backgroundColor = UIColor.white
                self.phoneTextField.backgroundColor = UIColor.white
                self.emailTextField.backgroundColor = UIColor.white
                self.notesTextField.backgroundColor = UIColor.white
            }
            else {
                //For dark mode
                self.firstNameTextField.backgroundColor = UIColor.black
                self.lastNameTextField.backgroundColor = UIColor.black
                self.phoneTextField.backgroundColor = UIColor.black
                self.faxTextField.backgroundColor = UIColor.black
                self.titleTextField.backgroundColor = UIColor.black
                self.phoneTextField.backgroundColor = UIColor.black
                self.emailTextField.backgroundColor = UIColor.black
                self.notesTextField.backgroundColor = UIColor.black
            }
            
            self.firstNameTextField.isEditable = false
            self.lastNameTextField.isEditable = false
            self.phoneTextField.isEditable = false
            self.faxTextField.isEditable = false
            self.titleTextField.isEditable = false
            self.phoneTextField.isEditable = false
            self.emailTextField.isEditable = false
            self.notesTextField.isEditable = false
            self.deleteButton.isEnabled = true
            self.editButton.isEnabled = true
            self.doneButton.isHidden = true
            self.doneButton.isEnabled = false
        }
        else{
            var alertText : String = ""
            if(firstNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty){
                alertText.append("First Name can't be blank.\n")
            }
            if(lastNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty){
                alertText.append("Last Name can't be blank.\n")
            }
            let alert = UIAlertController(title: "Required fields blank", message:
                alertText, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   setupData                           //
    //                                              //
    //  Desc:   Populates the appropriate text      //
    //          fields with their respective data   //
    //          when the view is brought up.        //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func setupData() {
        //Setting account data to text fields
        navigation.title = contact.first_name + " " + contact.last_name
        firstNameTextField.text = contact.first_name
        lastNameTextField.text = contact.last_name
        titleTextField.text = contact.title
        faxTextField.text = contact.fax
        phoneTextField.text = contact.phone
        emailTextField.text = contact.email
        notesTextField.text = contact.notes
    }
    
    //*****************************************************//
    //                                                     //
    //  func:   traitCollectionDidChange                   //
    //                                                     //
    //  Desc:   Handles style changes when the             //
    //          device is in light or dark mode.           //
    //                                                     //
    //  args:   previousTraitCollection: UITraitCollection //
    //*****************************************************//
    //If iOS transitioned from light/dark or dark/light
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.userInterfaceStyle == .light {
            //For light mode
            self.firstNameTextField.backgroundColor = UIColor.white
            self.lastNameTextField.backgroundColor = UIColor.white
            self.phoneTextField.backgroundColor = UIColor.white
            self.faxTextField.backgroundColor = UIColor.white
            self.titleTextField.backgroundColor = UIColor.white
            self.phoneTextField.backgroundColor = UIColor.white
            self.emailTextField.backgroundColor = UIColor.white
            self.notesTextField.backgroundColor = UIColor.white
        }
        else {
            //For dark mode
            self.firstNameTextField.backgroundColor = UIColor.black
            self.lastNameTextField.backgroundColor = UIColor.black
            self.phoneTextField.backgroundColor = UIColor.black
            self.faxTextField.backgroundColor = UIColor.black
            self.titleTextField.backgroundColor = UIColor.black
            self.phoneTextField.backgroundColor = UIColor.black
            self.emailTextField.backgroundColor = UIColor.black
            self.notesTextField.backgroundColor = UIColor.black
        }
    }
}
