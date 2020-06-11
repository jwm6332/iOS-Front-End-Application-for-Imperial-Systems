/*
 Info about this controller:
 The reason there are several protocols communicating between the main class and the AddersCell class is to keep
 consistency between them. When a cell is scrolled out of view it is deleted from memory, so all the cells info is stored in
 the cell_array in the main class. When the cell comes back into view it is repopulated with the information given from before.
 */
//**************************************************//
//          Imperial Systems Inc.                   //
//**************************************************//
//                                                  //
//  Filename:   SpecificProductViewController.swift //
//                                                  //
//  Desc:       Search for file functionality       //
//                                                  //
//  Creation:   03Mar20                             //
//**************************************************//

import UIKit

//Protocol for changing the array in the main viewcontroller to reflect button selections
protocol OptionsProtocol {
    func changeOptionValue(option: Int, section: Int, row: Int)
}

//Protocol for making sure buttons remain in the correct position and quantites are correct
protocol Consistency {
    func buttonCheck(option: Int, quantity: Int, base: Bool)
}

//Protocol for sending quantities to the cell_array in the main class from the cells class
protocol Quantities {
    func changeQuantity(quantity: Int, section: Int, row: Int)
}

//Structure for holding all the cells information
struct cell {
    var buttonSelected: Int = 0
    var quantity: Int = 1
    var price: Double = 0.00
    var first: Bool = true
}

extension UITextView {
    
    //Used to center the textViews within the cells to the center of the height
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}

class AddersCell: UITableViewCell, UITextFieldDelegate, Consistency {
    
    //When cell comes back into view make sure the previous data is displayed
    func buttonCheck(option: Int, quantity: Int, base: Bool) {
        if(base){
            excludeButton.isHidden = true
            excludeButton.isEnabled = false
        }
        else{
            excludeButton.isHidden = false
            excludeButton.isEnabled = true
        }
        //Exclude button was selected
        if(option == 0 && !base){
            excludeButton.isSelected = true
            excludeButton.backgroundColor = UIColor.systemGreen
            addToQuoteButton.backgroundColor = UIColor.lightGray
            addAsOptionButton.backgroundColor = UIColor.lightGray
        }
            //Add to Quote button was selected
        else if(option == 1){
            addToQuoteButton.isSelected = true
            excludeButton.backgroundColor = UIColor.lightGray
            addToQuoteButton.backgroundColor = UIColor.systemGreen
            addAsOptionButton.backgroundColor = UIColor.lightGray
        }
            //Add as option was selected
        else {
            addAsOptionButton.isSelected = true
            excludeButton.backgroundColor = UIColor.lightGray
            addToQuoteButton.backgroundColor = UIColor.lightGray
            addAsOptionButton.backgroundColor = UIColor.systemGreen
        }
        //Set the correct quantity as given from before
        self.numberTextField.text = String(quantity)
    }
    
    var options_delegate: OptionsProtocol?
    var quantity_delegate: Quantities?
    var section: Int = 0
    var row: Int = 0
    var option: Int = 0
    var base: Bool = false
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var adderTitleTextField: UITextView!
    @IBOutlet weak var excludeButton: UIButton!
    @IBOutlet weak var addToQuoteButton: UIButton!
    @IBOutlet weak var addAsOptionButton: UIButton!
    
    //If the any of the buttons are clicked within a cell
    
