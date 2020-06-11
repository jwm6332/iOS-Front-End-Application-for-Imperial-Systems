//**********************************************//
//          Imperial Systems Inc.               //
//**********************************************//
//                                              //
//  Filename:   BundleViewController.swift      //
//                                              //
//  Desc:       Search for file functionality   //
//                                              //
//  Creation:   03Mar20                         //
//**********************************************//

import UIKit

protocol changeOrderProtocol {
    func changeOrder(quoteItem: QuoteItem, trigger: Int)
}
protocol navConProtocol {
    func passInstance(quoteItem: QuoteItem, delete: Bool)
}

class QuoteItemCell: UITableViewCell, quoteItemProtocol {
    var cellQuoteItem = QuoteItem()
    
    func passQuoteItems(quoteItem: QuoteItem) {
        cellQuoteItem = quoteItem
    }
    
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var deleteQuoteItemButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var downArrow: UIButton!
    
    //**********************************************//
    //                                              //
    //  func:   topArrow, bottomArrow, ... , upArrow//
    //                                              //
    //  Desc:   Either changes the order of the     //
    //          quote items in the list or utilizes //
    //          the delegate to handle the edit and //
    //          delete buttons                      //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func topArrow(_ sender: Any) {
        changeOrder_delegate?.changeOrder(quoteItem: cellQuoteItem, trigger: -2)
    }
    
    @IBAction func bottomArrow(_ sender: Any) {
        changeOrder_delegate?.changeOrder(quoteItem: cellQuoteItem, trigger: 2)
    }
    @IBOutlet weak var upArrow: UIButton!
    var navCon_delegate:navConProtocol?
    var changeOrder_delegate:changeOrderProtocol?
    
    @IBAction func deleteClicked(_ sender: Any) {
        self.navCon_delegate?.passInstance(quoteItem: cellQuoteItem, delete: true)
    }
    @IBAction func editClicked(_ sender: Any) {
        self.navCon_delegate?.passInstance(quoteItem: cellQuoteItem, delete: false)
    }
    @IBAction func downArrow(_ sender: Any) {
        changeOrder_delegate?.changeOrder(quoteItem: cellQuoteItem, trigger: 1)
    }
    @IBAction func upArrow(_ sender: Any) {
        changeOrder_delegate?.changeOrder(quoteItem: cellQuoteItem, trigger: -1)
    }
    
}
class BundleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, navConProtocol, quoteItemProtocol, changeOrderProtocol, addQuoteItemProtocol {
    
