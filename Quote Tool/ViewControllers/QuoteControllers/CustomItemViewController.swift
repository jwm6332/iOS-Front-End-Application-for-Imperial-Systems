//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   CustomItemViewController.swift  //
//                                              //
//  Desc:       Search for file functionality   //
//                                              //
//  Creation:   03Mar20                         //
//**********************************************//

import UIKit

class CustomItemViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var listPriceField: UITextField!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var optionSwitch: UISwitch!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var quantity: Int = 1
    var quote = Quote() //Needed for sell price calculation
    var quoteItem = QuoteItem()
    var addQuoteItem_delegate: addQuoteItemProtocol?
    var quote_delegate: QuoteProtocol?
    
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
        quantityField.delegate = self
        listPriceField.delegate = self
        nameField.delegate = self
        createButton.layer.cornerRadius = createButton.bounds.size.height/2
        activityIndicator.center = self.view.center
        activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        optionSwitch.isOn = false
        listPriceField.text = "0.00"
        quantityField.text = "1"
        self.descriptionField.text = "Sample Description Text"
    }
    
    //Change the quantity in the cell_array when the cell is done editing the quantity text field
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField == quantityField {
            if(textField.text == "" || textField.text == "0"){
                textField.text = "1"
            }
            quantity = Int(textField.text!) ?? 1
            let intermediate = (quote.multiplier / ((100.0 - quote.commission)/100.0))
            let sell_price = (Double(listPriceField.text!)! * Double(quantity)) * intermediate
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            if let formatted_price = formatter.string(from: sell_price as NSNumber) {
                self.priceLabel.text = formatted_price
            }
        }
        else if textField == listPriceField {
            if(listPriceField.text == ""){
                listPriceField.text = "0.00"
            }
            let intermediate = (quote.multiplier / ((100.0 - quote.commission)/100.0))
            let sell_price = (Double(textField.text!)! * Double(quantity)) * intermediate
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            if let formatted_price = formatter.string(from: sell_price as NSNumber) {
                self.priceLabel.text = formatted_price
            }
        }
        else if textField == nameField {
            if(nameField.text == ""){
                nameField.text = "New Quote Item"
            }
        }
    }
    
    //When the cells quantity text field is editing don't allow more than three digits
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == quantityField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= 3
        }
        else if(textField == listPriceField){
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
    //  func:   createClicked                       //
    //                                              //
    //  Desc:   Attempts to create the quote_item   //
    //          with input data from GUI elements.  //
    //          Populates an alert if error occurs  //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func createClicked(_ sender: Any) {
        let customQuoteItem = QuoteItem()
        customQuoteItem.quantity = Int(quantityField.text ?? "") ?? 1
        customQuoteItem.name = nameField.text ?? ""
        customQuoteItem.option = optionSwitch.isOn
        customQuoteItem.description = descriptionField.text
        customQuoteItem.price = Double(listPriceField.text ?? "") ?? 0.00
        customQuoteItem.bundle_id = quoteItem.bundle_id
        customQuoteItem.bundle_position = -1    //Adds to the beginning of the list so if the list is long they can see the new item added, sorting algorithm will re-assign this to 0 and fix all others
        customQuoteItem.id = 0
        customQuoteItem.model = quoteItem.model
        customQuoteItem.active = quoteItem.active
        customQuoteItem.category = quoteItem.category
        customQuoteItem.product_id = quoteItem.product_id
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .default).async {
            let tempID = apiDispatcher.dispatcher.postNewQuoteItem(quote_item: customQuoteItem)
            let tempQIGrab = apiDispatcher.dispatcher.getQuoteItem(quote_item_id: tempID)
            self.quote = apiDispatcher.dispatcher.getQuote(quote_id: self.quote.id)
            DispatchQueue.main.async {
                // UI updates must be on main thread
                self.activityIndicator.stopAnimating()
                if(tempQIGrab.name == customQuoteItem.name){
                    self.quote_delegate?.passQuote(quote: self.quote, new: false)
                    self.addQuoteItem_delegate?.addQuoteItem(quoteItem: tempQIGrab)
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    let alert = UIAlertController(title: "Quote Item Creation Error", message:
                        "The quote item could not be created at this time. Please try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
}