    //**********************************************//
    //                                              //
    //  func:   excludeClicked                      //
    //                                              //
    //  Desc:   updates the quote_item's optional   //
    //          field in the quote to exclude the   //
    //          quote_item                          //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func excludeClicked(_ sender: Any) {
        option = 0
        options_delegate?.changeOptionValue(option: option, section: section, row: row)
        excludeButton.backgroundColor = UIColor.systemGreen
        addToQuoteButton.backgroundColor = UIColor.lightGray
        addAsOptionButton.backgroundColor = UIColor.lightGray
    }
    
    //**********************************************//
    //                                              //
    //  func:   addToQuoteClicked                   //
    //                                              //
    //  Desc:   updates the quote_item's optional   //
    //          field in the quote to include the   //
    //          quote_item                          //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func addToQuoteClicked(_ sender: Any) {
        option = 1
        options_delegate?.changeOptionValue(option: option, section: section, row: row)
        excludeButton.backgroundColor = UIColor.lightGray
        addToQuoteButton.backgroundColor = UIColor.systemGreen
        addAsOptionButton.backgroundColor = UIColor.lightGray
    }
    
    //**********************************************//
    //                                              //
    //  func:   addAsOptionClicked                  //
    //                                              //
    //  Desc:   updates the quote_item's optional   //
    //          field in the quote to include the   //
    //          quote_item as an option             //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func addAsOptionClicked(_ sender: Any) {
        option = 2
        options_delegate?.changeOptionValue(option: option, section: section, row: row)
        excludeButton.backgroundColor = UIColor.lightGray
        addToQuoteButton.backgroundColor = UIColor.lightGray
        addAsOptionButton.backgroundColor = UIColor.systemGreen
    }
    
    //Change the quantity in the cell_array when the cell is done editing the quantity text field
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField == numberTextField {
            if(textField.text == "" || textField.text == "0" || Int(textField.text ?? "") ?? 0 <= 0){
                textField.text = "1"
            }
            let quantity = Int(textField.text ?? "") ?? 1
            quantity_delegate?.changeQuantity(quantity: quantity, section: section, row: row)
        }
    }
    
    //When the cells quantity text field is editing don't allow more than three digits
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == numberTextField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= 3
        }
        else{
            return true
        }
    }
}

class SpecificProductViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, OptionsProtocol, Quantities {
    
    @IBOutlet weak var addersTable: UITableView!
    //Variables used only when coming from the edit bundle view
    var edit: Bool = false
    var bundle_id: Int = 0
    var quoteItemsFromBundle = [QuoteItem]()
    var startValues = [[Int]]()
    var startQuantities = [[Int]]()
    
    //Protocol delegates
    var consistency_delegate: Consistency?
    var bundle_delegate:BundleProtocol?
    var quote = Quote() //Given by previous controllers so we know what quote we're adding to
    var cell_array = [[cell]]() //Holds cell information
    var product = Product() //Holds the current products information
    var make : String = ""  //Is given by previous controller
    var adder_array = [[Product]]() //Holds all adder information
    var price_num: String = ""  //Holds the price value of the current product
    var quote_delegate:QuoteProtocol?
    
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var Activity: UIActivityIndicatorView!
    @IBOutlet weak var product_image: UIImageView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    //**********************************************//
    //                                              //
    //  func:   viewDidLoad                         //
    //                                              //
    //  Desc:   Function that takes care of         //
    //          initializing the view and all of its//
    //          components. Many styling adjustments//
    //          exist here. Does heavy work to      //
    //          populate the dynamic quote_item list//
    //                                              //
    //  args:                                       //
    //**********************************************//
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addersTable.delegate = self
        self.addersTable.dataSource = self
        if(edit){
            navigationItem.rightBarButtonItem?.title = "Update"
        }
        self.navigationItem.title = product.name
        Activity.center = self.view.center
        Activity.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        //self.descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.descriptionTextView.layer.borderWidth = 1
        //Check if there is a description
        if(product.description != ""){
            descriptionTextView.text = product.description
        }
        