    @IBOutlet weak var Activity: UIActivityIndicatorView!
    @IBOutlet weak var quoteItemsTable: UITableView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var bundle_delegate:BundleProtocol?
    var quoteItem_delegate:quoteItemProtocol?
    var quote_delegate:QuoteProtocol?
    var quoteItemToSend = QuoteItem()
    var bundle = Bundle()
    var quote = Quote()
    var quote_items = [QuoteItem]()
    
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
        self.quoteItemsTable.rowHeight = 90
        self.quoteItemsTable.delegate = self
        self.quoteItemsTable.dataSource = self
        self.navigationItem.title = bundle.name + " Bundle"
        Activity.center = self.view.center
        Activity.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        Activity.startAnimating()
        //Get the adders for the product
        DispatchQueue.global(qos: .default).async {
            self.quote_items = apiDispatcher.dispatcher.getAllQuoteItemsInBundle(DESC: false, bundle_id: self.bundle.id)
            let _ = self.bubbleSort()
            DispatchQueue.main.async { [weak self] in
                // UI updates must be on main thread
                self?.Activity.stopAnimating()
                self?.quoteItemsTable.reloadData()
            }
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   viewWillAppear                      //
    //                                              //
    //  Desc:   On view appearance, if a cell is    //
    //          already selected, deselect it       //
    //                                              //
    //  args:   animated - Bool                     //
    //**********************************************//
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.quoteItemsTable.indexPathForSelectedRow{
            self.quoteItemsTable.deselectRow(at: index, animated: true)
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   viewDidAppear                       //
    //                                              //
    //  Desc:   Upon view loading, if a bundle is   //
    //          empty, attempt to delete it         //
    //                                              //
    //  args:   animated - Bool                     //
    //**********************************************//
    override func viewDidAppear(_ animated: Bool) {
        if quote_items.count == 0 {
            let _ = apiDispatcher.dispatcher.deleteBundle(id: bundle.id)
            self.navigationController?.popToRootViewController(animated: true)
        }
        else{
            let changed = self.bubbleSort()
            if(changed){
                self.quoteItemsTable.reloadData()
            }
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   tableView                           //
    //                                              //
    //  Desc:   Returns the correct number of quote //
    //          item entries to populate the table  //
    //          with                                //
    //                                              //
    //  args:   tableView - UITableView             //
    //          section - Int                       //
    //**********************************************//
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quote_items.count
    }
    
    //**********************************************//
    //                                              //
    //  func:   numberOfSections                    //
    //                                              //
    //  Desc:   returns the number of sections      //
    //          set for the tableView, which is     //
    //          selected to be one                  //
    //                                              //
    //  args:   tableView - UITableView             //
    //**********************************************//
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //**********************************************//
    //                                              //
    //  func:   tableView                           //
    //                                              //
    //  Desc:   Populates the tableView's cells     //
    //          and style using the QuoteItem array //
    //                                              //
    //  args:   tableView - UITableView             //
    //          indexPath - IndexPath               //
    //**********************************************//
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.quoteItemsTable.separatorColor = UIColor.systemBlue
        self.quoteItemsTable.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        let cell = self.quoteItemsTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QuoteItemCell
        cell.navCon_delegate = self
        cell.changeOrder_delegate = self
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.nameTextField.text = self.quote_items[indexPath.row].name
        cell.nameTextField.centerVertically()
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let formatted_price = formatter.string(from: quote_items[indexPath.row].price as NSNumber) {
            cell.priceLabel.text = formatted_price
        }
        cell.quantityTextField.text = String(self.quote_items[indexPath.row].quantity)
        if(!self.quote_items[indexPath.row].option){
            cell.optionLabel.isHidden = true
        }
        else{
            cell.optionLabel.isHidden = false
        }
        self.quoteItem_delegate = cell
        quoteItem_delegate?.passQuoteItems(quoteItem: self.quote_items[indexPath.row])
        return cell
    }
    
    //**********************************************//
    //                                              //
    //  func:   tableView                           //
    //                                              //
    //  Desc:   Returns the header title to be used //
    //          for the tableView                   //
    //                                              //
    //  args:   tableView - UITableView             //
    //          section - Int                       //
    //**********************************************//
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Quote Items:"
    }
    
    //**********************************************//
    //                                              //
    //  func:   deleteClick                         //
    //                                              //
    //  Desc:   Attempts to delete the Bundle with  //
    //          an alert confirmation to begin      //
    //                                              //
    //  args:   sender - Any                        //
    //**********************************************//
    @IBAction func deleteClick(_ sender: Any) {
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete \(bundle.name ?? "bundle")?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            let code = apiDispatcher.dispatcher.deleteBundle(id: self.bundle.id)
            self.quote = apiDispatcher.dispatcher.getQuote(quote_id: self.quote.id)
            if (code == 200){
                self.bundle.id = -1
                self.bundle_delegate?.passBundle(bundle: self.bundle, new: false)
                self.quote_delegate?.passQuote(quote: self.quote, new: false)
                self.navigationController?.popViewController(animated: true)
            } else {
                let alert = UIAlertController(title: "Bundle Deletion Error", message:
                    "The bundle could not be deleted at this time. Please try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //**********************************************//
    //                                              //
    //  func:   passInstance                        //
    //                                              //
    //  Desc:   If delete is true, this attempts to //
    //          delete the quote item in question.  //
    //          The user is prompted to confirm this//
    //          deletion first. If delete is false, //
    //          The view is segued to the edit      //
    //          quote item view                     //
    //                                              //
    //  args:   quoteItem - QuoteItem               //
    //          delete - Bool                       //
    //**********************************************//
    func passInstance(quoteItem: QuoteItem, delete: Bool) {
        if(delete){
            let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete \(quoteItem.name)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                let code = apiDispatcher.dispatcher.deleteQuoteItem(id: quoteItem.id)
                if(code == 200){
                    self.quote = apiDispatcher.dispatcher.getQuote(quote_id: self.quote.id)
                    self.quote_delegate?.passQuote(quote: self.quote, new: false)
                    for (index, item) in self.quote_items.enumerated() {
                        if(item.id == quoteItem.id){
                            self.quote_items.remove(at: index)
                            if(self.quote_items.count == 0){
                                let _ = apiDispatcher.dispatcher.deleteBundle(id: self.bundle.id)
                                self.bundle.id = -1
                                self.bundle_delegate?.passBundle(bundle: self.bundle, new: false)
                                self.navigationController?.popViewController(animated: true)
                            }
                            else {
                                self.quoteItemsTable.reloadData()
                            }
                        }
                    }
                }
                else{
                    let alert = UIAlertController(title: "Quote Item Deletion Error", message:
                        "The quote item could not be deleted at this time. Please try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            self.quoteItemToSend = quoteItem
            performSegue(withIdentifier: "quoteItemSegue", sender: self)
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   prepare                             //
    //                                              //
    //  Desc:   Prepares data to pass along for     //
    //          certain segues                      //
    //                                              //
    //  args:   segue - UIStoryboardSegue           //
    //          sender - Any                        //
    //**********************************************//
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "quoteItemSegue" {
            if let viewController = segue.destination as? QuoteItemViewController {
                //sets the delegate of the next controller to this controller
                viewController.quoteItem = quoteItemToSend
                viewController.quoteItem_delegate = self
                viewController.quote = quote
                viewController.quote_delegate = quote_delegate
            }
        }
        if segue.identifier == "customItemSegue" {
            if let viewController = segue.destination as? CustomItemViewController
            {
                var tempQI = quote_items[0]
                for element in quote_items {
                    if(tempQI.bundle_position < element.bundle_position){
                        tempQI = element
                    }
                }
                viewController.quoteItem = tempQI
                viewController.quote = quote
                viewController.addQuoteItem_delegate = self
                viewController.quote_delegate = quote_delegate
            }
        }
        if segue.identifier == "productSegue" {
            if let viewController = segue.destination as? SpecificProductViewController {
                //sets the delegate of the next controller to this controller
                if(quote_items.count > 0){
                    let product = apiDispatcher.dispatcher.getProduct(product_id: quote_items[0].product_id)
                    viewController.quoteItemsFromBundle = quote_items
                    viewController.quote = quote
                    viewController.product = product
                    viewController.bundle_id = bundle.id
                    viewController.make = product.make
                    viewController.edit = true
                    viewController.quote_delegate = quote_delegate
                }
            }
        }
        
    }
    
    //**********************************************//
    //                                              //
    //  func:   passQuoteItems                      //
    //                                              //
    //  Desc:   Used by delegate to pass quoteItems //
    //          from one view to another            //
    //                                              //
    //  args:   quoteItem - QuoteItem               //
    //**********************************************//
    func passQuoteItems(quoteItem: QuoteItem) {
        for (index, element) in quote_items.enumerated() {
            if(element.id == quoteItem.id){
                quote_items[index].name = quoteItem.name
                quote_items[index].quantity = quoteItem.quantity
            }
        }
        self.quoteItemsTable.reloadData()
    }
    
    //**********************************************//
    //                                              //
    //  func:   bubbleSort                          //
    //                                              //
    //  Desc:   Bubble sorts the quote_items array  //
    //          based on bundle position            //
    //                                              //
    //  args:                                       //
    //**********************************************//
    func bubbleSort() -> Bool
    {
        var changed = false
        if(quote_items.count > 1){
            for i in 1...self.quote_items.count {
                for j in 0 ..< self.quote_items.count - i {
                    if self.quote_items[j].bundle_position > self.quote_items[j + 1].bundle_position {
                        self.quote_items.swapAt(j, j + 1)
                        changed = true
                    }
                }
            }
            //Update values to have no gaps in bundle positions
            for (index, element) in self.quote_items.enumerated() {
                if(element.bundle_position != index){
                    element.bundle_position = index
                    let _ = apiDispatcher.dispatcher.updateQuoteItem(quote_item: element)
                }
            }
        }
        return changed
    }
    
    /*Trigger Numbers:
     1: Move down one
     2: Move to last item
     -1: Move up one
     -2: Move to first item
     */
    //**********************************************//
    //                                              //
    //  func:   changeOrder                         //
    //                                              //
    //  Desc:   Changes the quote item's bundle     //
    //          position based on the trigger number//
    //          passed into the function            //
    //                                              //
    //  args:   quoteItem - QuoteItem               //
    //          trigger - Int                       //
    //**********************************************//
    func changeOrder(quoteItem: QuoteItem, trigger: Int) {
        var code: Int = 0
        for (index, element) in quote_items.enumerated() {
            if element.id == quoteItem.id {
                if(trigger == 1 && index != quote_items.count-1){
                    quote_items[index].bundle_position+=1
                    quote_items[index+1].bundle_position-=1
                    code = apiDispatcher.dispatcher.updateQuoteItem(quote_item: self.quote_items[index])
                    if(code != 200){
                        let alert = UIAlertController(title: "Could not update Quote Item", message:
                            "Please try again later.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                        self.present(alert, animated: true, completion: nil)
                        break
                    }
                    code = apiDispatcher.dispatcher.updateQuoteItem(quote_item: self.quote_items[index+1])
                    if(code != 200){
                        let alert = UIAlertController(title: "Could not update Quote Item", message:
                            "Please try again later.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                        self.present(alert, animated: true, completion: nil)
                        break
                    }
                    self.quote_items.swapAt(index, index+1)
                }
                else if(trigger == 2 && index != quote_items.count-1){
                    quote_items[index].bundle_position = quote_items.count-1
                    for i in index+1...quote_items.count-1 {
                        quote_items[i].bundle_position-=1
                        code = apiDispatcher.dispatcher.updateQuoteItem(quote_item: self.quote_items[i])
                        if(code != 200){
                            let alert = UIAlertController(title: "Could not update Quote Item", message:
                                "Please try again later.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                            self.present(alert, animated: true, completion: nil)
                            break
                        }
                    }
                    code = apiDispatcher.dispatcher.updateQuoteItem(quote_item: self.quote_items[index])
                    if(code != 200){
                        let alert = UIAlertController(title: "Could not update Quote Item", message:
                            "Please try again later.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                        self.present(alert, animated: true, completion: nil)
                    }
                    let _ = bubbleSort()
                }
                else if(trigger == -1 && index != 0){
                    quote_items[index].bundle_position-=1
                    quote_items[index-1].bundle_position+=1
                    code = apiDispatcher.dispatcher.updateQuoteItem(quote_item: self.quote_items[index])
                    if(code != 200){
                        let alert = UIAlertController(title: "Could not update Quote Item", message:
                            "Please try again later.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                        self.present(alert, animated: true, completion: nil)
                        break
                    }
                    code = apiDispatcher.dispatcher.updateQuoteItem(quote_item: self.quote_items[index-1])
                    if(code != 200){
                        let alert = UIAlertController(title: "Could not update Quote Item", message:
                            "Please try again later.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                        self.present(alert, animated: true, completion: nil)
                        break
                    }
                    self.quote_items.swapAt(index, index-1)
                }
                else if(trigger == -2 && index != 0){
                    quote_items[index].bundle_position = 0
                    for i in 0...index-1 {
                        quote_items[i].bundle_position+=1
                        code = apiDispatcher.dispatcher.updateQuoteItem(quote_item: self.quote_items[i])
                        if(code != 200){
                            let alert = UIAlertController(title: "Could not update Quote Item", message:
                                "Please try again later.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                            self.present(alert, animated: true, completion: nil)
                            break
                        }
                    }
                    code = apiDispatcher.dispatcher.updateQuoteItem(quote_item: self.quote_items[index])
                    if(code != 200){
                        let alert = UIAlertController(title: "Could not update Quote Item", message:
                            "Please try again later.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                        self.present(alert, animated: true, completion: nil)
                        break
                    }
                    let _ = bubbleSort()
                }
                self.quoteItemsTable.reloadData()
            }
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   addQuoteItem                        //
    //                                              //
    //  Desc:   Appends a new quote item to the     //
    //          quote item array that comes from    //
    //          the delegate from another view      //
    //                                              //
    //  args:   quoteItem - QuoteItem               //
    //**********************************************//
    func addQuoteItem(quoteItem: QuoteItem) {
        quote_items.append(quoteItem)
        let _ = self.bubbleSort()
        self.quoteItemsTable.reloadData()
    }
    
}

