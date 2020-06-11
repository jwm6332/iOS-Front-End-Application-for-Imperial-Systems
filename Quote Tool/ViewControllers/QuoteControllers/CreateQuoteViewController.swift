//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   CreateQuoteViewController.swift //
//                                              //
//  Desc:       Search for file functionality   //
//                                              //
//  Creation:   03Mar20                         //
//**********************************************//

import UIKit

class CreateQuoteViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    //Variables and components
    @IBOutlet weak var createQuoteButton: UIButton!
    @IBOutlet weak var openSwitch: UISwitch!
    @IBOutlet weak var bundleSwitch: UISwitch!
    @IBOutlet weak var itemizeSwitch: UISwitch!
    @IBOutlet weak var commisionField: UITextField!
    @IBOutlet weak var multiplierField: UITextField!
    @IBOutlet weak var applicationField: UITextField!
    @IBOutlet weak var quoteNumberField: UITextField!
    @IBOutlet weak var AccountPicker: UIPickerView!
    @IBOutlet weak var ContactPicker: UIPickerView!
    
    var accounts = [Account]()
    var selectedItemsArray = [Contact]()
    var quote_delegate:QuoteProtocol?
    var quoteToSend = Quote()
    
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
        createQuoteButton.isEnabled = false
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        self.view.addSubview(activityIndicator)
        AccountPicker.delegate = self
        AccountPicker.dataSource = self
        ContactPicker.delegate = self
        ContactPicker.dataSource = self
        commisionField.delegate = self
        multiplierField.delegate = self
        quoteNumberField.delegate = self
        applicationField.delegate = self
        createQuoteButton.layer.cornerRadius = createQuoteButton.bounds.size.height/2
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .default).async {
            self.accounts = apiDispatcher.dispatcher.getAllAccounts(DESC: false)
            self.selectedItemsArray = apiDispatcher.dispatcher.getAllContactsForAccount(DESC: false, account_id: self.accounts[0].id)
            DispatchQueue.main.async { [weak self] in
                // UI updates must be on main thread
                if self?.selectedItemsArray.count == 0{
                    self?.createQuoteButton.isEnabled = false
                    self?.createQuoteButton.backgroundColor = UIColor.systemGray
                } else {
                    self?.createQuoteButton.isEnabled = true
                    self?.createQuoteButton.backgroundColor = UIColor.systemGreen
                }
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                self?.AccountPicker.reloadAllComponents()
                self?.ContactPicker.reloadAllComponents()
            }
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   textFieldShouldEndEditing           //
    //                                              //
    //  Desc:   Checks for valid numbers in         //
    //          multiplier and commision fields     //
    //                                              //
    //  args:   textField - UITextField             //
    //**********************************************//
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == commisionField {
            if (checkComission()){
                textField.textColor = UIColor.red
                return false
            }
            else {
                //Adjust look for light or dark mode
                if traitCollection.userInterfaceStyle == .light {
                    //For light mode
                    textField.textColor = UIColor.black
                }
                else {
                    //For dark mode
                    textField.textColor = UIColor.white
                }
                return true
            }
        }
        else if textField == multiplierField {
            if (checkMultiplier()){
                textField.textColor = UIColor.red
                return false
            }
            else {
                //Adjust look for light or dark mode
                if traitCollection.userInterfaceStyle == .light {
                    //For light mode
                    textField.textColor = UIColor.black
                }
                else {
                    //For dark mode
                    textField.textColor = UIColor.white
                }
                return true
            }
        }
        return true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if (checkComission()){
            commisionField.textColor = UIColor.red
        }
        else {
            //Adjust look for light or dark mode
            if traitCollection.userInterfaceStyle == .light {
                //For light mode
                commisionField.textColor = UIColor.black
            } else {
                //For dark mode
                commisionField.textColor = UIColor.white
            }
        }
        if (checkMultiplier()){
            multiplierField.textColor = UIColor.red
        }
        else {
            //Adjust look for light or dark mode
            if traitCollection.userInterfaceStyle == .light {
                //For light mode
                multiplierField.textColor = UIColor.black
            } else {
                //For dark mode
                multiplierField.textColor = UIColor.white
            }
        }
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    //Make pickers have one selection
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Set the number of rows for each picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == AccountPicker{
            return accounts.count
        } else if pickerView == ContactPicker{
            if selectedItemsArray.count > 0{
                    return selectedItemsArray.count
            } else {
                return 1
            }
        } else {
            return 0
        }
        
    }
    
    //Fill the pickers with data
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == AccountPicker{
            return accounts[row].name
        } else if pickerView == ContactPicker {
            if createQuoteButton.isEnabled {
                return selectedItemsArray[row].first_name + " " + selectedItemsArray[row].last_name
            } else {
                return "No Contacts For Account"
            }
        } else {
            return ""
        }
        
    }
    
    //Reload contact picker view after a new account is chosen
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == AccountPicker {
            selectedItemsArray = apiDispatcher.dispatcher.getAllContactsForAccount(DESC: false, account_id: accounts[row].id)
            if selectedItemsArray.count == 0 {
                createQuoteButton.isEnabled = false
                createQuoteButton.backgroundColor = UIColor.systemGray
            } else {
                createQuoteButton.isEnabled = true
                createQuoteButton.backgroundColor = UIColor.systemGreen
            }
            // IMPORTANT reload the data on the item picker
            ContactPicker.reloadAllComponents()
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   createQuoteSubmit                   //
    //                                              //
    //  Desc:   Attempts to create a quote using    //
    //          input from the GUI. Populates alerts//
    //          if any errors occur                 //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func createQuoteSubmit(_ sender: Any) {
        if quoteNumberField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            let alert = UIAlertController(title: "Quote Number is Empty", message:
                "Quote number field cannot be empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
        else if checkComission() || checkMultiplier() {
            let alert = UIAlertController(title: "Invalid Numbers", message:
                "Please check that: \n- Multiplier is greater than zero and less than or equal to 1\n- Commission does not exceed 100", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let newQuote = Quote.init(account_id: accounts[AccountPicker.selectedRow(inComponent: 0)].id, commission: Double(commisionField.text!)!, quote_number: quoteNumberField.text!, multiplier: Double(multiplierField.text!)!, contact_id: selectedItemsArray[ContactPicker.selectedRow(inComponent: 0)].id, application: applicationField.text!, list_prices: bundleSwitch.isOn, open: openSwitch.isOn, created_date: "", updated_date: "", id: 0, lead_time: "", sell_price: 0.00, net_imperial: 0.00)
            let id = apiDispatcher.dispatcher.postNewQuote(quote: newQuote!)
            if id == 0 {
                let alert = UIAlertController(title: "Error", message:
                    "A new quote could not be made at this time. Please try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                let quote = apiDispatcher.dispatcher.getQuote(quote_id: id)
                quoteToSend = quote
                self.navigationController?.popViewController(animated: true)
                quote_delegate?.passQuote(quote: quote, new: true)
            }
        }
    }
    
    
    func checkComission() -> Bool {
        //True means bad numbers
        var flag: Bool = false
        if let num2 = Double(commisionField.text!){
            if (num2 > 100 || num2 < 0){
                flag = true
            }
        }
        else {
            flag = true
        }
        return flag
    }
    
    func checkMultiplier() -> Bool {
        var flag: Bool = false
        if let number = Double(multiplierField.text!){
            if number <= 0 || number > 1.00 {
                flag = true;
            }
        }
        else {
            flag = true;
        }
        return flag
    }
    
    //**********************************************//
    //                                              //
    //  func:   textField                           //
    //                                              //
    //  Desc:   Controls what is being entered into //
    //          the multiplier and commision text   //
    //          fields.                             //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == multiplierField){
            guard let oldText = textField.text, let r = Range(range, in: oldText) else {
                return true
            }
            
            let newText = oldText.replacingCharacters(in: r, with: string)
            let isNumeric = newText.isEmpty || (Double(newText) != nil)
            let numberOfDots = newText.components(separatedBy: ".").count - 1
            
            let numberOfDecimalDigits: Int
            if let dotIndex = newText.firstIndex(of: ".") {
                numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
            } else {
                numberOfDecimalDigits = 0
            }
            
            return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 3
        }
        else if (textField == commisionField){
            guard let oldText = textField.text, let r = Range(range, in: oldText) else {
                return true
            }
            
            let newText = oldText.replacingCharacters(in: r, with: string)
            let isNumeric = newText.isEmpty || (Double(newText) != nil)
            let numberOfDots = newText.components(separatedBy: ".").count - 1
            
            let numberOfDecimalDigits: Int
            if let dotIndex = newText.firstIndex(of: ".") {
                numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
            } else {
                numberOfDecimalDigits = 0
            }
            return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 1
        }
        else{
            return true
        }
    }
    
}
