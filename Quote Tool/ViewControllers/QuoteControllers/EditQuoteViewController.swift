//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   EditQuoteViewController.swift   //
//                                              //
//  Desc:       Search for file functionality   //
//                                              //
//  Creation:   03Mar20                         //
//**********************************************//

import UIKit

class EditQuoteViewController: UIViewController, UITextFieldDelegate {
    
    var quote = Quote()
    var quote_delegate:QuoteProtocol?
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var openSwitch: UISwitch!
    @IBOutlet weak var quoteNumberTextField: UITextField!
    @IBOutlet weak var applicationTextField: UITextField!
    @IBOutlet weak var multiplierTextField: UITextField!
    @IBOutlet weak var commissionTextField: UITextField!
    @IBOutlet weak var itemizeSwitch: UISwitch!
    @IBOutlet weak var listBundleTotalsSwitch: UISwitch!
    @IBOutlet weak var Activity: UIActivityIndicatorView!
    
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
        multiplierTextField.delegate = self
        commissionTextField.delegate = self
        updateButton.layer.cornerRadius = updateButton.bounds.size.height/2
        Activity.center = self.view.center
        Activity.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        setupData()
    }
    
    //Check for valid numbers in commision and multiplier field
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == commissionTextField {
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
        else if textField == multiplierTextField {
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
            commissionTextField.textColor = UIColor.red
        }
        else {
            //Adjust look for light or dark mode
            if traitCollection.userInterfaceStyle == .light {
                //For light mode
                commissionTextField.textColor = UIColor.black
            } else {
                //For dark mode
                commissionTextField.textColor = UIColor.white
            }
        }
        if (checkMultiplier()){
            multiplierTextField.textColor = UIColor.red
        }
        else {
            //Adjust look for light or dark mode
            if traitCollection.userInterfaceStyle == .light {
                //For light mode
                multiplierTextField.textColor = UIColor.black
            } else {
                //For dark mode
                multiplierTextField.textColor = UIColor.white
            }
        }
    }
    
    func checkComission() -> Bool {
        //True means bad numbers
        var flag: Bool = false
        if let num2 = Double(commissionTextField.text!){
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
        if let number = Double(multiplierTextField.text!){
            if number <= 0 || number > 1.00 {
                flag = true;
            }
        }
        else {
            flag = true;
        }
        return flag
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == multiplierTextField){
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
        else if (textField == commissionTextField){
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    //**********************************************//
    //                                              //
    //  func:   updateClicked                       //
    //                                              //
    //  Desc:   Attempts to update the Quote's info //
    //          using data input from the GUI       //
    //          elements. Performs error checking   //
    //          to avoid poor data input            //
    //                                              //
    //  args:                                       //
    //**********************************************//
    @IBAction func updateClicked(_ sender: Any) {
        if quoteNumberTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty{
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
            //Used to save current state of account if API doesn't update it
            let tempQuote = Quote.init()
            tempQuote.account_id = quote.account_id
            tempQuote.account_name = quote.account_name
            tempQuote.application = quote.application
            tempQuote.commission = quote.commission
            tempQuote.contact_id = quote.contact_id
            tempQuote.contact_name = quote.contact_name
            tempQuote.id = quote.id
            tempQuote.lead_time = quote.lead_time
            tempQuote.list_prices = quote.list_prices
            tempQuote.multiplier = quote.multiplier
            tempQuote.net_imperial = quote.net_imperial
            tempQuote.open = quote.open
            tempQuote.quote_number = quote.quote_number
            tempQuote.modified_dates = quote.modified_dates
            quote.quote_number = quoteNumberTextField.text
            quote.application = applicationTextField.text ?? ""
            quote.multiplier = Double(multiplierTextField.text!)
            quote.commission = Double(commissionTextField.text!)
            quote.open = openSwitch.isOn
            quote.list_prices = listBundleTotalsSwitch.isOn
            Activity.startAnimating()
            DispatchQueue.global(qos: .default).async {
                if(!self.quote.equals(quote: tempQuote)){
                    let code = apiDispatcher.dispatcher.updateQuote(quote: self.quote)
                    if(code == 200){
                        self.quote = apiDispatcher.dispatcher.getQuote(quote_id: self.quote.id)
                        DispatchQueue.main.async {
                            self.Activity.stopAnimating()
                            self.quote_delegate?.passQuote(quote: self.quote, new: false)
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.Activity.stopAnimating()
                            self.quote = tempQuote
                            self.setupData()
                            let alert = UIAlertController(title: "Internal Server Error", message:
                                "Please try again later.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.Activity.stopAnimating()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   deleteClicked                       //
    //                                              //
    //  Desc:   Attempts Quote deletion. Populates  //
    //          an alert if an error occurred       //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func deleteClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete \(quote.quote_number!)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            let code = apiDispatcher.dispatcher.deleteQuote(id: self.quote.id)
            if(code == 200){
                //Set account for deletion on account view
                self.quote.id = 0
                self.quote_delegate?.passQuote(quote: self.quote, new: false)
                self.navigationController?.popToRootViewController(animated: true)
            }
            else{
                let alert = UIAlertController(title: "Error", message: "There was an error deleting that account. Try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func setupData(){
        commissionTextField.text = String(quote.commission)
        multiplierTextField.text = String(quote.multiplier)
        applicationTextField.text = quote.application
        quoteNumberTextField.text = quote.quote_number
        openSwitch.isOn = quote.open
        listBundleTotalsSwitch.isOn = quote.list_prices
    }
}
