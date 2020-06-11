//**************************************************//
//          Imperial Systems Inc.                   //
//**************************************************//
//                                                  //
//  Filename:   SpecificAccountViewController.swift //
//                                                  //
//  Desc:       Search for file functionality       //
//                                                  //
//  Creation:   03Mar20                             //
//**************************************************//

import UIKit

class ContactsCell: UITableViewCell {
    
    @IBOutlet weak var fullNameTextField: UILabel!
}

class SpecificAccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ContactProtocol, UITextViewDelegate {
    
    //**********************************************//
    //                                              //
    //  func:   passData                            //
    //                                              //
    //  Desc:   Used to update data from one view   //
    //          to the next. Avoids having to       //
    //          refresh the application to see new  //
    //          updates to the contact list         //
    //                                              //
    //  args:   contact - Contact                   //
    //          new  - Bool                         //
    //**********************************************//
    func passContact(contact: Contact, new: Bool) {
        if !contact.first_name.isEmpty && new == false {
            contactArray[rowSelected] = contact
        }
            //Was deleted
        else if contact.first_name.isEmpty && new == false {
            contactArray.remove(at: rowSelected)
        }
            //Was created
        else {
            contactArray.append(contact)
        }
        contactsTable.reloadData()
    }
    
    
    @IBOutlet weak var contactsTable: UITableView!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var doneEditingButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    
    @IBOutlet weak var zipCodeTextField: UITextView!
    @IBOutlet weak var nameTextField: UITextView!
    @IBOutlet weak var phoneTextField: UITextView!
    @IBOutlet weak var faxTextField: UITextView!
    @IBOutlet weak var websiteTextField: UITextView!
    @IBOutlet weak var street1TextField: UITextView!
    @IBOutlet weak var street2TextField: UITextView!
    @IBOutlet weak var cityTextField: UITextView!
    @IBOutlet weak var countryTextField: UITextView!
    @IBOutlet weak var stateTextField: UITextView!
    var account_delegate:AccountProtocol?
    var rowSelected: Int = 0
    var selectedContact = Contact()
    var account = Account()
    var contactArray = [Contact]()
    
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
        self.contactsTable.estimatedRowHeight = 60
        self.contactsTable.delegate = self
        self.contactsTable.dataSource = self
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .default).async {
            self.contactArray = apiDispatcher.dispatcher.getAllContactsForAccount(DESC: false, account_id: self.account.id)
            DispatchQueue.main.async { [weak self] in
                // UI updates must be on main thread
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                self?.contactsTable.reloadData()
            }
        }
        
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
        
        //For limiting textfield lines to 1 and making sure overflow text is handled
        nameTextField.textContainer.maximumNumberOfLines = 1
        nameTextField.textContainer.lineBreakMode = .byTruncatingMiddle
        phoneTextField.textContainer.maximumNumberOfLines = 1
        phoneTextField.textContainer.lineBreakMode = .byTruncatingMiddle
        zipCodeTextField.textContainer.maximumNumberOfLines = 1
        zipCodeTextField.textContainer.lineBreakMode = .byTruncatingMiddle
        faxTextField.textContainer.maximumNumberOfLines = 1
        faxTextField.textContainer.lineBreakMode = .byTruncatingMiddle
        websiteTextField.textContainer.maximumNumberOfLines = 1
        websiteTextField.textContainer.lineBreakMode = .byTruncatingMiddle
        street1TextField.textContainer.maximumNumberOfLines = 1
        street1TextField.textContainer.lineBreakMode = .byTruncatingMiddle
        street2TextField.textContainer.maximumNumberOfLines = 1
        street2TextField.textContainer.lineBreakMode = .byTruncatingMiddle
        cityTextField.textContainer.maximumNumberOfLines = 1
        cityTextField.textContainer.lineBreakMode = .byTruncatingMiddle
        stateTextField.textContainer.maximumNumberOfLines = 1
        stateTextField.textContainer.lineBreakMode = .byTruncatingMiddle
        countryTextField.textContainer.maximumNumberOfLines = 1
        countryTextField.textContainer.lineBreakMode = .byTruncatingMiddle
        
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
        
        self.setupData()
        self.doneEditingButton.isHidden = true
    }
    
    //**********************************************//
    //                                              //
    //  func:   viewWillAppear                      //
    //                                              //
    //  Desc:   On view appearance, if a table entry//
    //          is already selected, deselect it    //
    //                                              //
    //  args:   animated - Bool                     //
    //**********************************************//
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.contactsTable.indexPathForSelectedRow{
            self.contactsTable.deselectRow(at: index, animated: true)
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   tableView                           //
    //                                              //
    //  Desc:   Returns the number of entries to be //
    //          in the tableView based on the       //
    //          number of contacts to display       //
    //                                              //
    //  args:   tableView - UITableView             //
    //          section - Int                       //
    //**********************************************//
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactArray.count
    }
    
    //**********************************************//
    //                                              //
    //  func:   tableView                           //
    //                                              //
    //  Desc:   Returns the string to be used for   //
    //          the contacts tableView header       //
    //                                              //
    //  args:   tableView - UITableView             //
    //          section - Int                       //
    //**********************************************//
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Contacts:"
    }
    
    //**********************************************//
    //                                              //
    //  func:   tableView                           //
    //                                              //
    //  Desc:   Sets up each cell in the contact    //
    //          tableView with GUI stylings and     //
    //          contact information                 //
    //                                              //
    //  args:   tableView - UITableView             //
    //          indexPath - IndexPath               //
    //**********************************************//
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.contactsTable.separatorColor = UIColor.systemBlue
        self.contactsTable.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        let cell = self.contactsTable.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactsCell
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.fullNameTextField.text = contactArray[indexPath.row].first_name + " " + contactArray[indexPath.row].last_name
        return cell
    }
    
    //**********************************************//
    //                                              //
    //  func:   tableView                           //
    //                                              //
    //  Desc:   Performs a segue based on the       //
    //          tableView entry selected            //
    //                                              //
    //  args:   tableView - UITableView             //
    //          indexPath - IndexPath               //
    //**********************************************//
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedContact = contactArray[indexPath.row]
        rowSelected = indexPath.row
        self.performSegue(withIdentifier: "contactClickedSegue", sender: nil)
    }
    
    //**********************************************//
    //                                              //
    //  func:   prepare                             //
    //                                              //
    //  Desc:   Prepares data for certain segues    //
    //                                              //
    //  args:   segue - UIStoryboardSegue           //
    //          sender - Any                        //
    //**********************************************//
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "contactClickedSegue" {
            if let viewController = segue.destination as? SpecificContactViewController {
                //sets the delegate of the next controller to this controller
                viewController.contact = selectedContact
                viewController.contact_delegate = self
            }
        }
        else if segue.identifier == "createContactSegue" {
            if let viewController = segue.destination as? CreateContactViewController {
                //sets the delegate of the next controller to this controller
                viewController.account_id = account.id
                viewController.contact_delegate = self
            }
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   editClicked                         //
    //                                              //
    //  Desc:   Upon button press, make all Account //
    //          data fields editable and disable    //
    //          buttons the user should not access  //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func editClicked(_ sender: Any) {
        self.contactsTable.isUserInteractionEnabled = false
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        //Making all fields editable
        self.nameTextField.isEditable = true
        self.phoneTextField.isEditable = true
        self.faxTextField.isEditable = true
        self.zipCodeTextField.isEditable = true
        self.websiteTextField.isEditable = true
        self.street1TextField.isEditable = true
        self.street2TextField.isEditable = true
        self.cityTextField.isEditable = true
        self.stateTextField.isEditable = true
        self.countryTextField.isEditable = true
        
        //Changing colors of text fields to make them noticeable
        self.nameTextField.backgroundColor = UIColor.gray
        self.nameTextField.backgroundColor = UIColor.gray
        self.zipCodeTextField.backgroundColor = UIColor.gray
        self.zipCodeTextField.backgroundColor = UIColor.gray
        self.phoneTextField.backgroundColor = UIColor.gray
        self.faxTextField.backgroundColor = UIColor.gray
        self.websiteTextField.backgroundColor = UIColor.gray
        self.street1TextField.backgroundColor = UIColor.gray
        self.street2TextField.backgroundColor = UIColor.gray
        self.cityTextField.backgroundColor = UIColor.gray
        self.stateTextField.backgroundColor = UIColor.gray
        self.countryTextField.backgroundColor = UIColor.gray
        
        //Disabling buttons user should not be able to access
        self.deleteButton.isEnabled = false
        self.editButton.isEnabled = false
        self.doneEditingButton.isHidden = false
        self.doneEditingButton.isEnabled = true
        self.directionsButton.isEnabled = false
    }
    
    //**********************************************//
    //                                              //
    //  func:   deleteClicked                       //
    //                                              //
    //  Desc:   Attempts to delete the account upon //
    //          button press. If the account has a  //
    //          quote associated with it, deletion  //
    //          will fail. The user is then prompted//
    //          to confirm their decision and the   //
    //          deletion process begins             //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func deleteClicked(_ sender: Any) {
        let quoteArray = apiDispatcher.dispatcher.getAllQuotes(DESC: false)
        var accountInUse = false
        for element in quoteArray{
            if(element.account_id == account.id){
                accountInUse = true
            }
        }
        if(accountInUse){
            let alert = UIAlertController(title: "Unable to delete", message: "This account is currently being used in a quote.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            //Successful Change
            let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete \(account.name)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                let code = apiDispatcher.dispatcher.deleteAccount(id: self.account.id)
                if(code == 200){
                    //Set account for deletion on account view
                    self.account.name = ""
                    self.account_delegate?.passData(account: self.account, new: false)
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
    //  func:   doneEditingClicked                  //
    //                                              //
    //  Desc:   Attempts to submit changes to the   //
    //          edited account information. Cases   //
    //          exist for error checking and for    //
    //          light/dark mode support.            //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func doneEditingClicked(_ sender: Any) {
        if (!nameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty && !cityTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty && !stateTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty) {
            //Used to save current state of account if API doesn't update it
            let tempAccount = Account.init(name: account.name, state: account.state, city: account.city, country: account.country, street_1: account.street_1, street_2: account.street_2, postal_code: account.postal_code, fax: account.fax, phone: account.phone, website: account.website, id: account.id, created_at: account.modified_dates.created_at, updated_at: account.modified_dates.updated_at, group_id: account.group_id)
            account.name = self.nameTextField.text!
            account.phone = self.phoneTextField.text!
            account.fax = self.faxTextField.text!
            account.website = self.websiteTextField.text!
            account.street_1 = self.street1TextField.text!
            account.street_2 = self.street2TextField.text!
            account.city = self.cityTextField.text!
            account.state = self.stateTextField.text!
            account.country = self.countryTextField.text!
            account.postal_code = self.zipCodeTextField.text!
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            //If account was edited
            if(!account.equals(account: tempAccount)){
                let code = apiDispatcher.dispatcher.updateAccount(accountObj: account)
                if(code == 200){
                    account = apiDispatcher.dispatcher.getAccount(id: account.id)
                    account_delegate?.passData(account: account, new: false)
                    self.setupData()
                }
                else{
                    account = tempAccount
                    self.setupData()
                    let alert = UIAlertController(title: "Internal Server Error", message:
                        "Please try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            if traitCollection.userInterfaceStyle == .light {
                //For light mode
                self.nameTextField.backgroundColor = UIColor.white
                self.nameTextField.backgroundColor = UIColor.white
                self.phoneTextField.backgroundColor = UIColor.white
                self.faxTextField.backgroundColor = UIColor.white
                self.websiteTextField.backgroundColor = UIColor.white
                self.street1TextField.backgroundColor = UIColor.white
                self.street2TextField.backgroundColor = UIColor.white
                self.cityTextField.backgroundColor = UIColor.white
                self.stateTextField.backgroundColor = UIColor.white
                self.countryTextField.backgroundColor = UIColor.white
                self.zipCodeTextField.backgroundColor = UIColor.white
            }
            else {
                //For dark mode
                self.nameTextField.backgroundColor = UIColor.black
                self.nameTextField.backgroundColor = UIColor.black
                self.phoneTextField.backgroundColor = UIColor.black
                self.faxTextField.backgroundColor = UIColor.black
                self.websiteTextField.backgroundColor = UIColor.black
                self.street1TextField.backgroundColor = UIColor.black
                self.street2TextField.backgroundColor = UIColor.black
                self.cityTextField.backgroundColor = UIColor.black
                self.stateTextField.backgroundColor = UIColor.black
                self.countryTextField.backgroundColor = UIColor.black
                self.zipCodeTextField.backgroundColor = UIColor.black
            }
            
            self.nameTextField.isEditable = false
            self.phoneTextField.isEditable = false
            self.faxTextField.isEditable = false
            self.websiteTextField.isEditable = false
            self.street1TextField.isEditable = false
            self.street2TextField.isEditable = false
            self.cityTextField.isEditable = false
            self.zipCodeTextField.isEditable = false
            self.stateTextField.isEditable = false
            self.countryTextField.isEditable = false
            self.deleteButton.isEnabled = true
            self.editButton.isEnabled = true
            self.directionsButton.isEnabled = true
            self.doneEditingButton.isHidden = true
            self.doneEditingButton.isEnabled = false
            self.contactsTable.isUserInteractionEnabled = true
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
    
    //**********************************************//
    //                                              //
    //  func:   directionsClicked                   //
    //                                              //
    //  Desc:   Takes the user to apple maps to     //
    //          start driving to the address of     //
    //          street1                             //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    //Takes the user to apple maps to start driving to the address of street1
    @IBAction func directionsClicked(_ sender: Any) {
        let street = account.street_1.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let city = account.city.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let state = account.state.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let myAddress = "\(street),\(city),\(state)"
        if let url = URL(string:"http://maps.apple.com/?address=\(myAddress)") {
            UIApplication.shared.open(url)
        }
        else{
            let alert = UIAlertController(title: "Invalid Address", message:
                "The address on file seems to be invalid, please check these fields and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   setupData                           //
    //                                              //
    //  Desc:   Populates data fields with account  //
    //          info                                //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func setupData(){
        //Setting account data to text fields
        self.navigationTitle.title = account.name
        self.nameTextField.text = account.name
        self.phoneTextField.text = account.phone
        self.faxTextField.text = account.fax
        self.websiteTextField.text = account.website
        self.street1TextField.text = account.street_1
        self.street2TextField.text = account.street_2
        self.cityTextField.text = account.city
        self.stateTextField.text = account.state
        self.countryTextField.text = account.country
        self.zipCodeTextField.text = account.postal_code
    }
    
    //**********************************************//
    //                                              //
    //  func:   textView                            //
    //                                              //
    //  Desc:   Updates textView so long as the     //
    //          string is not a newline character   //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return text != "\n"
    }
    
    //**********************************************//
    //                                              //
    //  func:   traitCollectionDidChange            //
    //                                              //
    //  Desc:   If account info has changed, refresh//
    //          the displayed info.                 //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.userInterfaceStyle == .light {
            //For light mode
            self.nameTextField.backgroundColor = UIColor.white
            self.nameTextField.backgroundColor = UIColor.white
            self.phoneTextField.backgroundColor = UIColor.white
            self.faxTextField.backgroundColor = UIColor.white
            self.websiteTextField.backgroundColor = UIColor.white
            self.street1TextField.backgroundColor = UIColor.white
            self.street2TextField.backgroundColor = UIColor.white
            self.cityTextField.backgroundColor = UIColor.white
            self.stateTextField.backgroundColor = UIColor.white
            self.countryTextField.backgroundColor = UIColor.white
            self.zipCodeTextField.backgroundColor = UIColor.white
        }
        else {
            //For dark mode
            self.nameTextField.backgroundColor = UIColor.black
            self.nameTextField.backgroundColor = UIColor.black
            self.phoneTextField.backgroundColor = UIColor.black
            self.faxTextField.backgroundColor = UIColor.black
            self.websiteTextField.backgroundColor = UIColor.black
            self.street1TextField.backgroundColor = UIColor.black
            self.street2TextField.backgroundColor = UIColor.black
            self.cityTextField.backgroundColor = UIColor.black
            self.stateTextField.backgroundColor = UIColor.black
            self.countryTextField.backgroundColor = UIColor.black
            self.zipCodeTextField.backgroundColor = UIColor.black
        }
    }
}