        //Set the image of the product on the main screen
        if product.image != "" {
            let url = URL(string: product.image)
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url!) { //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        self.product_image.image = UIImage(data: data)
                    }
                }
            }
        }
        else{
            DispatchQueue.main.async {
                self.product_image.image = UIImage(named: "default_image")
            }
        }
        Activity.startAnimating()
        //Get the adders for the product
        DispatchQueue.global(qos: .default).async {
            self.adder_array = apiDispatcher.dispatcher.getProductAdders(DESC: false, product_id: self.product.product_id, make: self.make)
            
            //For knowing which buttons were pressed on each cell
            for i in 0..<self.adder_array.count {
                let cell1 = [cell]()
                self.cell_array.append(cell1)
                for _ in 0..<self.adder_array[i].count {
                    let cell2 = cell()
                    self.cell_array[i].append(cell2)
                }
            }
            
            //Get price for main product
            let tag_array = apiDispatcher.dispatcher.getTagsForProduct(DESC: false, product_id: self.product.product_id)
            var found: Bool = false
            for element in tag_array{
                if element.category == "price" && element.name == "\(self.product.name)"{
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    if let formatted_price = formatter.string(from: Double(element.value)! as NSNumber) {
                        self.price_num = formatted_price
                    }
                    found = true
                    break
                }
            }
            if !found {
                self.price_num = "$0.00"
            }
            
            //Used for getting adder prices
            for i in 0..<self.adder_array.count {
                for j in 0..<self.adder_array[i].count {
                    //Get the specific adders tags through its product_id
                    let tagTemp = apiDispatcher.dispatcher.getTagsForProduct(DESC: false, product_id: self.adder_array[i][j].product_id)
                    //Search through the tag array to find the tag for price
                    for element in tagTemp {
                        if(element.name == self.product.name && element.category == "price"){
                            //If found add to the tag array in the appropraite section
                            self.cell_array[i][j].price = Double(element.value) ?? 0.00
                        }
                    }
                }
            }
            
            if(self.edit){
                for i in 0..<self.adder_array.count {
                    let start_vals = [Int]()
                    self.startValues.append(start_vals)
                    self.startQuantities.append(start_vals)
                    for j in 0..<self.adder_array[i].count {
                        self.startQuantities[i].append(1)
                        self.startValues[i].append(0)
                        for element in self.quoteItemsFromBundle {
                            if element.name == self.adder_array[i][j].name {
                                if(element.option){
                                    self.startValues[i][j] = 2
                                    self.cell_array[i][j].buttonSelected = 2
                                }
                                else{
                                    self.startValues[i][j] = 1
                                    self.cell_array[i][j].buttonSelected = 1
                                }
                                self.cell_array[i][j].quantity = element.quantity
                                self.startQuantities[i][j] = element.quantity
                                break
                            }
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                // UI updates must be on main thread
                self.price.text = self.price_num
                self.Activity.stopAnimating()
                self.addersTable.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adder_array[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 117
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.addersTable.separatorColor = UIColor.systemBlue
        self.addersTable.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        let cell = self.addersTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AddersCell
        cell.options_delegate = self
        cell.quantity_delegate = self
        consistency_delegate = cell
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.numberTextField.delegate = cell
        cell.addAsOptionButton.layer.cornerRadius = cell.addAsOptionButton.bounds.size.height/2
        cell.addToQuoteButton.layer.cornerRadius = cell.addToQuoteButton.bounds.size.height/2
        cell.excludeButton.layer.cornerRadius = cell.excludeButton.layer.frame.height / 2
        cell.excludeButton.layer.masksToBounds = true
        cell.addToQuoteButton.layer.masksToBounds = true
        cell.addAsOptionButton.layer.masksToBounds = true
        cell.adderTitleTextField.text = adder_array[indexPath.section][indexPath.row].name
        if UIDevice.current.userInterfaceIdiom == .pad {
            cell.adderTitleTextField.textAlignment = .center
        }
        else {
            cell.adderTitleTextField.centerVertically()
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let formatted_price = formatter.string(from: cell_array[indexPath.section][indexPath.row].price as NSNumber) {
            cell.priceLabel.text = formatted_price
        }
        cell.section = indexPath.section
        cell.row = indexPath.row
        var base: Bool = false
        if(!edit){
            //If it is the base object
            if(adder_array[indexPath.section][indexPath.row].category == "base"){
                base = true
                //If it is the first time creating the base cell
                if(cell_array[indexPath.section][indexPath.row].first){
                    //Select add to quote
                    cell_array[indexPath.section][indexPath.row].buttonSelected = 1
                    //Don't run this again, so we don't override a different selection
                    cell_array[indexPath.section][indexPath.row].first = false
                }
            }
        }
        consistency_delegate?.buttonCheck(option: cell_array[indexPath.section][indexPath.row].buttonSelected, quantity: cell_array[indexPath.section][indexPath.row].quantity, base: base)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return adder_array[section][0].category
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return adder_array.count
    }
    
    //**********************************************//
    //                                              //
    //  func:   submitClicked                       //
    //                                              //
    //  Desc:   Most of the work to create a bundle //
    //          with quote items occurs here. This  //
    //          attempts to add a new bundle with   //
    //          its associated quote_items from the //
    //          info entered in the dynamically     //
    //          populated list of quote_items.      //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func submitClicked(_ sender: Any) {
        var count: Int = 0  //For keeping track of quote item positions inside the new bundle
        Activity.center = self.view.center
        Activity.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        Activity.startAnimating()
        if(!edit){
            DispatchQueue.global(qos: .default).async {
                let new_bundle = Bundle.init(name: self.product.name, quote_id: self.quote.id, option: false, quote_position: -1)
                let bundle_id = apiDispatcher.dispatcher.postNewBundle(bundleObj: new_bundle)
                //If there is no internet or general server side error
                if(bundle_id == 0){
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "There was an error adding the bundle. Please try again later.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                }
                new_bundle.id = bundle_id
                for i in 0..<self.adder_array.count {
                    for j in 0..<self.adder_array[i].count {
                        //If adder is selected to be added to the quote
                        if(self.cell_array[i][j].buttonSelected == 1 && self.cell_array[i][j].quantity > 0){
                            let quote_item = QuoteItem.init(id: 0, quantity: self.cell_array[i][j].quantity, bundle_id: bundle_id, model: self.product.name, price: self.cell_array[i][j].price, option: false, bundle_position: count, product_id: self.product.product_id, active: self.product.active, category: self.product.category, description: self.product.description, digest_id: self.product.digest_id, image: self.product.image, lead_time: self.product.lead_time, make: self.product.make, name: self.adder_array[i][j].name, sku: self.product.sku, updated_at: self.product.modified_dates.updated_at, created_at: self.product.modified_dates.created_at)
                            let quote_item_id = apiDispatcher.dispatcher.postNewQuoteItem(quote_item: quote_item)
                            //If there is no internet or general server side error
                            if(quote_item_id == 0){
                                DispatchQueue.main.async {
                                    let alert = UIAlertController(title: "Error", message: "There was an error adding the quote item: \(self.adder_array[i][j].name). Please try again later.", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                    return
                                }
                            }
                        }
                            //If adder is selected to be added as option
                        else if(self.cell_array[i][j].buttonSelected == 2 && self.cell_array[i][j].quantity > 0){
                            let quote_item = QuoteItem.init(id: 0, quantity: self.cell_array[i][j].quantity, bundle_id: bundle_id, model: self.product.name, price: self.cell_array[i][j].price, option: true, bundle_position: count, product_id: self.product.product_id, active: self.product.active, category: self.product.category, description: self.product.description, digest_id: self.product.digest_id, image: self.product.image, lead_time: self.product.lead_time, make: self.product.make, name: self.adder_array[i][j].name, sku: self.product.sku, updated_at: self.product.modified_dates.updated_at, created_at: self.product.modified_dates.created_at)
                            let quote_item_id = apiDispatcher.dispatcher.postNewQuoteItem(quote_item: quote_item)
                            //If there is no internet or general server side error
                            if(quote_item_id == 0){
                                DispatchQueue.main.async {
                                    // UI updates must be on main thread
                                    let alert = UIAlertController(title: "Error", message: "There was an error adding the quote item: \(self.adder_array[i][j].name). Please try again later.", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                    return
                                }
                            }
                        }
                        count += 1
                    }
                }
                self.quote = apiDispatcher.dispatcher.getQuote(quote_id: self.quote.id)
                DispatchQueue.main.async {
                    // UI updates must be on main thread
                    //Updates prices on the QuoteViwController by refreshing the entire view
                    self.quote_delegate?.passQuote(quote: self.quote, new: false)
                    //Finds the SpecificQuoteViewController and pops all views off the stack to get to it
                    self.bundle_delegate?.passBundle(bundle: new_bundle, new: true)
                    for controller in self.navigationController!.viewControllers as Array {
                        if controller.isKind(of: SpecificQuoteViewController.self) {
                            self.navigationController!.popToViewController(controller, animated: true)
                            break
                        }
                    }
                    self.Activity.stopAnimating()
                }
            }
        }
            //Editing
        else{
            for i in 0..<self.cell_array.count {
                for j in 0..<self.cell_array[i].count {
                    if cell_array[i][j].buttonSelected != startValues[i][j] {
                        if(startValues[i][j] == 0){
                            //If adder is selected to be added to the quote
                            if(self.cell_array[i][j].buttonSelected == 1 && self.cell_array[i][j].quantity > 0){
                                let quote_item = QuoteItem.init(id: 0, quantity: self.cell_array[i][j].quantity, bundle_id: bundle_id, model: self.product.name, price: self.cell_array[i][j].price, option: false, bundle_position: count, product_id: self.product.product_id, active: self.product.active, category: self.product.category, description: self.product.description, digest_id: self.product.digest_id, image: self.product.image, lead_time: self.product.lead_time, make: self.product.make, name: self.adder_array[i][j].name, sku: self.product.sku, updated_at: self.product.modified_dates.updated_at, created_at: self.product.modified_dates.created_at)
                                let quote_item_id = apiDispatcher.dispatcher.postNewQuoteItem(quote_item: quote_item)
                                //If there is no internet or general server side error
                                if(quote_item_id == 0){
                                    DispatchQueue.main.async {
                                        let alert = UIAlertController(title: "Error", message: "There was an error adding the quote item: \(self.adder_array[i][j].name). Please try again later.", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                        return
                                    }
                                }
                            }
                                //If adder is selected to be added as option
                            else if(self.cell_array[i][j].buttonSelected == 2 && self.cell_array[i][j].quantity > 0){
                                let quote_item = QuoteItem.init(id: 0, quantity: self.cell_array[i][j].quantity, bundle_id: bundle_id, model: self.product.name, price: self.cell_array[i][j].price, option: true, bundle_position: count, product_id: self.product.product_id, active: self.product.active, category: self.product.category, description: self.product.description, digest_id: self.product.digest_id, image: self.product.image, lead_time: self.product.lead_time, make: self.product.make, name: self.adder_array[i][j].name, sku: self.product.sku, updated_at: self.product.modified_dates.updated_at, created_at: self.product.modified_dates.created_at)
                                let quote_item_id = apiDispatcher.dispatcher.postNewQuoteItem(quote_item: quote_item)
                                //If there is no internet or general server side error
                                if(quote_item_id == 0){
                                    DispatchQueue.main.async {
                                        // UI updates must be on main thread
                                        let alert = UIAlertController(title: "Error", message: "There was an error adding the quote item: \(self.adder_array[i][j].name). Please try again later.", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                        return
                                    }
                                }
                            }
                        }
                        else {
                            if(cell_array[i][j].buttonSelected != 0){
                                for element in quoteItemsFromBundle {
                                    if adder_array[i][j].name == element.name {
                                        element.quantity = cell_array[i][j].quantity
                                        if cell_array[i][j].buttonSelected == 2 {
                                            element.option = true
                                        }
                                        else {
                                            element.option = false
                                        }
                                        let _ = apiDispatcher.dispatcher.updateQuoteItem(quote_item: element)
                                    }
                                }
                            }
                            else{
                                for element in quoteItemsFromBundle {
                                    if adder_array[i][j].name == element.name {
                                        let _ = apiDispatcher.dispatcher.deleteQuoteItem(id: element.id)
                                    }
                                }
                            }
                        }
                    }
                    else if (startQuantities[i][j] != cell_array[i][j].quantity && cell_array[i][j].quantity > 0) {
                        if(cell_array[i][j].buttonSelected != 0){
                            for element in quoteItemsFromBundle {
                                if adder_array[i][j].name == element.name {
                                    element.quantity = cell_array[i][j].quantity
                                    let _ = apiDispatcher.dispatcher.updateQuoteItem(quote_item: element)
                                }
                            }
                        }
                    }
                }
            }
            self.quote = apiDispatcher.dispatcher.getQuote(quote_id: quote.id)
            quote_delegate?.passQuote(quote: self.quote, new: false)
            //Reload items in bundle
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: BundleViewController.self) {
                    controller.viewDidLoad()
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //Changes the cell_array to the new option value given by the cell
    func changeOptionValue(option: Int, section: Int, row: Int) {
        cell_array[section][row].buttonSelected = option
    }
    
    func changeQuantity(quantity: Int, section: Int, row: Int) {
        cell_array[section][row].quantity = quantity
    }
    
}
