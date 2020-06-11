//************************************************//
//          Imperial Systems Inc.                 //
//************************************************//
//                                                //
//  Filename:   SpecificQuoteViewController.swift //
//                                                //
//  Desc:       Search for file functionality     //
//                                                //
//  Creation:   03Mar20                           //
//************************************************//

import UIKit

protocol changeBundleOrderProtocol {
    func changeOrder(bundle: Bundle, trigger: Int)
}

class BundlesCell: UITableViewCell {
    var delegate:changeBundleOrderProtocol?
    var bundle = Bundle()
    @IBOutlet weak var bundleName: UILabel!
    @IBAction func upButtonClicked(_ sender: Any) {
        delegate?.changeOrder(bundle: bundle, trigger: -1)
    }
    @IBAction func downButtonClicked(_ sender: Any) {
        delegate?.changeOrder(bundle: bundle, trigger: 1)
    }
    
}

class SpecificQuoteViewController: UIViewController, QuoteProtocol, UITableViewDelegate, UITableViewDataSource, BundleProtocol, changeBundleOrderProtocol {
    
    func passBundle(bundle: Bundle, new: Bool) {
        if(new){
            bundleArray.append(bundle)
        }
            //Bundle was deleted
        else if(bundle.id == -1 && !new){
            bundleArray.remove(at: selectedRow)
        }
        else {
            bundleArray[selectedRow] = bundle
        }
        bundlesTable.reloadData()
    }
    
    
    func passQuote(quote: Quote, new: Bool) {
        quote_delegate?.passQuote(quote: quote, new: new)
        //Quote was not deleted
        if quote.id != 0 {
            self.quote = quote
            self.setupData()
        }
    }
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    var quote = Quote()
    var quote_delegate:QuoteProtocol?
    var bundleArray = [Bundle]()
    var selectedBundle = Bundle()
    var selectedRow: Int = 0
    @IBOutlet weak var bundlesTable: UITableView!
    @IBOutlet weak var editQuoteButton: UIButton!
    @IBOutlet weak var multiplierLabel: UILabel!
    @IBOutlet weak var quoteNumberLabel: UILabel!
    @IBOutlet weak var netToImperialLabel: UILabel!
    @IBOutlet weak var commissionLabel: UILabel!
    @IBOutlet weak var sellPriceLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var applicationLabel: UILabel!
    @IBOutlet weak var listPricesLabel: UILabel!
    @IBOutlet weak var leadTimeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
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
        self.setupData()
        self.bundlesTable.estimatedRowHeight = 60
        self.bundlesTable.delegate = self
        self.bundlesTable.dataSource = self
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .default).async {
            self.bundleArray = apiDispatcher.dispatcher.getBundlesForQuote(DESC: false, id: self.quote.id)
            let _ = self.bubbleSort()
            DispatchQueue.main.async { [weak self] in
                // UI updates must be on main thread
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                self?.bundlesTable.reloadData()
            }
        }
    }
    
    func setupData(){
        navigationBar.title = quote.quote_number
        multiplierLabel.text = String(quote.multiplier)
        quoteNumberLabel.text = quote.quote_number
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let formatted_price = formatter.string(from: quote.net_imperial as NSNumber) {
            netToImperialLabel.text = formatted_price
        }
        if let formatted_price = formatter.string(from: quote.sell_price as NSNumber) {
            sellPriceLabel.text = formatted_price
        }
        commissionLabel.text = String("\(quote.commission ?? 0.0)%")
        accountLabel.text = quote.account_name
        applicationLabel.text = quote.application
        leadTimeLabel.text = quote.lead_time
        if(quote.list_prices){
            listPricesLabel.text = "Yes"
        }
        else{
            listPricesLabel.text = "No"
        }
        if(quote.open){
            statusLabel.text = "Open"
        }
        else{
            statusLabel.text = "Closed"
        }
    }
    
    //**********************************************//
    //                                              //
    //  func:   copyQuoteClicked                    //
    //                                              //
    //  Desc:   Attempts to copy the current quote  //
    //          and populate a new quote with the   //
    //          same data. This will create new     //
    //          quote_items, new bundles, and a new //
    //          quote.                              //
    //                                              //
    //  args:                                       //
    //**********************************************//
    @IBAction func copyQuoteClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Copy", message: "Would you like to copy \(quote.quote_number!)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            self.view.isUserInteractionEnabled = false
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.center = self.view.center
            activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
            self.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            var new_quote = Quote.init()
            DispatchQueue.global(qos: .default).async {
                self.quote.quote_number += " (Copy)"
                let quote_id = apiDispatcher.dispatcher.postNewQuote(quote: self.quote)
                self.quote.quote_number.removeLast(7)
                if(quote_id == 0){
                    DispatchQueue.main.async {
                        activityIndicator.stopAnimating()
                        //Internal Server Error
                        let alert = UIAlertController(title: "Quote Creation Error", message:
                            "An internal server error has been encountered. Please try again later.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                }
                for element in self.bundleArray {
                    element.quote_id = quote_id
                    let bundle_id = apiDispatcher.dispatcher.postNewBundle(bundleObj: element)
                    if(bundle_id == 0){
                        DispatchQueue.main.async {
                            activityIndicator.stopAnimating()
                            //Internal Server Error
                            let alert = UIAlertController(title: "Bundle Creation Error", message:
                                "An internal server error has been encountered. Please try again later.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                    }
                    element.quote_id = self.quote.id
                    let quote_items = apiDispatcher.dispatcher.getAllQuoteItemsInBundle(DESC: false, bundle_id: element.id)
                    for quote_item in quote_items {
                        quote_item.bundle_id = bundle_id
                        let quote_item_id = apiDispatcher.dispatcher.postNewQuoteItem(quote_item: quote_item)
                        if(quote_item_id == 0){
                            DispatchQueue.main.async {
                                activityIndicator.stopAnimating()
                                //Internal Server Error
                                let alert = UIAlertController(title: "Quote Item Creation Error", message:
                                    "An internal server error has been encountered. Please try again later.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                                self.present(alert, animated: true, completion: nil)
                                return
                            }
                        }
                    }
                }
                new_quote = apiDispatcher.dispatcher.getQuote(quote_id: quote_id)
                DispatchQueue.main.async { [weak self] in
                    // UI updates must be on main thread
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()
                    self?.navigationController?.popToRootViewController(animated: true)
                    self?.quote_delegate?.passQuote(quote: new_quote, new: true)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditQuoteSegue" {
            if let viewController = segue.destination as? EditQuoteViewController {
                //sets the delegate of the next controller to this controller
                viewController.quote_delegate = self
                viewController.quote = quote
            }
        }
        else if segue.identifier == "addToQuoteSegue" {
            if let viewController = segue.destination as? MakesCollectionViewController {
                //sets the delegate of the next controller to this controller
                viewController.quote = quote
                viewController.quote_delegate = self
                viewController.bundle_delegate = self
            }
        }
        else if segue.identifier == "bundleViewSegue" {
            if let viewController = segue.destination as? BundleViewController {
                viewController.bundle_delegate = self
                viewController.quote_delegate = self
                viewController.bundle = selectedBundle
                viewController.quote = quote
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBundle = bundleArray[indexPath.row]
        selectedRow = indexPath.row
        self.performSegue(withIdentifier: "bundleViewSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bundleArray.count
    }
    
    func tableView( _ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Bundles:"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        self.bundlesTable.separatorColor = UIColor.systemBlue
        self.bundlesTable.tableFooterView = UIView(frame: CGRect(x: 0,y: 0, width: 0, height: 0))
        let cell = self.bundlesTable.dequeueReusableCell(withIdentifier: "BundlesCell", for: indexPath) as! BundlesCell
        cell.preservesSuperviewLayoutMargins = false
        cell.delegate = self
        cell.bundle = bundleArray[indexPath.row]
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.bundleName.text = bundleArray[indexPath.row].name
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.bundlesTable.indexPathForSelectedRow{
            self.bundlesTable.deselectRow(at: index, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if bundleArray.count != 0 {
            let changed = self.bubbleSort()
            if(changed){
                self.bundlesTable.reloadData()
            }
        }
    }
    
    /*Trigger Numbers:
     1: Move down one
     -1: Move up one
     */
    func changeOrder(bundle: Bundle, trigger: Int) {
        var code: Int = 0
        for (index, element) in bundleArray.enumerated() {
            if element.id == bundle.id {
                if(trigger == 1 && index != bundleArray.count-1){
                    bundleArray[index].quote_position+=1
                    bundleArray[index+1].quote_position-=1
                    code = apiDispatcher.dispatcher.updateBundle(bundleObj: bundleArray[index])
                    if(code != 200){
                        let alert = UIAlertController(title: "Could not update bundle", message:
                            "Please try again later.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                        self.present(alert, animated: true, completion: nil)
                        break
                    }
                    code = apiDispatcher.dispatcher.updateBundle(bundleObj: bundleArray[index+1])
                    if(code != 200){
                        let alert = UIAlertController(title: "Could not update bundle", message:
                            "Please try again later.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                        self.present(alert, animated: true, completion: nil)
                        break
                    }
                    self.bundleArray.swapAt(index, index+1)
                }
                else if(trigger == -1 && index != 0){
                    bundleArray[index].quote_position-=1
                    bundleArray[index-1].quote_position+=1
                    code = apiDispatcher.dispatcher.updateBundle(bundleObj: bundleArray[index])
                    if(code != 200){
                        let alert = UIAlertController(title: "Could not update bundle", message:
                            "Please try again later.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                        self.present(alert, animated: true, completion: nil)
                        break
                    }
                    code = apiDispatcher.dispatcher.updateBundle(bundleObj: bundleArray[index-1])
                    if(code != 200){
                        let alert = UIAlertController(title: "Could not update bundle", message:
                            "Please try again later.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                        self.present(alert, animated: true, completion: nil)
                        break
                    }
                    self.bundleArray.swapAt(index, index-1)
                }
                self.bundlesTable.reloadData()
            }
        }
    }
    
    // A function to implement bubble sort
    func bubbleSort() -> Bool
    {
        var changed = false
        if(bundleArray.count > 1){
            for i in 1...self.bundleArray.count {
                for j in 0 ..< self.bundleArray.count - i {
                    if self.bundleArray[j].quote_position > self.bundleArray[j + 1].quote_position {
                        self.bundleArray.swapAt(j, j + 1)
                        changed = true
                    }
                }
            }
            //Update values to have no gaps in bundle positions
            for (index, element) in self.bundleArray.enumerated() {
                if(element.quote_position != index){
                    element.quote_position = index
                    let _ = apiDispatcher.dispatcher.updateBundle(bundleObj: element)
                }
            }
        }
        return changed
    }
    
    //**********************************************//
    //                                              //
    //  func:   emptyQuoteClicked                   //
    //                                              //
    //  Desc:   Attempts to remove all quote_items  //
    //          and bundles from the quote          //
    //                                              //
    //  args:                                       //
    //**********************************************//
    @IBAction func emptyQuoteClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Empty Quote", message: "Are you sure you want to empty the quote?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            self.view.isUserInteractionEnabled = false
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.center = self.view.center
            activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
            self.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            DispatchQueue.global(qos: .default).async {
                for element in self.bundleArray {
                    let quote_items = apiDispatcher.dispatcher.getAllQuoteItemsInBundle(DESC: false, bundle_id: element.id)
                    for quote_item in quote_items {
                        let code = apiDispatcher.dispatcher.deleteQuoteItem(id: quote_item.id)
                        if(code != 200){
                            DispatchQueue.main.async {
                                activityIndicator.stopAnimating()
                                //Internal Server Error
                                let alert = UIAlertController(title: "Quote Item Deletion Error", message:
                                    "An internal server error has been encountered. Please try again later.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                                self.present(alert, animated: true, completion: nil)
                                return
                            }
                        }
                    }
                    let _ = apiDispatcher.dispatcher.deleteBundle(id: element.id)
                }
                
                self.quote = apiDispatcher.dispatcher.getQuote(quote_id: self.quote.id)
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    self.quote_delegate?.passQuote(quote: self.quote, new: false)
                    self.setupData()
                    self.bundleArray.removeAll()
                    self.bundlesTable.reloadData()
                    self.view.isUserInteractionEnabled = true
                }
            }
            //Don't need to delete bundles as if you try to you get a 404 error. Backend deletes the empty bundle automatically.
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
