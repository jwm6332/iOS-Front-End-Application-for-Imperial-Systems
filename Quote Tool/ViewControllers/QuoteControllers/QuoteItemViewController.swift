//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   QuoteItemViewController.swift   //
//                                              //
//  Desc:       Search for file functionality   //
//                                              //
//  Creation:   03Mar20                         //
//**********************************************//

import UIKit

class QuoteItemViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var listPriceTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var optionSwitch: UISwitch!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sellPriceTextField: UILabel!
    
    var quote = Quote()
    var quoteItem = QuoteItem()
    var quoteItem_delegate:quoteItemProtocol?
    var quote_delegate:QuoteProtocol?
    var quantity: Int = 0
    
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
        quantityTextField.delegate = self
        listPriceTextField.delegate = self
        nameTextField.delegate = self
        updateButton.layer.cornerRadius = updateButton.bounds.size.height/2
        let intermediate = (quote.multiplier / ((100.0 - quote.commission)/100.0))
        let sell_price = (quoteItem.price * Double(quoteItem.quantity)) * intermediate
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let formatted_price = formatter.string(from: sell_price as NSNumber) {
            self.sellPriceTextField.text = formatted_price
        }
        activityIndicator.center = self.view.center
        activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        self.nameTextField.text = quoteItem.name
        self.listPriceTextField.text = String(quoteItem.price)
        self.quantityTextField.text = String(quoteItem.quantity)
        quantity = quoteItem.quantity
        self.optionSwitch.isOn = quoteItem.option
        self.descriptionTextView.text = quoteItem.description
    }
    
    //Change the quantity in the cell_array when the cell is done editing the quantity text field
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField == quantityTextField {
            if(textField.text == "" || textField.text == "0"){
                textField.text = "1"
            }
            quantity = Int(textField.text!) ?? 1
            let intermediate = (quote.multiplier / ((100.0 - quote.commission)/100.0))
            let sell_price = (Double(listPriceTextField.text!)! * Double(quantity)) * intermediate
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            if let formatted_price = formatter.string(from: sell_price as NSNumber) {
                self.sellPriceTextField.text = formatted_price
            }
        }
        else if textField == listPriceTextField {
            if(listPriceTextField.text == ""){
                listPriceTextField.text = "0.00"
            }
            let intermediate = (quote.multiplier / ((100.0 - quote.commission)/100.0))
            let sell_price = (Double(textField.text!)! * Double(quantity)) * intermediate
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            if let formatted_price = formatter.string(from: sell_price as NSNumber) {
                self.sellPriceTextField.text = formatted_price
            }
        }
        else if textField == nameTextField {
            if(nameTextField.text == ""){
                nameTextField.text = quoteItem.name
            }
        }
    }
    
    //When the cells quantity text field is editing don't allow more than three digits
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == quantityTextField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= 3
        }
        else if(textField == listPriceTextField){
            guard let oldText = textField.text, let r = Range(range, in: oldText) else {
                return true
            }
            let newText = oldText.replacingCharacters(in: r, with: string)
            let isNumeric = newText.isEmpty || (Double(newText) != nil)
            let numberOfDots = newText.components(separatedBy: ".").count - 1
            let needle: Character = "."
            var isPrecise: Int = 0
            if let idx = newText.firstIndex(of: needle) {
                isPrecise = newText.distance(from: idx, to: newText.endIndex)
            }
            return isNumeric && numberOfDots <= 1 && isPrecise <= 3
        }
        else{
            return true
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   updateClicked                       //
    //                                              //
    //  Desc:   Attempts to update the quote_item   //
    //          with input data from GUI elements.  //
    //          Populates an alert if error occurs  //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func updateClicked(_ sender: Any) {
        quoteItem.quantity = Int(quantityTextField.text ?? "") ?? 1
        quoteItem.name = self.nameTextField.text ?? ""
        quoteItem.option = self.optionSwitch.isOn
        quoteItem.description = self.descriptionTextView.text
        quoteItem.price = Double(self.listPriceTextField.text ?? "") ?? 0.00
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .default).async {
            let code = apiDispatcher.dispatcher.updateQuoteItem(quote_item: self.quoteItem)
            self.quote = apiDispatcher.dispatcher.getQuote(quote_id: self.quote.id)
            DispatchQueue.main.async {
                // UI updates must be on main thread
                self.activityIndicator.stopAnimating()
                if(code == 200){
                    self.quoteItem_delegate?.passQuoteItems(quoteItem: self.quoteItem)
                    //Updates prices on the QuoteViwController by refreshing the entire view
                    self.quote_delegate?.passQuote(quote: self.quote, new: false)
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    let alert = UIAlertController(title: "Quote Item Update Error", message:
                        "The quote item could not be updated at this time. Please try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
}
